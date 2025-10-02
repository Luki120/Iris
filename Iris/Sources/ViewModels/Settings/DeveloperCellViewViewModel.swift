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
@Observable
final class DeveloperCellViewViewModel {
	@ObservationIgnored
	let name: String

	private(set) var image = UIImage()

	/// Designated initializer
	/// - Parameter name: A `String` that represents the developer name
	init(name: String) {
		self.name = name

		Task {
			guard let image = await fetchImage() else { return }

			withAnimation(.smooth) {
				self.image = image
			}
		}
	}

	nonisolated
	private func fetchImage() async -> UIImage? {
		guard let url = URL(string: .githubImageURL) else { return nil }

		do {
			let (data, _) = try await URLSession.shared.data(from: url)
			return UIImage(data: data)
		}
		catch {
			print(error.localizedDescription)
		}

		return nil
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
