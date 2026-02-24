import Foundation

public nonisolated struct OpenAIResponse: Codable, Sendable {
    public struct Choice: Codable, Sendable {
        public struct Message: Codable, Sendable {
            public let content: String
            
            public init(content: String) {
                self.content = content
            }
        }
        public let message: Message
        
        public init(message: Message) {
            self.message = message
        }
    }
    public let choices: [Choice]
    
    public init(choices: [Choice]) {
        self.choices = choices
    }
}
