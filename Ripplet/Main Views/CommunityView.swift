import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Text("Community")
            }
            .navigationTitle("Community")
        }
    }
}
