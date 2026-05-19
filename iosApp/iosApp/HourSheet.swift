import SwiftUI

struct HourSheet: View {
    @Binding var hours: [Int]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(hours, id: \.self) { hour in
                Text("\(hour):00")
            }
            .navigationTitle("Found Meeting Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HourSheet(hours: .constant([8, 9, 10]))
}
