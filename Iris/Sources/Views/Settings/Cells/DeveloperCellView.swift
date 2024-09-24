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

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Image(uiImage: viewModel.image)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 40, height: 40)
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
