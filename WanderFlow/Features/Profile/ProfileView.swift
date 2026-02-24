import SwiftUI

struct ProfileView: View {
    @State private var profile: UserProfile = UserRepository.shared.load() ?? .defaultProfile
    @State private var foodie: Bool = false
    @State private var history: Bool = false
    @State private var nature: Bool = false
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("昵称", text: $profile.name)
                    TextField("MBTI", text: Binding(
                        get: { profile.mbti ?? "" },
                        set: { profile.mbti = $0.isEmpty ? nil : $0.uppercased() }
                    ))
                } header: {
                    Text("基本信息")
                }
                Section {
                    Toggle("吃货", isOn: $foodie)
                    Toggle("历史", isOn: $history)
                    Toggle("自然", isOn: $nature)
                } header: {
                    Text("偏好")
                }
                Section {
                    VStack {
                        HStack {
                            Text("最低").frame(width: 40, alignment: .leading)
                            Slider(value: Binding(
                                get: { profile.budgetRange.lowerBound },
                                set: { profile = UserProfile(id: profile.id, name: profile.name, preferences: profile.preferences, budgetRange: $0...profile.budgetRange.upperBound, visitedPOIs: profile.visitedPOIs, mbti: profile.mbti, personaTags: profile.personaTags) }
                            ), in: 0...profile.budgetRange.upperBound, step: 50)
                            Text("\(Int(profile.budgetRange.lowerBound))")
                        }
                        HStack {
                            Text("最高").frame(width: 40, alignment: .leading)
                            Slider(value: Binding(
                                get: { profile.budgetRange.upperBound },
                                set: { profile = UserProfile(id: profile.id, name: profile.name, preferences: profile.preferences, budgetRange: profile.budgetRange.lowerBound...$0, visitedPOIs: profile.visitedPOIs, mbti: profile.mbti, personaTags: profile.personaTags) }
                            ), in: profile.budgetRange.lowerBound...10000, step: 50)
                            Text("\(Int(profile.budgetRange.upperBound))")
                        }
                    }
                } header: {
                    Text("预算区间")
                }
                Section {
                    Button("重新填写画像") {
                        showOnboarding = true
                    }
                }
            }
            .navigationTitle("个人画像")
            .onAppear {
                reloadProfile()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        var prefs: [String] = []
                        if foodie { prefs.append("Foodie") }
                        if history { prefs.append("History") }
                        if nature { prefs.append("Nature") }
                        profile = UserProfile(id: profile.id, name: profile.name, preferences: prefs, budgetRange: profile.budgetRange, visitedPOIs: profile.visitedPOIs, mbti: profile.mbti, personaTags: prefs)
                        UserRepository.shared.save(profile)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(onFinish: {
                showOnboarding = false
                reloadProfile()
            }, onBack: {
                showOnboarding = false
            })
        }
    }
    
    private func reloadProfile() {
        profile = UserRepository.shared.load() ?? .defaultProfile
        foodie = profile.preferences.contains("Foodie")
        history = profile.preferences.contains("History")
        nature = profile.preferences.contains("Nature")
    }
}
