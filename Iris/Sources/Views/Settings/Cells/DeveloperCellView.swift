//
//  DeveloperCellView.swift
//  Iris
//
//  Created by Luki on 19/09/2024.
//

import SwiftUI

/// View that'll show a developer cell
struct DeveloperCellView: View {
	let viewModel: DeveloperCellViewViewModel

	@ScaledMetric private var imageHeight = 40

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Image(uiImage: viewModel.image)
					.resizable()
					.scaledToFit()
					.frame(height: imageHeight)
					.clipShape(.circle)

				Text(viewModel.name)
					.font(.quicksand(withStyle: .medium))
					.padding(.leading, 2.5)
			}
		}
	}
}

#Preview {
    SettingsVC()
}
