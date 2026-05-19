import SwiftUI

struct TimeCard: View {
    var timezone: String
    var time: String
    var date: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Your Location")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer().frame(height: 8.0)
                Text(timezone)
                    .lineLimit(1)
                    .font(.system(size: 16.0))
                    .foregroundStyle(.white)
            }
            .padding(.leading, 8).padding(.bottom, 16)
            Spacer()
            VStack(alignment: .trailing) {
                Text(time)
                    .font(.system(size: 34.0, weight: .light))
                    .foregroundStyle(.white)
                Spacer().frame(height: 8.0)
                Text(date)
                    .lineLimit(1)
                    .font(.system(size: 12.0))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.trailing, 8).padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: Alignment(horizontal: .leading, vertical: .bottom))
        .background(
            LinearGradient(
                colors: [
                    Color(red: 30/255, green: 136/255, blue: 229/255),
                    Color(red: 0/255, green: 92/255, blue: 178/255),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding([.top, .horizontal])
    }
}

#Preview {
    TimeCard(timezone: "America/Los_Angeles", time: "1:39 PM", date: "Saturday, October 16")
}
