//
//  LoginViewViewModel.swift
//  Iris
//
//  Created by Luki on 15/09/2024.
//

import Foundation
import SwiftUI

/// View model class for LoginView
@MainActor
@Observable
final class LoginViewViewModel {
	@AppStorage("nickname")
	@ObservationIgnored var nickname = ""

	var username = ""
	var password = ""
	var errorMessage = ""

	var showToast = false
	var showPassword = false
	var isRegistering = false
	var presentHomeVC = false
	var shouldShowToast = true

	// MARK: - Private

	private enum ValidationError: String {
		case fieldsBlank = "Fields can't be blank"
		case foreigner = "Who tf are you? Get out"
		case passwordIsTooShort = "Password must be at least 8 characters"
	}

	private func performAuth(isSignIn: Bool = false, isManual: Bool = false) {
		guard validateFields() else { return }

		Task {
			do {
				let result = isSignIn ? try await AuthService.shared.signIn(username: username, password: password) : try await AuthService.shared.signUp(username: username, password: password)

				switch result {
					case .success:
						if isManual {
							await SubjectsManager.shared.loadData()
							try await Task.sleep(for: .seconds(0.02))
						}
						presentHomeVC.toggle()

					case .unauthorized: break
				}
			}
			catch let error as AuthService.AuthError {
				presentToast(errorMessage: error.description)
			}
		}
	}

	private func presentToast(errorMessage: String) {
		self.errorMessage = errorMessage

		guard shouldShowToast else { return }

		withAnimation(.easeInOut) {
			showToast.toggle()
			shouldShowToast = false
		}

		Task {
			try await Task.sleep(for: .seconds(1.5))

			await MainActor.run {
				withAnimation(.easeInOut, completionCriteria: .logicallyComplete) {
					showToast.toggle()
				} completion: {
					self.shouldShowToast = true
				}
			}
		}
	}

	private func validateFields() -> Bool {
		guard !username.isEmpty && !password.isEmpty else {
			presentToast(errorMessage: ValidationError.fieldsBlank.rawValue)
			return false
		}

		guard username == "Luki120" || username == "lustflouis" else {
			presentToast(errorMessage: ValidationError.foreigner.rawValue)
			return false
		}

		guard password.count >= 8 else {
			presentToast(errorMessage: ValidationError.passwordIsTooShort.rawValue)
			return false
		}

		return true
	}
}

// MARK: - Public

extension LoginViewViewModel {
	/// Function to sign up a user
	func signUp() {
		performAuth()
	}
	
	/// Function to sign in a user
	func signIn() {
		performAuth(isSignIn: true, isManual: true)
	}
}
