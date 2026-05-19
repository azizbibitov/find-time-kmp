import SwiftUI

struct NumberTimeCard: View {
    var timezone: String
    var time: String
    var hours: String
    var date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(timezone)
                    .font(.system(size: 16.0, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text(hours)
                    .lineLimit(1)
                    .font(.system(size: 13.0))
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 12).padding(.vertical, 14)
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(time)
                    .font(.system(size: 16.0, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text(date)
                    .lineLimit(1)
                    .font(.system(size: 11.0))
                    .foregroundStyle(.secondary)
            }
            .padding(.trailing, 12).padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .separator), lineWidth: 0.5)
        )
        .padding(.horizontal, 16).padding(.bottom, 10)
    }
}

#Preview {
    NumberTimeCard(
        timezone: "America/Los_Angeles",
        time: "2:38 PM",
        hours: "6 hours from local",
        date: "Sunday, October 17"
    )
}
