import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var settings: Settings
        
    var body: some View {
        List {
            if let user = settings.user {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signed in as:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(user.name)
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("via Google")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .cornerRadius(8)
            }
            
            Spacer()
            
            Button(action: {
                settings.hapticFeedback()
                settings.signOut()
            }) {
                Text("Sign Out")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settings.accentColor.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .shadow(color: settings.accentColor.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(settings.accentColor, lineWidth: 5)
                            .shadow(color: settings.accentColor, radius: 10, x: 0.0, y: 0.0)
                            .blur(radius: 5)
                            .opacity(0.5)
                    )
            }
        }
        .navigationTitle("Profile")
        .background(settings.backgroundColor)
    }
}
