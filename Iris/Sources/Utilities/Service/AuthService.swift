//
//  AuthService.swift
//  Iris
//
//  Created by Luki on 13/09/2024.
//

import Foundation

/// Singleton auth service to make API calls related to authentication
final actor AuthService {
	static let shared = AuthService()
	private init() {}

	private enum Constants {
		static let baseURL = "https://ianthea-luki120.koyeb.app/v1/auth/"
	}

	enum Result {
		case success, unauthorized
	}

	enum AuthError: String, Error {
		case badURL = "Malformed API URL"
		case badServerResponse = "Bad server response"
		case conflict = "A conflict occurred, please check server logs"
		case unknownError = "An unknown error occured"

		var description: String { rawValue }
	}

	private enum Route: String {
		case signup, signin, authenticate, secret, users
	}

	/// Function to sign up a user
	/// - Parameters:
	///		- username: A `String` that represents the username
	///		- password: A `String` that represents the password
	///	- Returns: `Result`
	/// - Throws: `AuthError`
	func signUp(username: String, password: String) async throws -> Result {
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
	///		- username: A `String` that represents the username
	///		- password: A `String` that represents the password
	///	- Returns: `Result`
	/// - Throws: `AuthError`
	func signIn(username: String, password: String) async throws -> Result {
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

				let userId = try await getUserId()
				await SubjectsManager.shared.setCurrentUser(id: userId)

				return .success

			case 401: return .unauthorized
			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	/// Function to authenticate a user
	///	- Returns: `Result`
	/// - Throws: `AuthError`
	func authenticate() async throws -> Result {
		guard let token = UserDefaults.standard.string(forKey: "jwtToken") else { return .unauthorized }
		guard let url = URL(string: Constants.baseURL + Route.authenticate.rawValue) else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

		let (_, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200:
				let userId = try await getUserId()
				await SubjectsManager.shared.setCurrentUser(id: userId)

				return .success

			case 401:
				UserDefaults.standard.removeObject(forKey: "jwtToken")
				return .unauthorized

			case 409: throw AuthError.conflict
			case 500...600: throw AuthError.badServerResponse
			default: throw AuthError.unknownError
		}
	}

	/// Function to delete an account with the user id that matches the JWT token stored in UserDefaults
	///	- Returns: `Result`
	/// - Throws: `AuthError`
	func deleteAccount() async throws -> Result {
		let userId = try await getUserId()
		guard let url = URL(string: Constants.baseURL + Route.users.rawValue + "/\(userId)") else { throw AuthError.badURL }

		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"

		let (_, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else { throw AuthError.unknownError }

		switch httpResponse.statusCode {
			case 200:
				UserDefaults.standard.removeObject(forKey: "jwtToken")
				await SubjectsManager.shared.clearCurrentUser()
				try await SubjectsManager.shared.deleteData(userId: userId)

				return .success

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
