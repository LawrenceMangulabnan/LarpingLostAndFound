import SwiftUI
import UIKit

struct AppButton: View {
    let title: String
    var enabled: Bool = true
    var loading: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(loading ? "Please wait…" : title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(enabled ? .white : AppColors.label3)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(enabled ? AppColors.red : AppColors.cardHi)
                .clipShape(RoundedRectangle(cornerRadius: AppMetrics.buttonRadius, style: .continuous))
                .shadow(color: enabled ? AppColors.red.opacity(0.33) : .clear, radius: 12, y: 4)
        }
        .disabled(!enabled || loading)
        .buttonStyle(.plain)
    }
}

struct GhostButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppColors.card)
                .overlay(RoundedRectangle(cornerRadius: AppMetrics.buttonRadius).stroke(AppColors.red.opacity(0.2), lineWidth: 1.5))
                .clipShape(RoundedRectangle(cornerRadius: AppMetrics.buttonRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    let text: String
    var body: some View {
        let style = StatusStyle.style(for: text)
        HStack(spacing: 4) {
            Circle().fill(style.dot).frame(width: 5, height: 5)
            Text(text).font(.system(size: 11, weight: .semibold)).foregroundStyle(style.text)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(style.bg)
        .clipShape(Capsule())
    }
}

enum StatusStyle {
    case pending, approved, claimed, returned, rejected, other
    var bg: Color {
        switch self {
        case .pending: return AppColors.orangeLight
        case .approved, .claimed: return AppColors.blueLight
        case .returned: return AppColors.purpleLight
        case .rejected: return AppColors.redLight
        case .other: return AppColors.greenLight
        }
    }
    var text: Color {
        switch self {
        case .pending: return AppColors.orange
        case .approved, .claimed: return AppColors.blue
        case .returned: return AppColors.purple
        case .rejected: return AppColors.red
        case .other: return AppColors.green
        }
    }
    var dot: Color { text }
    static func style(for text: String) -> StatusStyle {
        if text.contains("Pending") { return .pending }
        if text == "Returned" { return .returned }
        if text.contains("Reject") { return .rejected }
        if text.contains("Claimed") || text == "Approved" { return .approved }
        if text == "Found" { return .other }
        return .other
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder = "Search items…"
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppColors.label3)
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.placeholder))
                .foregroundStyle(AppColors.label)
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 20, height: 20).background(AppColors.label3).clipShape(Circle())
                }
                .accessibilityLabel("Clear")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.cardHi)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct CapsuleSegment<T: Hashable>: View {
    let options: [(T, String)]
    @Binding var value: T
    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.0) { option in
                Button {
                    value = option.0
                } label: {
                    Text(option.1)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(value == option.0 ? AppColors.label : AppColors.label3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(value == option.0 ? AppColors.card : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(AppColors.cardHi)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    var color: Color = AppColors.red
    var bg: Color = AppColors.redLight
    var action: (() -> Void)?
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 2) {
                Text("\(value)").font(.system(size: 22, weight: .black)).foregroundStyle(color)
                Text(title).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.label3).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .opacity(1)
    }
}

struct SettingsRow: View {
    let title: String
    var icon: String = ""
    var value: String?
    var destructive = false
    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty { Text(icon).frame(width: 24) }
            Text(title).font(.system(size: 15)).foregroundStyle(destructive ? AppColors.red : AppColors.label)
            Spacer()
            if let value { Text(value).foregroundStyle(AppColors.label3).font(.system(size: 15)) }
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase).padding(.horizontal, 4)
            VStack(spacing: 0) { content }
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 6, y: 1)
        }
    }
}

struct LabeledField: View {
    let label: String
    var placeholder: String
    @Binding var text: String
    var error: String? = nil
    var secure = false
    var showSecure = false
    var onToggle: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.label3).textCase(.uppercase)
            HStack {
                Group {
                    if secure && !showSecure { SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.placeholder)) }
                    else { TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.placeholder)) }
                }
                .foregroundStyle(AppColors.label)
                .textInputAutocapitalization(.never)
                if secure, let onToggle {
                    Button(showSecure ? "Hide" : "Show", action: onToggle)
                        .font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.label3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(AppColors.card)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(error == nil ? AppColors.sep : AppColors.red, lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if let error { Text("⚠ \(error)").font(.system(size: 12)).foregroundStyle(AppColors.red) }
        }
    }
}

struct AvatarView: View {
    let user: User
    var size: CGFloat = 68
    var body: some View {
        Group {
            if let data = user.profilePhotoData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Text(user.initials).font(.system(size: size * 0.35, weight: .black)).foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .background(LinearGradient(colors: [AppColors.redDark, AppColors.red], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(Circle())
        .shadow(color: AppColors.red.opacity(0.33), radius: 8, y: 4)
    }
}

struct EmptyState: View {
    let emoji: String
    let title: String
    var button: String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 48))
            Text(title).font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColors.label)
            if let button, let action {
                Button(action: action) {
                    Text(button).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(AppColors.red).clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

struct RolePicker: View {
    @Binding var role: UserRole
    var body: some View {
        HStack(spacing: 10) {
            ForEach(UserRole.allCases) { option in
                Button {
                    role = option
                } label: {
                    VStack(spacing: 6) {
                        Text(option.emoji).font(.system(size: 24))
                        Text(option.shortLabel).font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(role == option ? .white : AppColors.label3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(role == option ? AppColors.red : AppColors.card)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(role == option ? AppColors.red : AppColors.sep, lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: role == option ? AppColors.red.opacity(0.27) : .clear, radius: 10, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct BrandMark: View {
    var size: CGFloat = 56
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous).fill(AppColors.red)
            Image(systemName: "checkmark.shield.fill").font(.system(size: size * 0.42)).foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: AppColors.red.opacity(0.4), radius: 10, y: 4)
    }
}
