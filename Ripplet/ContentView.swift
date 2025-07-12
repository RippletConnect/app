import SwiftUI
import AuthenticationServices
import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

struct User {
    let id: String
    let name: String
    let email: String
}

struct ContentView: View {
    @State private var isSignedIn = false
    @State private var currentUser: User? = nil
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        if isSignedIn {
            MainAppView(user: currentUser, onSignOut: {
                signOut()
            })
        } else {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Ripplet")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Meet people, make friends.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack {
                            Image("GoogleLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Google")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        showAppleNotImplemented()
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Continue with Apple")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 60)
            }
        }
        .background(Color(UIColor.systemBackground))
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            configureGoogleSignIn()
            checkAuthStatus()
            
            if let config = GIDSignIn.sharedInstance.configuration {
                print("✅ Google Sign In configuration found: \(config.clientID)")
            } else {
                print("❌ Google Sign In configuration missing!")
            }
        }
        }
    }
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("❌ GoogleService-Info.plist not found or CLIENT_ID missing")
            return
        }
        
        print("✅ Configuring Google Sign In with Client ID: \(clientId)")
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    private func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            currentUser = User(
                id: user.uid,
                name: user.displayName ?? "User",
                email: user.email ?? ""
            )
            isSignedIn = true
        }
    }
    
    private func handleGoogleSignIn() {
        print("🚀 Starting Google Sign In...")
        
        guard let presentingViewController = getRootViewController() else {
            print("❌ Unable to find root view controller")
            showError("Unable to find root view controller")
            return
        }
        
        print("✅ Found presenting view controller: \(presentingViewController)")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Google Sign In Error: \(error)")
                    print("❌ Error Code: \(error._code)")
                    print("❌ Error Domain: \(error._domain)")
                    
                    if error.localizedDescription.contains("canceled") {
                        self.showError("Google Sign In was canceled. Please try again and complete the sign-in process.")
                    } else {
                        self.showError("Google Sign In failed: \(error.localizedDescription)")
                    }
                    return
                }
                
                print("✅ Google Sign In result received")
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    print("❌ Failed to get user information from Google")
                    self.showError("Failed to get user information from Google")
                    return
                }
                
                print("✅ Got user info: \(user.profile?.name ?? "Unknown"), \(user.profile?.email ?? "Unknown")")
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                print("🔥 Signing in with Firebase...")
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("❌ Firebase authentication failed: \(error)")
                        self.showError("Firebase authentication failed: \(error.localizedDescription)")
                        return
                    }
                    
                    print("✅ Firebase authentication successful!")
                    
                    self.currentUser = User(
                        id: user.userID ?? "",
                        name: user.profile?.name ?? "Google User",
                        email: user.profile?.email ?? ""
                    )
                    
                    withAnimation {
                        self.isSignedIn = true
                    }
                    
                    print("🎉 Google Sign In successful!")
                }
            }
        }
    }
    
    private func showAppleNotImplemented() {
        errorMessage = "Apple Sign In is not implemented yet. Please use Google Sign In."
        showingError = true
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            withAnimation {
                isSignedIn = false
                currentUser = nil
            }
        } catch {
            showError("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    

    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}

struct MainAppView: View {
    let user: User?
    let onSignOut: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Ripplet!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let user = user {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Signed in as:")
                            .font(.headline)
                        Text(user.name)
                            .font(.title2)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("via Google")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button("Sign Out") {
                    onSignOut()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Ripplet")
        }
    }
}

#Preview {
    ContentView()
}
