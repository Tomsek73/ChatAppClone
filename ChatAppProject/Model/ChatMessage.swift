import Foundation

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text, profileImageUrl: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        
    }
}
