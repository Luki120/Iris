import Charts
import SwiftUI

/// Grades chart view
struct GradesChartView: View {
	@State private var subjectManager = SubjectsManager.shared
	@State private var tappedGrade = 0

	var body: some View {
		if !subjectManager.passedSubjects.isEmpty {
			ScrollView {
				Chart(
					subjectManager.passedSubjects.sorted(using: SortDescriptor(\.finalExamDate))
				) { subject in
					AreaMark(
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
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
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
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
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
					)
					.annotation {
						if let grade = subject.grade, tappedGrade == grade {
							Text(String(describing: grade))
						}
					}
					.opacity(0)
				}
				.chartOverlay { chartProxy in
					GeometryReader { _ in
						Color.clear
							.contentShape(.rect)
							.onTapGesture { location in
								guard let (_, grade) = chartProxy.value(at: location, as: (String, Int).self) else {
									return
								}
								withAnimation(.easeInOut(duration: 0.25)) {
									tappedGrade = grade
								}
							}
					}
				}
				.chartXAxis {
					GradesAxisContent()
				}
				.chartYAxis {
					GradesAxisContent()
				}
				.chartYScale(domain: 0...10)
				.frame(height: 150)
				.padding()

				let gradesAverage: Double = subjectManager.passedSubjects.average(\.grade)

				Text(String(describing: "Average: " + String(describing: gradesAverage)))
					.font(.quicksand(withStyle: .medium))
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
			}
			.padding()
		}
		else {
			ContentUnavailableView {
				Text("There's currently no grades data")
					.font(.quicksand(withStyle: .medium))
			}
		}
	}

	@AxisContentBuilder
	private func GradesAxisContent() -> some AxisContent {
		AxisMarks {
			AxisGridLine()
			AxisValueLabel()
				.font(.quicksand(withStyle: .medium, size: 10))
		}
	}
}

private extension Collection {
	func average<F: BinaryFloatingPoint, T: BinaryInteger>(_ predicate: (Element) -> T?) -> F {
		let values = self.compactMap(predicate)
		guard !values.isEmpty else { return F.zero }
		return F(values.reduce(.zero) { $0 + F($1) }) / F(count)
	}
}

#Preview {
	GradesChartView()
}
