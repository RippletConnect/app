import SwiftUI

struct ChatView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Text("Chat")
            }
            .navigationTitle("Chat")
        }
    }
}
