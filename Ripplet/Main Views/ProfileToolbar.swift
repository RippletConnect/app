import SwiftUI

struct ProfileToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "gear")
                }
                .padding(.trailing, 6)
            }
        }
    }
}

extension View {
    func profileToolbar() -> some View { modifier(ProfileToolbar()) }
}
