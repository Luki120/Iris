import Charts
import SwiftUI

/// Grades chart view
struct GradesChartView: View {
	@State private var subjectManager = SubjectsManager.shared
	@State private var newGrades = [NewGrade]()
	@State private var showSheet = false
	@State private var tappedGrade = 0

	private var sortedSubjects: [Subject] {
		subjectManager.passedSubjects.sorted(using: SortDescriptor(\.finalExamDate))
	}

	private struct NewGrade {
		let subject: Subject
		let value: Int
	}

	var body: some View {
		if !subjectManager.passedSubjects.isEmpty {
			ScrollView {
				Chart(sortedSubjects) { subject in
					AreaMark(
						x: .value("Subjects", subject.name),
						y: .value("Grade", subject.grades.first ?? 0)
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
						y: .value("Grade", subject.grades.first ?? 0)
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
						y: .value("Grade", subject.grades.first ?? 0)
					)
					.annotation {
						if let grade = subject.grades.first, tappedGrade == grade {
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

				let gradesAverage: Double = subjectManager.passedSubjects
					.flatMap(\.grades)
					.average { $0 }

				VStack(alignment: .leading, spacing: 15) {
					Text(String(describing: "Average: " + String(describing: gradesAverage)))

					Button("Add new grade") {
						showSheet.toggle()
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
				.workingSheet(
					isPresented: $showSheet,
					onDismiss: { newGrades.removeAll() }
				) {
					AddNewGradeView()
				}
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

	@ViewBuilder
	private func AddNewGradeView() -> some View {
		VStack(spacing: 20) {
			List(sortedSubjects) { subject in
				HStack {
					Text(subject.name)
					Spacer()

					if let latestGrade = newGrades.last(where: { $0.subject.name == subject.name })?.value {
						Text(String(describing: latestGrade))
					}

					Menu {
						ForEach(1...10, id: \.self) { grade in
							Button {
								if let subject = subjectManager.passedSubjects.first(
									where: { $0.name == subject.name }
								) {
									newGrades.append(.init(subject: subject, value: grade))
								}
							} label: {
								HStack {
									Text(String(describing: grade))

									if newGrades.last(where: { $0.subject.name == subject.name })?.value == grade {
										Image(systemName: "checkmark")
									}
								}
							}
						}
					} label: {
						Image(systemName: "chevron.up.chevron.down")
							.font(.title3)
					}
				}
			}
			.padding()

			Button("Confirm") {
				withAnimation(.snappy) {
					newGrades.forEach {
						$0.subject.grades.append($0.value)
					}
					newGrades.removeAll()
				}
				showSheet = false
			}
			.disabled(newGrades.isEmpty)
			.foregroundStyle(.primary)
			.frame(width: 120, height: 50)
			.background(Color.irisSlateBlue, in: .capsule)
			.padding(.bottom, 20)
			.shadow(color: .irisSlateBlue, radius: 4)
			.opacity(newGrades.isEmpty ? 0.5 : 1)
			.animation(.easeInOut, value: newGrades.isEmpty)
		}
	}
}

// Using SwiftUI's sheet on 17+ doesn't respect medium detent so yeah 💀
private struct SheetView<Content: View>: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let onDismiss: (() -> Void)?
	let content: Content

	init(
		isPresented: Binding<Bool>,
		onDismiss: (() -> Void)? = nil,
		@ViewBuilder content: () -> Content
	) {
		self._isPresented = isPresented
		self.onDismiss = onDismiss
		self.content = content()
	}

	func makeUIViewController(context: Context) -> UIViewController {
		return .init()
	}

	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
		if isPresented {
			guard context.coordinator.hostingController == nil else {
				context.coordinator.hostingController?.rootView = content
				return
			}

			let hostingVC = UIHostingController(rootView: content)
			hostingVC.presentationController?.delegate = context.coordinator

			if let sheetVC = hostingVC.presentationController as? UISheetPresentationController {
				sheetVC.detents = [.medium(), .large()]
			}
			context.coordinator.hostingController = hostingVC
			uiViewController.present(hostingVC, animated: true)
		}
		else {
			uiViewController.dismiss(animated: true) {
				context.coordinator.hostingController = nil
			}
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(isPresented: $isPresented, onDismiss: onDismiss)
	}

	fileprivate
	final class Coordinator: NSObject, UISheetPresentationControllerDelegate {
		@Binding var isPresented: Bool
		fileprivate var hostingController: UIHostingController<Content>?
		fileprivate let onDismiss: (() -> Void)?

		init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) {
			self._isPresented = isPresented
			self.onDismiss = onDismiss
		}

		func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
			isPresented = false
			hostingController = nil

			guard let onDismiss else { return }
			onDismiss()
		}
	}
}

private struct SheetModifier<SheetContent: View>: ViewModifier {
	@Binding var isPresented: Bool
	let onDismiss: (() -> Void)?
	let sheetContent: SheetContent

	init(
		isPresented: Binding<Bool>,
		onDismiss: (() -> Void)? = nil,
		sheetContent: () -> SheetContent
	) {
		self._isPresented = isPresented
		self.onDismiss = onDismiss
		self.sheetContent = sheetContent()
	}

	func body(content: Content) -> some View {
		ZStack {
			SheetView(isPresented: $isPresented, onDismiss: onDismiss) {
				sheetContent
			}
			content
		}
	}
}

private extension View {
	func workingSheet<Content: View>(
		isPresented: Binding<Bool>,
		onDismiss: (() -> Void)?,
		content: @escaping () -> Content
	) -> some View {
		self
			.modifier(
				SheetModifier(
					isPresented: isPresented,
					onDismiss: onDismiss,
					sheetContent: content
				)
			)
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
