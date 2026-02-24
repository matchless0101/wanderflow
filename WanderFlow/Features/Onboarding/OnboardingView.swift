import SwiftUI

struct OnboardingView: View {
    var onFinish: (() -> Void)?
    var onBack: (() -> Void)?
    
    private let rounds: [DimensionRound] = [
        DimensionRound(
            title: "你的出行节拍？",
            subtitle: "决定了 WanderFlow 为你推荐的交通策略",
            cards: [
                DimensionCard(title: "徒步丈量", description: "慢节奏，深度探索每一条街巷", icon: "🥾", isSystemSymbol: false, backgroundHex: "#E3F9E5", backgroundColor: nil, round: 0),
                DimensionCard(title: "自驾流浪", description: "自由掌控速度与停靠点", icon: "🚗", isSystemSymbol: false, backgroundHex: "#E3F2FD", backgroundColor: nil, round: 0),
                DimensionCard(title: "极简飞行", description: "高效跨越，只为终点美景", icon: "✈️", isSystemSymbol: false, backgroundHex: "#FFF8E1", backgroundColor: nil, round: 0)
            ]
        ),
        DimensionRound(
            title: "你的人格底色？",
            subtitle: "帮助我们寻找志同道合的旅伴",
            cards: [
                DimensionCard(title: "独行特立", description: "享受孤独，在静谧中思考", icon: "🧘", isSystemSymbol: false, backgroundHex: "#F3E5F5", backgroundColor: nil, round: 1),
                DimensionCard(title: "社交狂热", description: "旅行就是一场大型面基", icon: "🥂", isSystemSymbol: false, backgroundHex: "#FCE4EC", backgroundColor: nil, round: 1),
                DimensionCard(title: "温暖随行", description: "陪伴家人，记录温馨瞬间", icon: "👨‍👩‍👧", isSystemSymbol: false, backgroundHex: "#EFEBE9", backgroundColor: nil, round: 1)
            ]
        ),
        DimensionRound(
            title: "你更偏好哪种氛围？",
            subtitle: "我们会据此调整推荐的停留节奏",
            cards: [
                DimensionCard(title: "松弛慢游", description: "慢慢来，把时间留给街角与日落", icon: "🌤️", isSystemSymbol: false, backgroundHex: "#FFF1D6", backgroundColor: nil, round: 2),
                DimensionCard(title: "均衡刚好", description: "体验与休息同样重要", icon: "🧩", isSystemSymbol: false, backgroundHex: "#E7F1FF", backgroundColor: nil, round: 2),
                DimensionCard(title: "高能拉满", description: "高强度打卡，每一刻都充实", icon: "⚡️", isSystemSymbol: false, backgroundHex: "#FDE2E4", backgroundColor: nil, round: 2)
            ]
        ),
        DimensionRound(
            title: "你更在意哪种记忆？",
            subtitle: "帮助我们把旅行拆成更像你的片段",
            cards: [
                DimensionCard(title: "味觉记忆", description: "好吃是旅行最重要的锚点", icon: "🍜", isSystemSymbol: false, backgroundHex: "#E8F9F1", backgroundColor: nil, round: 3),
                DimensionCard(title: "人文记忆", description: "故事与历史让城市有温度", icon: "🏛️", isSystemSymbol: false, backgroundHex: "#F2E9FF", backgroundColor: nil, round: 3),
                DimensionCard(title: "自然记忆", description: "山海风光才是终极治愈", icon: "🌿", isSystemSymbol: false, backgroundHex: "#E3FCEC", backgroundColor: nil, round: 3)
            ]
        ),
        DimensionRound(
            title: "你期待怎样的陪伴？",
            subtitle: "让 WanderFlow 为你匹配合适的旅伴强度",
            cards: [
                DimensionCard(title: "独享时光", description: "一个人也能闪闪发光", icon: "🌙", isSystemSymbol: false, backgroundHex: "#ECE7FF", backgroundColor: nil, round: 4),
                DimensionCard(title: "小团体", description: "一两位同行刚刚好", icon: "👫", isSystemSymbol: false, backgroundHex: "#FFE8F1", backgroundColor: nil, round: 4),
                DimensionCard(title: "热闹同行", description: "氛围感来自一群人", icon: "🎉", isSystemSymbol: false, backgroundHex: "#FFF0D9", backgroundColor: nil, round: 4)
            ]
        )
    ]
    
    var body: some View {
        DimensionSelectorView(rounds: rounds, onComplete: { selections in
            let tags = selections.map { $0.title }
            let profile = UserProfile(
                id: UUID(),
                name: "Traveler",
                preferences: [],
                budgetRange: 0...2000,
                visitedPOIs: [],
                mbti: nil,
                personaTags: tags
            )
            UserRepository.shared.save(profile)
            onFinish?()
        }, onBack: {
            onBack?()
        })
    }
}
