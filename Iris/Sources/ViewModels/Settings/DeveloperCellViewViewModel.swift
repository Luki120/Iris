//
//  DeveloperCellViewViewModel.swift
//  Iris
//
//  Created by Luki on 19/09/2024.
//

import Foundation
import UIKit.UIImage
import func SwiftUI.withAnimation

/// View model class for `DeveloperCellView`
@MainActor
final class DeveloperCellViewViewModel {
	let name: String
	private(set) var image = UIImage()

	/// Designated initializer
	/// - Parameter name: A `String` that represents the developer name
	init(name: String) {
		self.name = name

		Task {
			await fetchImage()
		}
	}

	nonisolated
	private func fetchImage() async {
		guard let url = URL(string: .githubImageURL) else { return }

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			let image = UIImage(data: data) ?? .init()

			await MainActor.run {
				withAnimation(.smooth) {
					self.image = image
				}
			}
		}
		catch {
			print(error.localizedDescription)
		}
	}
}

// MARK: - Hashable

nonisolated extension DeveloperCellViewViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}

	static func == (lhs: DeveloperCellViewViewModel, rhs: DeveloperCellViewViewModel) -> Bool {
		return lhs.name == rhs.name
	}
}
