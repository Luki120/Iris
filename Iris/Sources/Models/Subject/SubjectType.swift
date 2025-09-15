//
//  SubjectType.swift
//  Iris
//
//  Created by Luki on 30/07/2025.
//

/// Enum useful for mapping `Subject` data to UI elements
enum SubjectType {
	case hye, physiology, bioethics, twoExams, threeExams

	init(subject: Subject) {
		switch subject.name {
			case "HyE": self = .hye
			case "Physiology": self = .physiology
			case "Bioethics": self = .bioethics
			default: self = subject.hasThreeExams ? .threeExams : .twoExams
		}
	}

	var exams: [String] {
		switch self {
			case .hye: return ["Biología", "Genética", "Histología", "Embriología", "Final"]
			case .physiology: return ["R2", "R1", "Final"]
			case .bioethics: return ["Final"]
			case .twoExams: return ["Primer parcial", "Segundo parcial", "Final"]
			case .threeExams: return ["Primer parcial", "Segundo parcial", "Tercer parcial", "Final"]
		}
	}
}
