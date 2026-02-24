import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var routeStore: RoutePlanStore
    @Binding var selection: Tab
    @State private var showOnboarding = false
    @State private var desiredCity: String = ""
    @State private var desiredDays: Int = 2
    @State private var budgetMax: Double = 2000
    @State private var lastTravelMode: String = "自驾"
    @State private var lastCareMode: String = "默认"
    @State private var recommendations: [Itinerary] = []
    private let recommender = HomeRecommender()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(greetingTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Text("告诉我此刻的心情与期待，我们将为你挑一段合适的路。")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.top, -8)
                
                QuickPlannerView(city: $desiredCity, days: $desiredDays, budgetMax: $budgetMax) { tags, budget, travelMode, careMode in
                    lastTravelMode = travelMode
                    lastCareMode = careMode
                    generateRecommendations(tags: tags, budgetMax: budget, travelMode: travelMode, careMode: careMode)
                }
                .padding(.horizontal)
                Text("画像可在个人页修改")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                
                Text("精选推荐")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                Text("基于你的偏好与区域口碑，为你准备了温柔且不打扰的 3 条路线。")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(recommendations) { itin in
                        VStack(spacing: 8) {
                            ItineraryCard(itinerary: itin)
                            HStack {
                                Spacer()
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    applyTravelModeToStore()
                                    routeStore.updateFromItinerary(itin)
                                    selection = .map
                                } label: {
                                    Text("一键应用到地图")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.liquidBlue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
                
                Text("小贴士：路线只是起点，随时在地图页增删途经点，留些空白给偶遇与风。")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
            }
            .padding(.top, 50)
        }
        .onAppear {
            if recommendations.isEmpty {
                generateRecommendations(tags: [], budgetMax: budgetMax, travelMode: lastTravelMode, careMode: lastCareMode)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView {
                showOnboarding = false
                generateRecommendations(tags: [], budgetMax: budgetMax, travelMode: lastTravelMode, careMode: lastCareMode)
            }
        }
    }
    
    private var greetingTitle: String {
        if let profile = UserRepository.shared.load() {
            return "你好，\(profile.name)"
        }
        return "Good Morning,\nTraveler"
    }
    
    private func generateRecommendations(tags: [String], budgetMax: Double, travelMode: String, careMode: String) {
        let profile = UserRepository.shared.load()
        recommendations = recommender.recommend(profile: profile, city: desiredCity, days: desiredDays, tags: tags, budgetMax: budgetMax, travelMode: travelMode, careMode: careMode)
    }
    
    private func applyTravelModeToStore() {
        switch lastTravelMode {
        case "步行":
            routeStore.setTravelMode(.walking)
        case "公交":
            routeStore.setTravelMode(.transit)
        case "打车":
            routeStore.setTravelMode(.taxi)
        default:
            routeStore.setTravelMode(.driving)
        }
    }
}
