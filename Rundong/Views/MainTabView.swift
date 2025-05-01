import SwiftUI
import ECE564Login

struct MainTabView: View {
    @EnvironmentObject var personListVM: PersonListViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // -----Person List-----
                NavigationStack {
                    PersonListView()
                }
                .tabItem {
                    Label("List", systemImage: "person.3")
                }
                .tag(0)
                
                // -----Teams View-----
                NavigationStack {
                    TeamsView()
                }
                .tabItem {
                    Label("Teams", systemImage: "person.3.sequence")
                }
                .tag(1)
            }
            .tint(Color("AppPrimaryColor"))
            
            ECE564Login()
        }
        .background(Color("backgroundColor"))
    }
}

#Preview {
    MainTabView()
        .environmentObject(PersonListViewModel())
        .modelContainer(for: DukePerson.self, inMemory: true)
}
