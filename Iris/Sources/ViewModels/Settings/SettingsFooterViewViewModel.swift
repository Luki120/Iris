//
//  SettingsFooterViewViewModel.swift
//  Iris
//
//  Created by Luki on 21/09/2024.
//

import Foundation
import struct SwiftUI.Image
import class UIKit.UIApplication

/// View model struct for `SettingsFooterView`
struct SettingsFooterViewViewModel {
	let fundingPlatforms = FundingPlatform.allCases
	let copyrightLabel = "© 2024-\(Date.now.formatted(.dateTime.year())) Luki120"

	/// Enum to represent each funding platform for the funding cell
	enum FundingPlatform: String, CaseIterable {
		case kofi = "Ko-fi"
		case paypal = "PayPal"

		var name: String { rawValue }

		var image: Image {
			switch self {
				case .kofi: return Image(.kofi)
				case .paypal: return Image(.payPal)
			}
		}

		var url: URL? {
			switch self {
				case .kofi: return URL(string: "https://ko-fi.com/Luki120")
				case .paypal: return URL(string: "https://paypal.me/Luki120")
			}
		}
	}
}
