//
//  SettingsFooterView.swift
//  Iris
//
//  Created by Luki on 20/09/2024.
//

import SwiftUI

/// View that'll show the settings footer view
struct SettingsFooterView: View {
	private let viewModel = SettingsFooterViewViewModel()

	@ScaledMetric private var imageHeight = 25

	var body: some View {
		VStack(spacing: 15) {
			HStack {
				ForEach(viewModel.fundingPlatforms, id: \.rawValue) { platform in
					platform.image
						.resizable()
						.scaledToFit()
						.frame(height: imageHeight)
						.contentShape(.rect)
						.onTapGesture {
							UIApplication.shared.openURL(platform.url)
						}
				}
			}

			Text(viewModel.copyrightLabel)
				.font(.quicksand(size: 14))
				.foregroundStyle(.gray)
		}
		.padding(35)
	}
}

#Preview {
	SettingsVC()
}
