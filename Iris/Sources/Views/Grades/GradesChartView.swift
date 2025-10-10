import Charts
import SwiftUI

/// Grades chart view
struct GradesChartView: View {
	@State private var subjectManager = SubjectsManager.shared
	@State private var tappedSubject = ""

	private var sortedSubjects: [Subject] {
		subjectManager.passedSubjects.sorted(using: SortDescriptor(\.finalExamDates.first))
	}

	var body: some View {
		if !subjectManager.passedSubjects.isEmpty {
			ScrollView {
				Chart(sortedSubjects) { subject in
					AreaMark(
						x: .value("Subjects", subject.shortName),
						y: .value("Grade", subject.finalGrades.first ?? 0)
					)
					.foregroundStyle(
						Gradient(
							colors: [
								.irisSlateBlue.opacity(0.8),
								.irisSlateBlue.opacity(0.2)
							]
						)
					)
					.interpolationMethod(.catmullRom)

					LineMark(
						x: .value("Subjects", subject.shortName),
						y: .value("Grade", subject.finalGrades.first ?? 0)
					)
					.foregroundStyle(Color.irisSlateBlue)
					.interpolationMethod(.catmullRom)
					.lineStyle(.init(lineWidth: 3, lineCap: .round))
					.symbol {
						Circle()
							.foregroundStyle(Color.irisSlateBlue)
							.frame(width: 8)
					}

					PointMark(
						x: .value("Subjects", subject.shortName),
						y: .value("Grade", subject.finalGrades.first ?? 0)
					)
					.annotation {
						if let grade = subject.finalGrades.first, tappedSubject == subject.shortName {
							Text(String(describing: grade))
						}
					}
					.opacity(0)
				}
				.chartGesture { proxy in
					SpatialTapGesture()
						.onEnded { value in
							if let (subjectName, _) = proxy.value(at: value.location, as: (String, Int).self),
							   let subject = sortedSubjects.first(where: { $0.shortName == subjectName }) {
								withAnimation(.easeInOut(duration: 0.25)) {
									tappedSubject = subject.shortName
								}
							}
							else {
								tappedSubject = ""
							}
						}
				}
				.chartScrollableAxes(.horizontal)
				.chartXVisibleDomain(length: 5)
				.chartXAxis {
					GradesAxisContent()
				}
				.chartYAxis {
					GradesAxisContent()
				}
				.chartYScale(domain: 0...10)
				.frame(height: 150)
				.padding()

				let gradesAverage: Double = subjectManager.passedSubjects
					.filter { $0.shortName != "Micro" }
					.flatMap(\.finalGrades)
					.average { $0 }

				VStack(alignment: .leading, spacing: 15) {
					Text(String(describing: "Average: " + String(describing: gradesAverage)))

					NavigationLink("View all grades") {
						AllGradesView(subjects: sortedSubjects, subjectManager: subjectManager)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
			}
			.padding()
		}
		else {
			ContentUnavailableView {
				Text("There's currently no grades data")
					.font(.quicksand())
			}
		}
	}

	@AxisContentBuilder
	private func GradesAxisContent() -> some AxisContent {
		AxisMarks {
			AxisGridLine()
			AxisValueLabel()
				.font(.quicksand(size: 10))
		}
	}
}

private extension Collection {
	func average<F: BinaryFloatingPoint, T: BinaryInteger>(_ predicate: (Element) -> T?) -> F {
		let values = self.compactMap(predicate)
		guard !values.isEmpty else { return F.zero }
		let average = F(values.reduce(.zero) { $0 + F($1) }) / F(values.count)

		let multiplier = F(pow(10.0, 1.0))
		return (average * multiplier).rounded() / multiplier
	}
}

#Preview {
	GradesChartView()
}
