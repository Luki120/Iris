//
//  SubjectDetailsCellViewModel.swift
//  Iris
//
//  Created by Luki on 07/09/2024.
//

import protocol Swift.Hashable

/// View model struct for `SubjectDetailsCell`
struct SubjectDetailsCellViewModel: Hashable {
	let exam: String
	var isFinalCell = false
}
