import SwiftUI

struct RateAppScreen: View {
    @EnvironmentObject private var app: AppController
    @State private var rating = 0
    @State private var feedback = ""
    @State private var submitted = false
    var body: some View {
        Form {
            Section("How was your experience?") {
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button { rating = star } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star").font(.title2).foregroundStyle(.yellow)
                        }.buttonStyle(.plain).accessibilityLabel("\(star) stars")
                    }
                }.disabled(submitted)
                TextField("Optional feedback", text: $feedback, axis: .vertical).lineLimit(3...6).disabled(submitted)
                AppButton(title: submitted ? "Rating Submitted" : "Submit Rating") {
                    guard rating > 0 else { app.errorMessage = "Select at least one star."; return }
                    submitted = true
                    app.successMessage = "Thank you for your \(rating)-star rating! Your feedback was recorded for this screen session only."
                }.disabled(submitted)
            }
        }.appBackground().navigationTitle("Rate the App")
    }
}
