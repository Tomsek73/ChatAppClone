//
//  MainMessagesViewModel.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 20.01.2023.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift

extension MainMessagesView{
    
    @MainActor class MainMessagesViewModel: ObservableObject {
        
        @Published var errorMessage = ""
        @Published var chatUser: ChatUser?
        @Published var isUserCurrentlyLoggedOut = false
        
        var chatLogViewModel = ChatLogView.ChatLogViewModel(chatUser: nil)
        
        
        init() {
            
            DispatchQueue.main.async {
                self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            }
            
            
            fetchCurrentGoogleUser()
            
            fetchRecentGoogleMessages()
            
            fetchCurrentUser()
            
            fetchRecentMessages()
            
        }
        
        @Published var recentMessages = [RecentMessage]()
        @Published var chatloggedUser: ChatUser?
        
        private var firestoreListener: ListenerRegistration?
        
        func generateRecentMessage(recent: RecentMessage){
            let uid = FirebaseManager.shared.auth.currentUser?.uid == recent.fromId ? recent.toId : GIDSignIn.sharedInstance.currentUser?.userID == recent.fromId ? recent.toId : recent.fromId
            
            
            
            let chatUserData = ["id": uid, "uid": uid, "email": recent.email, "profileImageUrl": recent.profileImageUrl]
            
            self.chatloggedUser = .init(data: chatUserData)
            
            self.chatLogViewModel.chatUser = self.chatloggedUser
            
            self.chatLogViewModel.fetchMessages()
            
            self.chatLogViewModel.fetchGoogleMessages()
            
            
            
        }
        
        func fetchRecentMessages() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            firestoreListener?.remove()
            self.recentMessages.removeAll()
            
            firestoreListener = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for recent messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        let docId = change.document.documentID
                        
                        if let index = self.recentMessages.firstIndex(where: { rm in
                            return rm.documentId == docId
                        }) {
                            self.recentMessages.remove(at: index)
                        }
                        
                        self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                        
                        
                        //                    self.recentMessages.append()
                    })
                }
        }
        
        func fetchRecentGoogleMessages() {
            guard let uid = GIDSignIn.sharedInstance.currentUser?.userID else { return }
            firestoreListener?.remove()
            self.recentMessages.removeAll()
            
            firestoreListener = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for recent messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        let docId = change.document.documentID
                        
                        if let index = self.recentMessages.firstIndex(where: { rm in
                            return rm.documentId == docId
                        }) {
                            self.recentMessages.remove(at: index)
                        }
                        
                        self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                        
                        
                        //                    self.recentMessages.append()
                    })
                }
        }
        
        func fetchCurrentUser() {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                self.errorMessage = "Could not find firebase uid"
                return
            }
            
            FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    print("Failed to fetch current user:", error)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No data found"
                    return
                    
                }
                
                self.chatUser = .init(data: data)
                FirebaseManager.shared.currentUser = self.chatUser
            }
        }
        
        func fetchCurrentGoogleUser() {
            guard let uid = GIDSignIn.sharedInstance.currentUser?.userID else {
                self.errorMessage = "Could not find firebase uid"
                return
            }
            
            FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    print("Failed to fetch current user:", error)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "No data found"
                    return
                    
                }
                
                self.chatUser = .init(data: data)
                FirebaseManager.shared.currentUser = self.chatUser
            }
        }
        
        func handleSignOut() {
            isUserCurrentlyLoggedOut.toggle()
            
            try? FirebaseManager.shared.auth.signOut()
            GIDSignIn.sharedInstance.signOut()
        }
        
    }
    
}
