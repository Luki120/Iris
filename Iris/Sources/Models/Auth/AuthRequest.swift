//
//  AuthResult.swift
//  Iris
//
//  Created by Luki on 13/09/2024.
//

import Foundation

/// API model struct for authentication
struct AuthRequest: Codable {
	let username: String
	let password: String
}
