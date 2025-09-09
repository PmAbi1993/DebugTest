import Foundation

class MockManager {
    enum MockFile: String {
        case userProfile
        case posts
        case comments

        var fileName: String {
            switch self {
            case .userProfile:
                return "user_profile"
            case .posts:
                return "posts"
            case .comments:
                return "comments"
            }
        }
    }
    
    static func loadJSON<T: Decodable>(from file: MockFile) -> T? {
        guard let url = Bundle(for: MockManager.self).url(forResource: file.rawValue, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Error decoding \(file.filename): \(error)")
            return nil
        }
    }
}
