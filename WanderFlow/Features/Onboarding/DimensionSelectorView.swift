import SwiftUI
import UIKit

struct DimensionCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isSystemSymbol: Bool
    let backgroundHex: String?
    let backgroundColor: Color?
    let round: Int
    
    var background: Color {
        if let backgroundColor {
            return backgroundColor
        }
        if let backgroundHex {
            return Color(hex: backgroundHex)
        }
        return Color.white
    }
}

struct DimensionRound: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let cards: [DimensionCard]
}

struct DimensionSelectorView: View {
    let rounds: [DimensionRound]
    var onComplete: (([DimensionCard]) -> Void)?
    var onBack: (() -> Void)?
    
    @Namespace private var cardNamespace
    @State private var currentRoundIndex = 0
    @State private var focusedIndex: Int? = nil
    @State private var selectedCards: [DimensionCard] = []
    @State private var isRoundVisible = true
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                topBar
                titleArea
                progressBar
                GeometryReader { proxy in
                    ZStack {
                        if isRoundVisible, let round = currentRound {
                            cardFanView(round: round, size: proxy.size)
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .zIndex(2)
            
            if focusedIndex != nil {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            focusedIndex = nil
                        }
                    }
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: focusedIndex)
        .animation(.easeInOut(duration: 0.35), value: currentRoundIndex)
        .animation(.easeInOut(duration: 0.35), value: isRoundVisible)
    }
    
    private var topBar: some View {
        HStack {
            Button(action: {
                onBack?()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("返回")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            }
            .disabled(onBack == nil)
            Spacer()
        }
        .overlay(
            Text("AI 决策分析")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [Color(hex: "#A3C4F3"), Color(hex: "#CDB4DB")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
        )
    }
    
    private var titleArea: some View {
        VStack(spacing: 6) {
            Text(currentRound?.title ?? "")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            Text(currentRound?.subtitle ?? "")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
    
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(rounds.indices, id: \.self) { index in
                Capsule()
                    .fill(index <= currentRoundIndex ? Color(hex: "#8ECAE6") : Color.gray.opacity(0.2))
                    .frame(width: index <= currentRoundIndex ? 30 : 10, height: 6)
            }
        }
        .frame(height: 10)
    }
    
    private func cardFanView(round: DimensionRound, size: CGSize) -> some View {
        ZStack {
            ForEach(round.cards.indices, id: \.self) { index in
                let card = round.cards[index]
                let isFocused = focusedIndex == index
                let anyFocused = focusedIndex != nil
                let baseY = size.height * 0.72
                let centerOffsetY = size.height * 0.42 - baseY
                let fan = fanLayout(index: index, total: round.cards.count)
                
                cardView(card: card, isFocused: isFocused, showConfirm: isFocused)
                    .frame(width: 180, height: 270)
                    .position(x: size.width / 2, y: baseY)
                    .offset(x: layoutOffsetX(isFocused: isFocused, anyFocused: anyFocused, fanOffset: fan.x, index: index),
                            y: layoutOffsetY(isFocused: isFocused, anyFocused: anyFocused, fanOffset: fan.y, centerOffsetY: centerOffsetY))
                    .rotationEffect(.degrees(layoutRotation(isFocused: isFocused, anyFocused: anyFocused, fanAngle: fan.angle, index: index)))
                    .scaleEffect(isFocused ? 1.25 : 1)
                    .opacity(layoutOpacity(isFocused: isFocused, anyFocused: anyFocused))
                    .zIndex(layoutZIndex(isFocused: isFocused, total: round.cards.count, offset: fan.offset))
                    .matchedGeometryEffect(id: card.id, in: cardNamespace)
                    .onTapGesture {
                        handleCardTap(index: index)
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func cardView(card: DimensionCard, isFocused: Bool, showConfirm: Bool) -> some View {
        VStack(spacing: 14) {
            Group {
                if card.isSystemSymbol {
                    Image(systemName: card.icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.primary)
                } else {
                    Text(card.icon)
                        .font(.system(size: 34))
                }
            }
            .frame(width: 72, height: 72)
            .background(Color.white.opacity(0.6))
            .clipShape(Circle())
            
            VStack(spacing: 6) {
                Text(card.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Text(card.description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            if showConfirm {
                Button(action: {
                    confirmSelection(card: card)
                }) {
                    Text("确认选择")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                Capsule()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: 28, height: 4)
                    .padding(.bottom, 6)
            }
        }
        .padding(18)
        .background(card.background)
        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(isFocused ? 0.2 : 0.08), radius: isFocused ? 30 : 10, x: 0, y: isFocused ? 18 : 6)
    }
    
    private func handleCardTap(index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        if focusedIndex == index {
            focusedIndex = nil
        } else {
            focusedIndex = index
            generator.impactOccurred()
        }
    }
    
    private func confirmSelection(card: DimensionCard) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let updatedSelections = selectedCards + [card]
        selectedCards = updatedSelections
        focusedIndex = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            isRoundVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let nextIndex = currentRoundIndex + 1
            if nextIndex < rounds.count {
                currentRoundIndex = nextIndex
                withAnimation(.easeInOut(duration: 0.35)) {
                    isRoundVisible = true
                }
            } else {
                onComplete?(updatedSelections)
            }
        }
    }
    
    private var currentRound: DimensionRound? {
        guard rounds.indices.contains(currentRoundIndex) else { return nil }
        return rounds[currentRoundIndex]
    }
    
    private func fanLayout(index: Int, total: Int) -> (offset: Double, angle: Double, x: CGFloat, y: CGFloat) {
        let mid = Double(total - 1) / 2
        let offset = Double(index) - mid
        let angle = offset * 12
        let x = CGFloat(offset) * 110
        let y = CGFloat(abs(offset)) * 20
        return (offset, angle, x, y)
    }
    
    private func layoutOffsetX(isFocused: Bool, anyFocused: Bool, fanOffset: CGFloat, index: Int) -> CGFloat {
        if isFocused {
            return 0
        }
        if anyFocused {
            let side: CGFloat = (index < (focusedIndex ?? 0)) ? -1 : 1
            return side * 320
        }
        return fanOffset
    }
    
    private func layoutOffsetY(isFocused: Bool, anyFocused: Bool, fanOffset: CGFloat, centerOffsetY: CGFloat) -> CGFloat {
        if isFocused {
            return centerOffsetY
        }
        if anyFocused {
            return 120
        }
        return fanOffset
    }
    
    private func layoutRotation(isFocused: Bool, anyFocused: Bool, fanAngle: Double, index: Int) -> Double {
        if isFocused {
            return 0
        }
        if anyFocused {
            return index < (focusedIndex ?? 0) ? -20 : 20
        }
        return fanAngle
    }
    
    private func layoutOpacity(isFocused: Bool, anyFocused: Bool) -> Double {
        if isFocused {
            return 1
        }
        if anyFocused {
            return 0
        }
        return 1
    }
    
    private func layoutZIndex(isFocused: Bool, total: Int, offset: Double) -> Double {
        if isFocused {
            return 100
        }
        return Double(total) - abs(offset)
    }
}

extension Color {
    init(hex: String) {
        let hexValue = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexValue.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
