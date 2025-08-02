import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bell.fill")
                }

            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3.fill") // Or "globe"
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}
