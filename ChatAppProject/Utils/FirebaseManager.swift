//
//  FirebaseManager.swift
//  ChatAppProject
//  Created by Tomáš Zatloukal on 12.01.2023.


import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import UIKit
import GoogleSignIn


class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    

    
}

extension UIApplication{
        func rootControler() -> UIViewController{
            guard let window = connectedScenes.first as? UIWindowScene else {return .init()}
            guard let viewController = window.windows.last?.rootViewController else {return .init()}
            
            return viewController
        }
    }
