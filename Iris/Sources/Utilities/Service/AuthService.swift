//
//  AuthService.swift
//  Iris
//
//  Created by Luki on 13/09/2024.
//

import Foundation

enum AuthResult {
	case success
	case unauthorized
}

enum AuthError: String, Error {
	case badURL = "Malformed API URL"
	case badServerResponse = "Bad server response"
	case conflict = "A conflict occurred, please check server logs"
	case unknownError = "An unknown error occured"

	var description: String { rawValue }
}

/// Singleton auth service to make API calls related to authentication
final class AuthService {

	static let shared = AuthService()
	private init() {}

	private enum Constants {
		static let baseURL = "https://ianthea-luki120.koyeb.app/v1/auth/"
	}

	@frozen
	private enum Route: String {
		case signup, signin, authenticate, secret, users
	}

	/// Function to sign up a user
	/// - Parameters:
	///		- username: A string that represents the username
	///		- password: A string that represents the password
	///	- Returns: AuthResult
	/// - Throws: An error of type AuthError
	func signUp(username: String, password: String) async throws -> AuthResult {
		guard let url = URL(string: Constants.baseURL + Route.signup.rawValue) else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		let authRequest = AuthRequest(username: username, password: password)

		let jsonData = try JSONEncoder().encode(authRequest)
		request.httpBody = jsonData

		let (_, response) = try await URLSession.shared.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200: return try await signIn(username: username, password: password)
			case 401: return .unauthorized
			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	/// Function to sign in a user
	/// - Parameters:
	///		- username: A string that represents the username
	///		- password: A strrng that represents the password
	///	- Returns: AuthResult
	/// - Throws: An error of type AuthError
	func signIn(username: String, password: String) async throws -> AuthResult {
		guard let url = URL(string: Constants.baseURL + Route.signin.rawValue) else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		let authRequest = AuthRequest(username: username, password: password)

		let jsonData = try JSONEncoder().encode(authRequest)
		request.httpBody = jsonData

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200:
				let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
				UserDefaults.standard.set(tokenResponse.token, forKey: "jwtToken")
				return .success

			case 401: return .unauthorized
			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	/// Function to authenticate a user
	///	- Returns: AuthResult
	/// - Throws: An error of type AuthError
	func authenticate() async throws -> AuthResult {
		guard let token = UserDefaults.standard.string(forKey: "jwtToken") else { return .unauthorized }
		guard let url = URL(string: Constants.baseURL + Route.authenticate.rawValue) else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

		let (_, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200: return .success
			case 401:
				UserDefaults.standard.removeObject(forKey: "jwtToken")
				return .unauthorized

			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	/// Function to delete an account with the user id that matches the JWT token stored in UserDefaults
	///	- Returns: AuthResult
	/// - Throws: An error of type AuthError
	func deleteAccount() async throws -> AuthResult {
		let userId = try await getUserId()
		guard let url = URL(string: Constants.baseURL + Route.users.rawValue + "/\(userId)") else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"

		let (_, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200: return .success
			case 401: return .unauthorized
			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	private func getUserId() async throws -> String {
		guard let token = UserDefaults.standard.string(forKey: "jwtToken") else { throw AuthError.unknownError }
		guard let url = URL(string: Constants.baseURL + Route.secret.rawValue) else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200: return String(data: data, encoding: .utf8) ?? ""
			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}
}
