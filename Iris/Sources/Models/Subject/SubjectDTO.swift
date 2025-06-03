//
//  SubjectDTO.swift
//  Iris
//
//  Created by Luki on 02/06/2025.
//

/// API model struct
struct SubjectDTO: Codable {
	let name: String
	let year: String
	let grades: [Int]
	let isFinished: Bool
	let hasThreeExams: Bool
	let finalExamDate: String
}
