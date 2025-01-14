//
//  PomodoroTimerView.swift
//  Iris
//
//  Created by Luki on 01/10/2024.
//

import SwiftUI

/// View that'll show a pomodoro timer
struct PomodoroTimerView: View {
	@State private var viewModel = PomodoroTimerViewViewModel()
	@Environment(\.colorScheme) private var colorScheme

	var body: some View {
		VStack(spacing: 15) {
			ProgressView()
				.frame(maxWidth: .infinity, maxHeight: 630)

			TimerButtons()
				.padding()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(colorScheme == .dark ? Color.irisBackground : .white)
		.overlay {
			ZStack {
				Color.black
					.ignoresSafeArea(edges: .top)
					.opacity(viewModel.createNewTimer ? 0.25 : 0.0)
					.onTapGesture {
						viewModel.createNewTimer = false
					}

				NewTimerView()
					.frame(maxHeight: .infinity, alignment: .bottom)
					.offset(y: viewModel.createNewTimer ? 0 : 400)
			}
			.animation(.easeInOut, value: viewModel.createNewTimer)
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			viewModel.onBackground()
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
			viewModel.onForeground()
		}
		.onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
			if viewModel.timerState == .active(isPaused: false) {
				viewModel.updateTimer()
			}
		}
	}

	@ViewBuilder
	private func ProgressView() -> some View {
		ZStack {
			if colorScheme == .dark {
				Circle()
					.stroke(
						Color.irisSlateBlue,
						style: StrokeStyle(
							lineWidth: 5,
							lineCap: .round,
							lineJoin: .round
						)
					)
					.blur(radius: 15)
					.padding(-2)

				Circle()
					.fill(Color.irisBackground)
			}
			else {
				Circle()
					.stroke(gradient, lineWidth: 30)
					.opacity(0.5)
			}

			Group {
				if colorScheme == .dark {
					CircleView(Color.irisSlateBlue)
				}
				else {
					CircleView(gradient)
						.shadow(color: .irisSlateBlue, radius: 5, x: 1, y: -4)
				}
			}
			.rotationEffect(.degrees(-90))
			.animation(.linear(duration: 1), value: viewModel.progress)

			VStack(spacing: 10) {
				Text(viewModel.totalTime, format: .time(pattern: .minuteSecond))
					.contentTransition(.numericText())
					.font(.quicksand(withStyle: .semiBold, size: 45))

				Text(viewModel.session.rawValue)
					.font(.quicksand(withStyle: .medium, size: 18))
			}
		}
		.animation(.smooth, value: viewModel.progress)
		.padding(45)
	}

	@ViewBuilder
	private func TimerButtons() -> some View {
		HStack(spacing: 20) {
			TimerButton(
				symbol: viewModel.timerState != .active(isPaused: false) ? "play.fill" : "pause"
			) {
				if viewModel.timerState == .active(isPaused: false) {
					viewModel.pauseTimer()
				}
				else {
					viewModel.resumeTimer()
				}
			}
			.disabled(viewModel.timerState == .inactive)
			.opacity(viewModel.timerState == .inactive ? 0.5 : 1)

			TimerButton(
				symbol: viewModel.timerState != .inactive ? "stop.fill" : "timer"
			) {
				if viewModel.timerState != .inactive {
					viewModel.stopTimer()
				}
				else {
					viewModel.createNewTimer.toggle()
				}
			}
		}
		.padding()
	}

	@ViewBuilder
	private func TimerButton(
		symbol: String,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			Image(systemName: symbol)
				.contentTransition(.symbolEffect(.replace, options: .speed(1.5)))
				.font(.largeTitle.bold())
				.foregroundStyle(.white)
				.frame(width: 80, height: 80)
				.background(Color.irisSlateBlue, in: .circle)
				.shadow(color: .irisSlateBlue, radius: 8)
		}
	}

	@ViewBuilder
	private func NewTimerView() -> some View {
		VStack(spacing: 15) {
			Text("Start new Pomodoro session")
				.font(.quicksand(withStyle: .medium, size: 20))
				.foregroundStyle(Color.primary)
				.padding(.top, 5)

			HStack {
				Group {
					Button("\(viewModel.minutes) min") {
						viewModel.showAlert.toggle()
					}
					.id(String(describing: viewModel.minutes) + "minutes")
					.minimumScaleFactor(0.8)
				}
				.foregroundStyle(.gray)
				.padding()
				.frame(width: 120, height: 50)
				.background(
					colorScheme == .dark ? Color.white.opacity(0.070) : Color.black.opacity(0.070),
					in: .capsule
				)
				.transition(.blurReplace.animation(.smooth))
			}

			Button("Confirm") {
				viewModel.startTimer()
			}
			.disabled(viewModel.minutes == 0)
			.font(.quicksand(withStyle: .semiBold, size: 18))
			.foregroundStyle(.primary)
			.opacity(viewModel.minutes == 0 ? 0.5 : 1)
			.padding(.horizontal, 35)
			.padding(.vertical)
			.background(Color.irisSlateBlue, in: .capsule)
		}
		.alert("Iris", isPresented: $viewModel.showAlert) {
			TextField("60m", value: $viewModel.minutes, format: .number)
				.keyboardType(.numberPad)

			TextField("20m break", value: $viewModel.breakMinutes, format: .number)
				.keyboardType(.numberPad)

			Button("Confirm") {}
			Button("Cancel") {}
		} message: {
			Text("Start a new pomodoro session with a given interval")
		}
		.padding()
		.frame(height: 220)
		.frame(maxWidth: .infinity)
		.background(
			colorScheme == .dark ? Color.irisBackground : .white,
			in: CustomCornersShape(radius: 15)
		)
	}

	@ViewBuilder
	private func CircleView<S: ShapeStyle>(_ shapeStyle: S) -> some View {
		Circle()
			.trim(from: 0, to: viewModel.progress)
			.stroke(
				shapeStyle,
				style: StrokeStyle(
					lineWidth: 30,
					lineCap: .round,
					lineJoin: .round
				)
			)
	}

	private var gradient: LinearGradient {
		return .init(
			colors: [
				.irisSlateBlue,
				.irisSlateBlue.opacity(0.5),
				.irisSlateBlue.opacity(0.3),
				.irisSlateBlue.opacity(0.1),
			],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
	}
}

private extension Color {
	static let irisBackground = Color(red: 0.11, green: 0.10, blue: 0.16)
}

#Preview {
	PomodoroTimerView()
}
