import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SignInView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("Ripplet")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Meet people, make friends.")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Image("Ripplet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .cornerRadius(25)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    settings.hapticFeedback()
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
                    settings.hapticFeedback()
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
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 60)
        }
        .padding(.horizontal, 32)
        .background(settings.backgroundColor)
        .alert("Error", isPresented: $settings.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(settings.errorMessage)
                .foregroundColor(.white)
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
    
    private func configureGoogleSignIn() {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path),
            let clientId = plist["CLIENT_ID"] as? String
        else {
            print("❌ GoogleService-Info.plist not found or CLIENT_ID missing")
            return
        }
        
        print("✅ Configuring Google Sign In with Client ID: \(clientId)")
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
    
    private func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            withAnimation {
                settings.user = User(
                    id: user.uid,
                    name: user.displayName ?? "User",
                    email: user.email ?? ""
                )
            }
        }
    }
    
    private func handleGoogleSignIn() {
        print("🚀 Starting Google Sign In...")
        
        guard let presentingViewController = getRootViewController() else {
            print("❌ Unable to find root view controller")
            settings.showError("Unable to find root view controller")
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
                        settings.showError("Google Sign In was canceled. Please try again and complete the sign-in process.")
                    } else {
                        settings.showError("Google Sign In failed: \(error.localizedDescription)")
                    }
                    
                    return
                }
                
                print("✅ Google Sign In result received")
                
                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    print("❌ Failed to get user information from Google")
                    settings.showError("Failed to get user information from Google")
                    
                    return
                }
                
                print("✅ Got user info: \(user.profile?.name ?? "Unknown"), \(user.profile?.email ?? "Unknown")")
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                print("🔥 Signing in with Firebase...")
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("❌ Firebase authentication failed: \(error)")
                        settings.showError("Firebase authentication failed: \(error.localizedDescription)")
                        
                        return
                    }
                    
                    print("✅ Firebase authentication successful!")
                    
                    withAnimation {
                        settings.user = User(
                            id: user.userID ?? "",
                            name: user.profile?.name ?? "Google User",
                            email: user.profile?.email ?? ""
                        )
                    }
                    
                    print("🎉 Google Sign In successful!")
                }
            }
        }
    }
    
    private func showAppleNotImplemented() {
        withAnimation {
            settings.errorMessage = "Apple Sign In is not implemented yet. Please use Google Sign In."
            settings.showingError = true
        }
    }
        
    private func getRootViewController() -> UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else {
            return nil
        }
        
        return window.rootViewController
    }
}
