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
                    MainAppView()
                }
            }
            .environmentObject(settings)
            .accentColor(settings.accentColor)
            .tint(settings.accentColor)
            //.preferredColorScheme(.light)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
