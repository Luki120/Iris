//
//  DeveloperCellViewViewModel.swift
//  Iris
//
//  Created by Luki on 19/09/2024.
//

import Foundation
import UIKit.UIImage
import func SwiftUI.withAnimation

/// View model class for DeveloperCellView
@Observable
final class DeveloperCellViewViewModel {
	@ObservationIgnored
	let name: String

	private(set) var image = UIImage()

	/// Designated initializer
	/// - Parameters:
	/// 	- name: A string that represents the developer name
	init(name: String) {
		self.name = name
		fetchImage()
	}

	private func fetchImage() {
		Task.detached(priority: .background) {
			guard let url = URL(string: .githubImageURL) else { return }

			do {
				let (data, _) = try await URLSession.shared.data(from: url)

				await MainActor.run {
					withAnimation(.smooth) {
						guard let image = UIImage(data: data) else { return }
						self.image = image
					}
				}
			}
			catch {
				print(error.localizedDescription)
			}
		}
	}

}

// MARK: - Hashable

extension DeveloperCellViewViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}

	static func == (lhs: DeveloperCellViewViewModel, rhs: DeveloperCellViewViewModel) -> Bool {
		return lhs.name == rhs.name
	}
}
