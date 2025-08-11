import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Text("Home")
            }
            .navigationTitle("Home")
            .profileToolbar()
        }
    }
}
