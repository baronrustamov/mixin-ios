import Foundation
import Alamofire

public final class CircleAPI: MixinAPI {
    
    private enum Path {
        
        static let circles = "/circles"
        
        static func circle(id: String) -> String {
            "/circles/\(id)"
        }
        
        static func update(id: String) -> String {
            "/circles/\(id)"
        }
        
        static func updateCircleForConversation(id: String) -> String {
            "/conversations/\(id)/circles"
        }
        
        static func updateCircleForUser(id: String) -> String {
            "/users/\(id)/circles"
        }
        
        static func delete(id: String) -> String {
            "/circles/\(id)/delete"
        }
        
        static func conversations(id: String) -> String {
            "/circles/\(id)/conversations"
        }
        
        static func conversations(id: String, offset: String?, limit: Int) -> String {
            var url = "/circles/\(id)/conversations?limit=\(limit)"
            if let offset = offset {
                url += "&offset=\(offset)"
            }
            return url
        }
        
    }
    
    public static func circles() -> MixinAPI.Result<[CircleResponse]> {
        return request(method: .get, path: Path.circles)
    }
    
    public static func circle(id: String) -> MixinAPI.Result<CircleResponse> {
        return request(method: .get, path: Path.circle(id: id))
    }
    
    public static func circle(id: String, completion: @escaping (MixinAPI.Result<CircleResponse>) -> Void) {
        request(method: .get, path: Path.circle(id: id), completion: completion)
    }
    
    public static func circleConversations(circleId: String, offset: String?, limit: Int) -> MixinAPI.Result<[CircleConversation]> {
        return request(method: .get, path: Path.conversations(id: circleId, offset: offset, limit: limit))
    }
    
    public static func create(name: String, completion: @escaping (MixinAPI.Result<CircleResponse>) -> Void) {
        let param = ["name": name]
        request(method: .post, path: Path.circles, parameters: param, completion: completion)
    }
    
    public static func update(id: String, name: String, completion: @escaping (MixinAPI.Result<CircleResponse>) -> Void) {
        let param = ["name": name]
        request(method: .post, path: Path.update(id: id), parameters: param, completion: completion)
    }
    
    public static func updateCircle(of id: String, requests: [CircleConversationRequest], completion: @escaping (MixinAPI.Result<[CircleConversation]>) -> Void) {
        let params = requests.map(\.jsonObject)
        request(method: .post, path: Path.conversations(id: id), parameters: params, completion: completion)
    }
    
    public static func updateCircles(forConversationWith id: String, requests: [ConversationCircleRequest], completion: @escaping (MixinAPI.Result<[CircleConversation]>) -> Void) {
        let params = requests.map(\.jsonObject)
        request(method: .post, path: Path.updateCircleForConversation(id: id), parameters: params, completion: completion)
    }
    
    public static func updateCircles(forUserWith id: String, requests: [ConversationCircleRequest], completion: @escaping (MixinAPI.Result<[CircleConversation]>) -> Void) {
        let params = requests.map(\.jsonObject)
        request(method: .post, path: Path.updateCircleForUser(id: id), parameters: params, completion: completion)
    }
    
    public static func delete(id: String, completion: @escaping (MixinAPI.Result<Empty>) -> Void) {
        request(method: .post, path: Path.delete(id: id), completion: completion)
    }
    
}
