//
//  SubjectDetailsViewViewModel.swift
//  Iris
//
//  Created by Luki on 20/08/2024.
//

import UIKit

protocol SubjectDetailsViewViewModelDelegate: AnyObject {
	func didTapAssignmentsCell(for subject: Subject)
}

/// View model class for SubjectDetailsView
final class SubjectDetailsViewViewModel: NSObject {

	var title: String { return subject.name }

	weak var delegate: SubjectDetailsViewViewModelDelegate?

	// MARK: - UICollectionViewDiffableDataSource

	private struct Item: Hashable {
		let viewModel: AnyHashable
	}

	private struct Section: Hashable {
		var viewModels: [Item]

		static func createSubjectDetailsSection(for subject: Subject) -> Section {
			let examValues: [String]

			if subject.name == "Physiology" {
				examValues = ["R2", "R1", "Final"]
			}
			else {
				examValues = ["Primer parcial", "Segundo parcial", "Final"]
			}

			return .init(viewModels: examValues.map { .init(viewModel: SubjectDetailsCellViewModel(exam: $0)) })
		}

		static var subjectDetails: Section = .init(viewModels: [])
		static let assignments: Section = .init(
			viewModels: [.init(viewModel: SubjectDetailsAssignmentsCellViewModel(title: "Assignments"))]
		)
	}

	private var sections = [Section]()

	private typealias SubjectDetailsCellRegistration = UICollectionView.CellRegistration<SubjectDetailsCell, SubjectDetailsCellViewModel>
	private typealias SubjectDetailsAssignmentsCellRegistration = UICollectionView.CellRegistration<SubjectDetailsAssignmentsCell, SubjectDetailsAssignmentsCellViewModel>

	private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
	private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

	private var dataSource: DataSource!

	private let subjectDetailsCellRegistration = SubjectDetailsCellRegistration { cell, _, viewModel in
		cell.configure(with: viewModel)
	}

	private let subjectDetailsAssignmentsCellRegistration = SubjectDetailsAssignmentsCellRegistration { cell, _, viewModel in
		cell.configure(with: viewModel)
	}

	private let subject: Subject

	/// Designated initializer
	/// - Parameters:
	/// 	- subject: The subject
	init(subject: Subject) {
		self.subject = subject

		Section.subjectDetails = .createSubjectDetailsSection(for: subject)
		sections = [.subjectDetails, .assignments]
	}

}

// MARK: - UICollectionView

extension SubjectDetailsViewViewModel {

	/// Function to setup the collection view's diffable data source
	/// - Parameters:
	///		- collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
			guard let self else { fatalError() }

			var examKey = ""

			switch indexPath.item {
				case 0: examKey = "FirstExamGrade"
				case 1: examKey = "SecondExamGrade"
				case 2: examKey = subject.hasThreeExams ? "ThirdExamGrade" : "FinalExamGrade"
				case 3: examKey = subject.hasThreeExams ? "FinalExamGrade" : ""
				default: break
			}

			switch sections[indexPath.section] {
				case .subjectDetails:
					guard let viewModel = item.viewModel as? SubjectDetailsCellViewModel else { fatalError() }

					let cell = collectionView.dequeueConfiguredReusableCell(
						using: subjectDetailsCellRegistration,
						for: indexPath,
						item: viewModel
					)
					cell.id = subject.name.lowercased().components(separatedBy: .whitespaces).joined() + examKey
					cell.configure(with: viewModel)
					cell.completion = { text in
						if self.subject.hasThreeExams && indexPath.item == 3 {
							self.subject.grade = Int(text)
						}
						else if indexPath.item == 2 {
							self.subject.grade = Int(text)
						}
					}
					cell.gradeTextField.text = UserDefaults.standard.string(forKey: cell.id)
					return cell

				case .assignments:
					guard let viewModel = item.viewModel as? SubjectDetailsAssignmentsCellViewModel else { fatalError() }


					let cell = collectionView.dequeueConfiguredReusableCell(
						using: subjectDetailsAssignmentsCellRegistration,
						for: indexPath,
						item: viewModel
					)
					cell.configure(with: viewModel)
					return cell

				default: fatalError()
			}
		}
		applyDiffableDataSourceSnapshot()
	}

	private func applyDiffableDataSourceSnapshot() {
		var snapshot = Snapshot()

		var updatedSections: [Section] = [.subjectDetails, .assignments]
		if subject.hasThreeExams {
			updatedSections[0].viewModels.insert(.init(viewModel: SubjectDetailsCellViewModel(exam: "Tercer parcial")), at: 2)
		}
		snapshot.appendSections(updatedSections)
		updatedSections.forEach { snapshot.appendItems($0.viewModels, toSection: $0) }
		dataSource.apply(snapshot)
	}

}

extension SubjectDetailsViewViewModel: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		switch sections[indexPath.section] {
			case .assignments: delegate?.didTapAssignmentsCell(for: subject)
			default: break
		}
	}
}
