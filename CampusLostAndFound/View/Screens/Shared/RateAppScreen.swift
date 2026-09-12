import SwiftUI

struct RateAppScreen: View {
    @EnvironmentObject private var app: AppController
    @Environment(\.dismiss) private var dismiss
    @State private var stars = 0
    @State private var feedback = ""
    @State private var submitted = false
    var body: some View {
        ScrollView {
            if submitted {
                VStack(spacing: 20) {
                    Spacer()
                    Text("⭐").font(.system(size: 44))
                    Text("Thank you!").font(.system(size: 26, weight: .black)).foregroundStyle(AppColors.label)
                    Text(stars >= 4 ? "Thanks for your positive feedback! We love hearing from you." : "We're sorry the experience wasn't perfect. Your feedback helps us improve.")
                        .foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
                    AppButton(title: "Done") { dismiss() }
                    Spacer()
                }.padding(32)
            } else {
                VStack(spacing: 24) {
                    Text("Enjoying Campus Lost & Found?").font(.system(size: 22, weight: .black)).foregroundStyle(AppColors.label).multilineTextAlignment(.center)
                    Text("How would you rate your experience?").foregroundStyle(AppColors.label3)
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Button { stars = star } label: {
                                Text(star <= stars ? "⭐" : "☆").font(.system(size: 44))
                            }.buttonStyle(.plain).accessibilityLabel("\(star) stars")
                        }
                    }
                    if stars > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Optional Feedback").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
                            TextField("", text: $feedback, prompt: Text("Tell us what you think…").foregroundStyle(AppColors.placeholder), axis: .vertical)
                                .foregroundStyle(AppColors.label).lineLimit(4...8)
                                .padding(16).background(AppColors.card).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    AppButton(title: "Submit Rating", enabled: stars > 0) {
                        app.submitRating(stars: stars, feedback: feedback)
                        submitted = true
                    }
                }.padding(16).padding(.top, 24)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Rate the App")
    }
}
