//
//  SubjectDetailsViewViewModel.swift
//  Iris
//
//  Created by Luki on 20/08/2024.
//

import UIKit

@MainActor
protocol SubjectDetailsViewViewModelDelegate: AnyObject {
	func didTapAssignmentsCell(for subject: Subject)
}

/// View model class for `SubjectDetailsView`
@MainActor
final class SubjectDetailsViewViewModel: NSObject {
	var title: String { return subject.name }

	weak var delegate: SubjectDetailsViewViewModelDelegate?

	// MARK: - UICollectionViewDiffableDataSource

	private struct Item: Hashable {
		let viewModel: AnyHashable
	}

	private struct Section: Hashable {
		fileprivate var viewModels: [Item]

		fileprivate
		static func createSubjectDetailsSection(for subject: Subject) -> Section {
			let examValues: [String]

			if subject.name == "Physiology" {
				examValues = ["R2", "R1", "Final"]
			}
			else if !subject.hasThreeExams {
				examValues = ["Primer parcial", "Segundo parcial", "Final"]
			}
			else {
				examValues = ["Primer parcial", "Segundo parcial", "Tercer parcial", "Final"]
			}

			return .init(viewModels: examValues.map { .init(viewModel: SubjectDetailsCellViewModel(exam: $0)) })
		}

		@MainActor
		fileprivate static var subjectDetails: Section = .init(viewModels: [])

		fileprivate
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
	/// - Parameter subject: The `Subject` object
	init(subject: Subject) {
		self.subject = subject

		Section.subjectDetails = .createSubjectDetailsSection(for: subject)
		sections = [.subjectDetails, .assignments]
	}

	private func examGradeKey(for index: Int) -> String {
		switch index {
			case 0: return "FirstExamGrade"
			case 1: return "SecondExamGrade"
			case 2: return subject.hasThreeExams ? "ThirdExamGrade" : "FinalExamGrade"
			case 3: return "FinalExamGrade"
			default: return ""
		}
	}
}

// MARK: - UICollectionView

extension SubjectDetailsViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupCollectionViewDiffableDataSource(for collectionView: UICollectionView) {
		dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
			guard let self else { fatalError() }

			let examGradeKey = examGradeKey(for: indexPath.item)

			switch sections[indexPath.section] {
				case .subjectDetails:
					guard var viewModel = item.viewModel as? SubjectDetailsCellViewModel else { fatalError() }

					let cell = collectionView.dequeueConfiguredReusableCell(
						using: subjectDetailsCellRegistration,
						for: indexPath,
						item: viewModel
					)

					let subjectName = subject.name.components(separatedBy: .whitespaces).joined()

					if viewModel.exam == "Final" {
						viewModel.isFinalCell = true
						cell.finalExamDatePicker.date = subject.finalExamDate
						cell.onSelectedExamDate = { finalExamDate in
							self.subject.finalExamDate = finalExamDate
						}
					}

					cell.onGradeChange = { text in
						if viewModel.exam == "Final" {
							guard !text.isEmpty else {
								self.subject.grades.removeAll()
								return
							}

							guard let grade = Int(text) else { return }
							self.subject.grades.append(grade)
						}

						UserDefaults.standard.set(text, forKey: subjectName + " - " + examGradeKey)
					}

					cell.configure(with: viewModel)
					cell.gradeTextField.text = UserDefaults.standard.string(forKey: subjectName + " - " + examGradeKey)
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
		snapshot.appendSections(sections)
		sections.forEach { snapshot.appendItems($0.viewModels, toSection: $0) }
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
