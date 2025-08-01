//
//  SubjectDetailsCellViewModel.swift
//  Iris
//
//  Created by Luki on 07/09/2024.
//

import protocol Swift.Hashable
import struct Foundation.Date

/// View model struct for `SubjectDetailsCell`
struct SubjectDetailsCellViewModel: Hashable {
	let exam: String
	let grade: Int
	let isFinalCell: Bool
	let finalExamDate: Date

	var displayedGrade: String {
		guard grade != 0 else { return "" }
		return String(describing: grade)
	}
}
