import SwiftUI

struct ListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(.init())
            .listRowSeparator(.hidden)
    }
}

extension View {
    func withListModifier() -> some View {
        modifier(ListModifier())
    }
}
