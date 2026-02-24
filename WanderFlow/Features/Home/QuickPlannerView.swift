import SwiftUI

struct QuickPlannerView: View {
    @Binding var city: String
    @Binding var days: Int
    @Binding var budgetMax: Double
    @State private var travelMode: Int = 0
    @State private var careMode: Int = 0
    @State private var selectedTags: Set<String> = []
    var onGenerate: (_ tags: [String], _ budgetMax: Double, _ travelMode: String, _ careMode: String) -> Void
    
    private let tags = ["美食", "商场", "景点", "住宿"]
    private let modes = ["自驾", "打车", "公交", "步行"]
    private let careModes = ["默认", "携老携幼", "个人快节奏", "出差", "时差适应", "特种兵"]
    
    var body: some View {
        VStack(spacing: 12) {
            Picker(selection: $travelMode, label: Text("出行")) {
                ForEach(0..<modes.count, id: \.self) { i in
                    Text(modes[i]).tag(i)
                }
            }
            .pickerStyle(.segmented)
            
            Picker(selection: $careMode, label: Text("人文关怀")) {
                ForEach(0..<careModes.count, id: \.self) { i in
                    Text(careModes[i]).tag(i)
                }
            }
            .pickerStyle(.segmented)
            
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { t in
                    TagChip(title: t, isOn: selectedTags.contains(t)) {
                        if selectedTags.contains(t) {
                            selectedTags.remove(t)
                        } else {
                            selectedTags.insert(t)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                TextField("目的地（可留空）", text: $city)
                    .textFieldStyle(.roundedBorder)
                Stepper("\(days) 天", value: $days, in: 1...10)
                    .labelsHidden()
            }
            
            VStack {
                HStack {
                    Text("预算上限")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text("¥\(Int(budgetMax))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                Slider(value: $budgetMax, in: 200...10000, step: 100)
            }
            
            ProgressView(value: progressValue)
                .tint(.white)
            
            Button {
                onGenerate(Array(selectedTags), budgetMax, modes[travelMode], careModes[careMode])
            } label: {
                Text("生成推荐")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.liquidBlue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.liquidBlue, .liquidPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private var progressValue: Double {
        var v = 0.0
        if !city.isEmpty { v += 0.2 }
        if days > 0 { v += 0.2 }
        if !selectedTags.isEmpty { v += 0.4 }
        v += 0.2
        return min(v, 1.0)
    }
}

private struct TagChip: View {
    let title: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isOn ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isOn ? Color.white : Color.white.opacity(0.15))
                .cornerRadius(16)
        }
    }
}
