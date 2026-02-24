import SwiftUI
import Combine
import AMapSearchKit

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var latestItinerary: Itinerary?
    
    private var cancellables = Set<AnyCancellable>()
    private let aiService = AIService.shared
    private let amapManager = AmapManager.shared
    private let itineraryKeywords = [
        "行程", "规划", "旅行计划", "旅游计划", "出行计划",
        "路线", "攻略", "安排", "几天", "玩几天",
        "itinerary", "trip plan", "travel plan", "plan a trip", "plan a travel"
    ]
    private let placeIntentKeywords = [
        "去", "到", "在哪", "在哪里", "定位", "导航", "地图", "怎么走", "怎么去",
        "where", "location", "navigate", "map", "go to"
    ]
    
    func sendMessage() {
        let prompt = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        
        messages.append(Message(content: prompt, isUser: true, itinerary: nil))
        userInput = ""
        isLoading = true
        
        if shouldGenerateItinerary(for: prompt) {
            sendItineraryRequest(prompt: prompt)
            return
        }
        
        Task {
            if shouldTryPlaceLookup(for: prompt),
               let target = await resolveMapJumpTarget(from: prompt) {
                await MainActor.run {
                    self.messages.append(
                        Message(
                            content: "已识别地点：\(target.name)\n点击下方链接可跳转地图并查看气泡标注。",
                            isUser: false,
                            itinerary: nil,
                            mapJumpTarget: target
                        )
                    )
                    self.isLoading = false
                }
                return
            }
            
            await MainActor.run {
                self.sendChatRequest(prompt: prompt)
            }
        }
    }
    
    private func sendItineraryRequest(prompt: String) {
        aiService.generateItinerary(prompt: prompt)
            .map { Message(content: "Here is your suggested itinerary:", isUser: false, itinerary: $0) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.messages.append(Message(content: "Error: \(error.localizedDescription)", isUser: false, itinerary: nil))
                }
            }, receiveValue: { [weak self] message in
                self?.messages.append(message)
                if let itinerary = message.itinerary {
                    self?.latestItinerary = itinerary
                }
            })
            .store(in: &cancellables)
    }
    
    private func sendChatRequest(prompt: String) {
        aiService.generateChat(prompt: prompt)
            .map { Message(content: $0, isUser: false, itinerary: nil) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.messages.append(Message(content: "Error: \(error.localizedDescription)", isUser: false, itinerary: nil))
                }
            }, receiveValue: { [weak self] message in
                self?.messages.append(message)
            })
            .store(in: &cancellables)
    }
    
    private func shouldGenerateItinerary(for input: String) -> Bool {
        let lowercased = input.lowercased()
        return itineraryKeywords.contains { keyword in
            lowercased.contains(keyword.lowercased())
        }
    }
    
    private func shouldTryPlaceLookup(for input: String) -> Bool {
        let lowercased = input.lowercased()
        return placeIntentKeywords.contains { lowercased.contains($0.lowercased()) }
    }
    
    private func resolveMapJumpTarget(from input: String) async -> MapJumpTarget? {
        let queries = candidatePlaceQueries(from: input)
        for query in queries {
            do {
                let pois = try await amapManager.searchPOIKeywords(keyword: query, city: nil, cityLimit: false)
                if let best = selectBestPOI(from: pois, query: query) {
                    let name = best.name ?? query
                    return MapJumpTarget(
                        name: name,
                        latitude: Double(best.location.latitude),
                        longitude: Double(best.location.longitude),
                        source: "chat"
                    )
                }
            } catch {
                print("POI lookup error: query=\(query), error=\(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func candidatePlaceQueries(from input: String) -> [String] {
        var candidates: [String] = []
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            candidates.append(trimmed)
        }
        
        let patterns = ["去", "到", "在", "导航到", "定位到", "帮我找", "带我去"]
        for marker in patterns {
            if let range = trimmed.range(of: marker) {
                let tail = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                if tail.count >= 2 {
                    candidates.append(tail)
                }
            }
        }
        
        return Array(Set(candidates)).sorted { $0.count > $1.count }
    }
    
    private func selectBestPOI(from pois: [AMapPOI], query: String) -> AMapPOI? {
        guard !pois.isEmpty else { return nil }
        let normalized = query.lowercased()
        let exactNameMatch = pois.first { poi in
            (poi.name ?? "").lowercased().contains(normalized)
        }
        if let exactNameMatch {
            return exactNameMatch
        }
        return pois.first
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let itinerary: Itinerary?
    let mapJumpTarget: MapJumpTarget?
    
    init(content: String, isUser: Bool, itinerary: Itinerary? = nil, mapJumpTarget: MapJumpTarget? = nil) {
        self.content = content
        self.isUser = isUser
        self.itinerary = itinerary
        self.mapJumpTarget = mapJumpTarget
    }
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject private var routeStore: RoutePlanStore
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { msg in
                        VStack(alignment: msg.isUser ? .trailing : .leading) {
                            HStack {
                                if msg.isUser { Spacer() }
                                Text(msg.content)
                                    .padding()
                                    .background(msg.isUser ? Color.liquidBlue : Color.gray.opacity(0.2))
                                    .foregroundColor(msg.isUser ? .white : .primary)
                                    .cornerRadius(16)
                                if !msg.isUser { Spacer() }
                            }
                            
                            if let target = msg.mapJumpTarget {
                                HStack {
                                    if msg.isUser { Spacer() }
                                    Button {
                                        routeStore.jumpToMapTarget(target)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "map.fill")
                                                .font(.system(size: 13, weight: .semibold))
                                            Text("在地图查看：\(target.name)")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(Capsule())
                                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 4)
                                    }
                                    if !msg.isUser { Spacer() }
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                            }
                            
                            if let itinerary = msg.itinerary {
                                ItineraryCard(itinerary: itinerary)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Ask about Chaoshan travel...", text: $viewModel.userInput)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.liquidBlue))
                }
                .padding(.trailing)
            }
            .background(.ultraThinMaterial)
        }
        .navigationTitle("AI Guide")
        .onChange(of: viewModel.latestItinerary) { _, itinerary in
            if let itinerary {
                print("Itinerary received: title=\(itinerary.title), days=\(itinerary.days.count)")
                routeStore.updateFromItinerary(itinerary)
            } else {
                print("Itinerary received: nil")
            }
        }
    }
}
