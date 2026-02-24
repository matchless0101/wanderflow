import SwiftUI

struct ItineraryCard: View {
    let itinerary: Itinerary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text(itinerary.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.liquidBlue.opacity(0.8))
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                ForEach(itinerary.days) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Day \(day.day)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.bottom, 4)
                        
                        ForEach(day.activities) { activity in
                            HStack(alignment: .top, spacing: 12) {
                                Text(activity.time)
                                    .font(.caption)
                                    .monospacedDigit()
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 40, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activity.poiName)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                    Text(activity.description)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: icon(for: activity.type))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(radius: 10)
    }
    
    func icon(for type: String) -> String {
        switch type.lowercased() {
        case "food": return "fork.knife"
        case "history": return "building.columns.fill"
        case "nature": return "leaf.fill"
        case "transport": return "tram.fill"
        default: return "mappin.circle.fill"
        }
    }
}
