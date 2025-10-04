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
	let shortName: String
	let examGrades: [Int]
	let finalGrades: [Int]
	let isFinished: Bool
	let hasThreeExams: Bool
	let finalExamDates: [String]
}
