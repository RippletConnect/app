import SwiftUI
import Firebase
import GoogleSignIn

@main
struct RippletApp: App {
    @ObservedObject var settings = Settings.shared
    
    @State private var isLaunching: Bool = true
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLaunching {
                    LaunchScreen(isLaunching: $isLaunching)
                } else if settings.user == nil {
                    SignInView()
                } else {
                    TabView {
                        VStack {
                            HomeView()
                            
                            Button(action: {
                                withAnimation {
                                    isLaunching = true
                                }
                            }) {
                                Text("Replay launch screen")
                            }
                        }
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                        CommunityView()
                            .tabItem {
                                Label("Community", systemImage: "person.3.fill")
                            }
                        
                        ChatView()
                            .tabItem {
                                Label("Chat", systemImage: "message.fill")
                            }
                    }
                }
            }
            .environmentObject(settings)
            .accentColor(settings.accentColor)
            .tint(settings.accentColor)
            .transition(.opacity)
            .animation(.easeInOut, value: isLaunching)
            //.preferredColorScheme(.light)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
