import SwiftUI

struct AppLogo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.crimsonSoft)
                .frame(width: 72, height: 72)

            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 38))
                .foregroundStyle(AppTheme.crimson)
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(AppTheme.crimson)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(AppTheme.crimson)
            .background(AppTheme.crimsonSoft)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
}

struct StatusBadge: View {
    let status: String

    private var color: Color {
        switch status {
        case "Approved", "Claim Approved":
            return AppTheme.success
        case "Rejected", "Claim Rejected":
            return .red
        case "Claimed", "Returned":
            return .blue
        default:
            return AppTheme.crimson
        }
    }

    var body: some View {
        Text(status)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search items"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.secondaryText)

            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .padding(13)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct FilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selected ? .white : AppTheme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    selected
                    ? AppTheme.crimson
                    : AppTheme.card
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.crimson)

                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.crimson)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.bold())
                .tracking(1)
                .foregroundStyle(AppTheme.secondaryText)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

struct SettingsRow: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(
                        destructive ? .red : AppTheme.crimson
                    )
                    .frame(width: 25)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .foregroundStyle(
                            destructive ? .red : .white
                        )

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundStyle(AppTheme.crimson)

            Text(title)
                .font(.headline.bold())
                .foregroundStyle(.white)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct ItemCard: View {
    let item: LostFoundItem
    var reporterName: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Group {
                    if let data = item.photoData,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: item.type == .lost
                              ? "magnifyingglass"
                              : "shippingbox.fill")
                            .font(.system(size: 25))
                            .foregroundStyle(AppTheme.crimson)
                    }
                }
                .frame(width: 75, height: 75)
                .background(AppTheme.crimsonSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(item.itemName)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Spacer()

                        StatusBadge(status: item.status.rawValue)
                    }

                    Text("\(item.type.rawValue) • \(item.displayCategory)")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryPrimaryText)

                    HStack(spacing: 12) {
                        Label(item.location, systemImage: "mappin")
                        Label(
                            item.date.formatted(
                                date: .abbreviated,
                                time: .omitted
                            ),
                            systemImage: "calendar"
                        )
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)

                    if let reporterName {
                        Text("Reported by \(reporterName)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            }
            .padding(14)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}