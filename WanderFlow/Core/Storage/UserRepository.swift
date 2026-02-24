import Foundation

final class UserRepository {
    static let shared = UserRepository()
    private let key = "wf.user.profile"
    private let defaults = UserDefaults.standard
    func load() -> UserProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }
    func save(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: key)
        }
    }
    func exists() -> Bool {
        load() != nil
    }
}
