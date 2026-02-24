import SwiftUI

// MARK: - Liquid Shape
struct LiquidShape: Shape {
    var offset: CGSize
    var animatableData: CGSize.AnimatableData {
        get { offset.animatableData }
        set { offset.animatableData = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Use sine waves to create organic shapes
        path.move(to: CGPoint(x: 0, y: height * 0.5))
        
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.5),
            control1: CGPoint(x: width * 0.25, y: height * 0.5 + offset.height),
            control2: CGPoint(x: width * 0.75, y: height * 0.5 - offset.height)
        )
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        
        return path
    }
}

// MARK: - Colors
extension Color {
    static let wanderPrimary = Color.liquidBlue
    static let wanderSecondary = Color.liquidPurple
    static let liquidBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let liquidPurple = Color(red: 0.5, green: 0.2, blue: 0.9)
}

struct LiquidBackground: View {
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Abstract blobs
            Circle()
                .fill(Color.liquidBlue.opacity(0.6))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(Color.liquidPurple.opacity(0.6))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 100, y: 150)
            
            // Glassmorphism overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
}
