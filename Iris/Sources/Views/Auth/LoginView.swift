//
//  LoginView.swift
//  Iris
//
//  Created by Luki on 15/09/2024.
//

import SwiftUI

/// View that'll show the login view
struct LoginView: View {
	@State private var viewModel = LoginViewViewModel()

	@FocusState private var isUsernameFocused
	@FocusState private var isPasswordFocused

	var body: some View {
		VStack {
			Text("Welcome back, Luki")
				.font(.quicksand(withStyle: .bold, size: 55))
				.foregroundStyle(.white)
				.frame(height: 160)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(20)

			ScrollView {
				VStack {
					Text(viewModel.isRegistering ? "Sign up" : "Login")
						.animation(.smooth, value: viewModel.isRegistering)
						.font(.quicksand(withStyle: .bold, size: 22))
						.foregroundStyle(.black)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.top, 20)

					CleanTextField(
						title: "Username",
						hint: "Luki120",
						icon: "person",
						value: $viewModel.username
					)
					.focused($isUsernameFocused)
					.onSubmit(of: .text) {
						isPasswordFocused = true
					}
					.padding(.top, 30)
					.submitLabel(.next)

					CleanTextField(
						title: "Password",
						hint: "@^&#^&HSJHDSJfm",
						icon: "lock",
						value: $viewModel.password,
						showPassword: $viewModel.showPassword
					)
					.focused($isPasswordFocused)
					.padding(.top, 15)
					.submitLabel(.done)

					Button(viewModel.isRegistering ? "Sign up" : "Login") {
						if viewModel.isRegistering {
							viewModel.signUp()
						}
						else {
							viewModel.signIn()
						}
					}
					.animation(.smooth, value: viewModel.isRegistering)
					.foregroundStyle(.white)
					.frame(width: 120, height: 50)
					.background(Color.irisSlateBlue, in: .capsule)
					.padding(.vertical, 25)
					.shadow(color: .black.opacity(0.4), radius: 5)

					Button("Create account") {
						viewModel.isRegistering.toggle()
					}
					.font(.quicksand(withStyle: .bold))
					.foregroundStyle(Color.irisSlateBlue)

				}
				.ignoresSafeArea()
				.padding(30)

				if viewModel.showToast {
					Text(viewModel.errorMessage)
						.font(.quicksand(withStyle: .medium, size: 14))
						.frame(height: 40)
						.padding(.horizontal, 20)
						.background(Color.irisSlateBlue, in: .capsule)
						.transition(.opacity.combined(with: .scale))
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(
				Color.white,
				in: UnevenRoundedRectangle(
					cornerRadii: .init(topLeading: 25, topTrailing: 25),
					style: .continuous
				)
			)
			.ignoresSafeArea()
			.scrollIndicators(.hidden)
		}
		.background(Color.irisSlateBlue)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.fullScreenCover(isPresented: $viewModel.presentHomeVC) {
			TabBarVCRepresentable()
				.ignoresSafeArea()
		}
	}

	@ViewBuilder
	private func CleanTextField(
		title: String,
		hint: String,
		icon: String,
		value: Binding<String>,
		showPassword: Binding<Bool> = .constant(false)
	) -> some View {
		VStack(alignment: .leading) {
			Label(title, systemImage: icon)
				.font(.quicksand(withStyle: .medium, size: 14))
				.foregroundStyle(.black.opacity(0.8))

			if title == "Password" && !showPassword.wrappedValue {
				SecureField("", text: value, prompt: Text(hint).foregroundStyle(.gray))
					.padding(.top, 2)
			}
			else {
				TextField("", text: value, prompt: Text(hint).foregroundStyle(.gray))
					.padding(.top, 2)
			}

			Divider()
				.background(Color.black.opacity(0.4))
		}
		.foregroundStyle(.black)
		.overlay {
			if title == "Password" {
				Button("", systemImage: showPassword.wrappedValue ? "eye.slash" : "eye") {
					withAnimation(.smooth) {
						showPassword.wrappedValue.toggle()
					}
				}
				.font(.quicksand(withStyle: .bold,  size: 14))
				.foregroundStyle(Color.irisSlateBlue)
				.frame(maxWidth: .infinity, alignment: .trailing)
			}
		}
	}
}

private struct TabBarVCRepresentable: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> TabBarVC {
		return TabBarVC()
	}

	func updateUIViewController(_ uiViewController: TabBarVC, context: Context) {}
}

#Preview {
    LoginView()
}
