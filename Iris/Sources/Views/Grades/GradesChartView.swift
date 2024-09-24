import Charts
import SwiftUI

/// Grades chart view
struct GradesChartView: View {
	@State private var subjectManager = SubjectsManager.shared
	@State private var tappedGrade = 0

	var body: some View {
		if !subjectManager.passedSubjects.isEmpty {
			ScrollView {
				Chart(subjectManager.passedSubjects) { subject in
					LineMark(
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
					)
					.foregroundStyle(Color.purple.gradient)
					.symbol(.circle)

					PointMark(
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
					)
					.opacity(0)
					.annotation {
						if tappedGrade == subject.grade {
							if let grade = subject.grade {
								Text(String(describing: grade))
							}
						}
					}

					AreaMark(
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grade ?? 0)
					)
					.foregroundStyle(
						Gradient(colors: [Color(.irisSlateBlue), Color(.irisSlateBlue).opacity(0.1)])
					)
				}
				.chartOverlay { chartProxy in
					GeometryReader { _ in
						Color.clear
							.contentShape(.rect)
							.onTapGesture { location in
								guard let (_, grade) = chartProxy.value(at: location, as: (String, Int).self) else { return }
								tappedGrade = grade
							}
					}
				}
				.chartXAxis {
					AxisMarks {
						AxisGridLine()
						AxisValueLabel()
							.font(.quicksand(withStyle: .medium, size: 10))
					}
				}
				.chartYAxis {
					AxisMarks {
						AxisGridLine()
						AxisValueLabel()
							.font(.quicksand(withStyle: .medium, size: 10))
					}
				}
				.chartYScale(domain: 0...10)
				.frame(height: 150)
				.padding()

				let averageDouble: Double = subjectManager.passedSubjects.average(\.grade)

				Text(String(describing: "Average: " + String(format: "%.1f", averageDouble)))
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
}

private extension Collection {
	func average<F: BinaryFloatingPoint, T: BinaryInteger>(_ predicate: (Element) -> T?) -> F {
		let values = self.compactMap(predicate)
		guard !values.isEmpty else { return F.zero }
		return F(values.reduce(.zero) { $0 + F($1) }) / F(count)
	}
}

extension Font {
	static func quicksand(withStyle style: UIFont.QuicksandStyle, size: CGFloat = 16) -> Font {
		return Font(UIFont.quicksand(withStyle: style, size: size))
	}
}

#Preview {
	GradesChartView()
}
