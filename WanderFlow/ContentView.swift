import SwiftUI

enum Tab {
    case home, map, chat, profile
}

struct ContentView: View {
    @State private var selection: Tab = .home
    @StateObject private var routeStore = RoutePlanStore()
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            // Global Background
            LiquidBackground()
            
            TabView(selection: $selection) {
                HomeView(selection: $selection)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(Tab.home)
                
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(Tab.map)
                
                ChatView()
                    .tabItem {
                        Label("AI Guide", systemImage: "sparkles")
                    }
                    .tag(Tab.chat)
                
                 ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(Tab.profile)
            }
            .accentColor(.white)
            .environmentObject(routeStore)
        }
        .onChange(of: routeStore.mapTabJumpToken) { _, token in
            guard token > 0 else { return }
            selection = .map
        }
        .preferredColorScheme(.dark) // Force dark mode for better liquid effect visibility
        .onAppear {
            if !UserRepository.shared.exists() {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(onFinish: {
                showOnboarding = false
            }, onBack: nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
