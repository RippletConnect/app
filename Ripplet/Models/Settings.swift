import SwiftUI
import os
import FirebaseAuth
import GoogleSignIn

let logger = Logger(subsystem: "com.elmallah.ripplet", category: "Ripplet")

final class Settings: ObservableObject {
    static let shared = Settings()
    
    let accentColor = Color(red: 69.0/255, green: 216.0/255, blue: 162.0/255)
    let backgroundColor = Color(red: 0.6, green: 0.725, blue: 0.741)
    
    //@Published var user: User? = nil
    @Published var user: User? = User(id: "1", name: "Test User", email: "test@gmail.com")
    
    @Published var showingError = false
    @Published var errorMessage = ""
    
    func showError(_ message: String) {
        withAnimation {
            errorMessage = message
            showingError = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            withAnimation {
                user = nil
            }
        } catch {
            showError("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func hapticFeedback() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}
