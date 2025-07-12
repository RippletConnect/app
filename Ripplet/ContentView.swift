import SwiftUI
import AuthenticationServices
import UIKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacer
                Spacer()
                
                // App name section
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
                
                // Authentication buttons section
                VStack(spacing: 16) {
                    // Continue with Google button
                    Button(action: {
                        // Handle Google sign in
                        print("Google Sign In tapped")
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
                    
                    // Continue with Apple button
                    SignInWithAppleButton(
                        onRequest: { request in
                            // Configure the request
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            // Handle the authorization result
                            switch result {
                            case .success(let authorization):
                                // Handle successful authorization
                                print("Apple Sign In successful")
                            case .failure(let error):
                                // Handle error
                                print("Apple Sign In failed: \(error)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                }
                .padding(.horizontal, 32)
                
                // Bottom spacer
                Spacer()
                    .frame(height: 60)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    ContentView()
}
