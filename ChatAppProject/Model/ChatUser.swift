//
//  ChatUser.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 12.01.2023.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
