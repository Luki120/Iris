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

	@MainActor
	fileprivate struct Item {
		fileprivate let id = UUID()
		fileprivate let viewModel: AnyHashable
	}

	@MainActor
	private struct Section: Hashable {
		fileprivate let viewModels: [Item]

		@MainActor
		fileprivate static var subjectDetails: Section = .init(viewModels: [])

		fileprivate
		static let assignments: Section = .init(
			viewModels: [.init(viewModel: SubjectDetailsAssignmentsCellViewModel(title: "Assignments"))]
		)

		fileprivate
		static func createSubjectDetailsSection(for subject: Subject) -> Section {
			let exams = SubjectType(subject: subject).exams

			return Section(
				viewModels: exams.enumerated().map { index, exam in
					let isFinal = exam == "Final"
					let grade = isFinal ? subject.finalGrades.first ?? 0 : subject.examGrades.element(at: index)

					return Item(
						viewModel: SubjectDetailsCellViewModel(
							exam: exam,
							grade: grade,
							isFinalCell: isFinal,
							finalExamDate: subject.finalExamDate
						)
					)
				}
			)
		}
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
}

// MARK: - UICollectionView

extension SubjectDetailsViewViewModel {
	/// Function to setup the collection view's diffable data source
	/// - Parameter collectionView: The collection view
	func setupDiffableDataSource(for collectionView: UICollectionView) {
		dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
			guard let self else { fatalError() }
			let exams = SubjectType(subject: subject).exams

			switch sections[indexPath.section] {
				case .subjectDetails:
					guard let viewModel = item.viewModel as? SubjectDetailsCellViewModel else { fatalError() }

					let cell = collectionView.dequeueConfiguredReusableCell(
						using: subjectDetailsCellRegistration,
						for: indexPath,
						item: viewModel
					)

					if viewModel.isFinalCell {
						cell.onSelectedExamDate = { self.subject.finalExamDate = $0 }
					}

					cell.onGradeChange = { [self] text in
						let grade = Int(text.trimmingCharacters(in: .whitespaces)) ?? 0
						setGrade(grade, for: viewModel, at: exams.firstIndex(of: viewModel.exam))
					}

					cell.configure(with: viewModel)
					return cell

				case .assignments:
					guard let viewModel = item.viewModel as? SubjectDetailsAssignmentsCellViewModel
					else { fatalError() }

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
		applySnapshot()
	}

	private func applySnapshot() {
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

private extension SubjectDetailsViewViewModel {
	private func setGrade(_ grade: Int, for viewModel: SubjectDetailsCellViewModel, at index: Int?) {
		if viewModel.isFinalCell {
			subject.setFinalGrade(grade)
		}
		else if let index {
			subject.examGrades.set(grade, at: index)
		}

		SubjectsManager.shared.update(subject: subject)
	}
}

private extension Array where Element == Int {
	mutating func set(_ value: Int, at index: Int) {
		if index < count {
			self[index] = value
		}
		else {
			while count < index { append(0) }
			append(value)
		}
	}

	func element(at index: Int) -> Int {
		return indices.contains(index) ? self[index] : 0
	}
}

nonisolated extension SubjectDetailsViewViewModel.Item: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	static func == (lhs: SubjectDetailsViewViewModel.Item, rhs: SubjectDetailsViewViewModel.Item) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
}
