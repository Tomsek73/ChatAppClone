//
//  ChatLogViewModel.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 20.01.2023.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SpriteKit


extension ChatLogView{
    
    @MainActor class ChatLogViewModel: ObservableObject {
        @Published var ShowImagePicker = false
        @Published var chatText = ""
        @Published var errorMessage = ""
        @Published var image: UIImage?
        @Published var imgURL: String = ""
        @Published var chatMessages = [ChatMessage]()
        
        
        var chatUser: ChatUser?
        
        
        
        init(chatUser: ChatUser?) {
            self.chatUser = chatUser
    
            fetchGoogleMessages()
            
            
            fetchMessages()
            
        }
        
        var firestoreListener: ListenerRegistration?
        
       
        func buttonHandleMessageSend(){
            if GIDSignIn.sharedInstance.currentUser != nil{
               
                if image != nil{
                    persistImageToStorage()
                }else{
                    handleGoogleSend()
                }
            }
            else{
                if image != nil{
                    persistImageToStorage()
                }else{
                    handleSend()
                }
            }
        }
        
        func fetchMessages() {
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            guard let toId = chatUser?.uid else { return }
            firestoreListener?.remove()
            chatMessages.removeAll()
            firestoreListener = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.messages)
                .document(fromId)
                .collection(toId)
                .order(by: FirebaseConstants.timestamp)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        if change.type == .added {
                            let data = change.document.data()
                            self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.count += 1
                    }
                }
        }
        
        
        func fetchGoogleMessages() {
            guard let fromId = GIDSignIn.sharedInstance.currentUser?.userID else { return }
            guard let toId = chatUser?.uid else { return }
            firestoreListener?.remove()
            chatMessages.removeAll()
            firestoreListener = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.messages)
                .document(fromId)
                .collection(toId)
                .order(by: FirebaseConstants.timestamp)
                .addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to listen for messages: \(error)"
                        print(error)
                        return
                    }
                    
                    querySnapshot?.documentChanges.forEach({ change in
                        if change.type == .added {
                            let data = change.document.data()
                            self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.count += 1
                    }
                }
        }
        
        func persistImageToStorage() {
    //        let filename = UUID().uuidString
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
            ref.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    print("Failed to push image to Storage: \(err)")
                    return
                }
                
                ref.downloadURL { url, err in
                    if let err = err {
                        print("Failed to retrieve downloadURL: \(err)")
                        return
                    }
                    print("Successfully stored image with url: \(url?.absoluteString ?? "")")
                    
                    print(url?.absoluteString ?? "")
                    
                    guard let url = url else { return }
                    self.imgURL = url.absoluteString
                    
                    if GIDSignIn.sharedInstance.currentUser != nil{
                        self.handleGoogleSend(imageProfileUrl: url.absoluteString)
                    }else{
                        self.handleSend(imageProfileUrl: url.absoluteString)
                    }
                    
                }
            }
        }

        
        func handleSend(imageProfileUrl: String = "") {
            
            print(chatText)
            guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
            
            guard let toId = chatUser?.uid else { return }
            
            let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                .document(fromId)
                .collection(toId)
                .document()
            
            
            let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp(), FirebaseConstants.profileImageUrl: imageProfileUrl.isEmpty ? "" : imageProfileUrl] as [String : Any]
            
            document.setData(messageData) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Successfully saved current user sending message")
                      
                self.persistRecentMessage()

                self.chatText = ""
                self.imgURL = ""
                self.image = nil
                self.count += 1
                
                
            }
            
            let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
                .document(toId)
                .collection(fromId)
                .document()
            
            recipientMessageDocument.setData(messageData) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Recipient saved message as well")
            }
        }
        
        func handleGoogleSend(imageProfileUrl: String = "") {
            
            print(chatText)
            guard let fromId = GIDSignIn.sharedInstance.currentUser?.userID else { return }
            
            guard let toId = chatUser?.uid else { return }
            
            let document = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
                .document(fromId)
                .collection(toId)
                .document()
            
            let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp(), FirebaseConstants.profileImageUrl: imageProfileUrl.isEmpty ? "" : imageProfileUrl] as [String : Any]
            
            document.setData(messageData) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Successfully saved current user sending message")
               
                self.persistRecentGoogleMessage()
                self.imgURL = ""
                self.image = nil
                self.chatText = ""
                self.count += 1
            }
            
            let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
                .document(toId)
                .collection(fromId)
                .document()
            
            recipientMessageDocument.setData(messageData) { error in
                if let error = error {
                    print(error)
                    self.errorMessage = "Failed to save message into Firestore: \(error)"
                    return
                }
                
                print("Recipient saved message as well")
            }
        }
        
        private func persistRecentMessage() {
            guard let chatUser = chatUser else { return }
            
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            guard let toId = self.chatUser?.uid else { return }
            
            let document = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .document(toId)
            
            let data = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                FirebaseConstants.email: chatUser.email
            ] as [String : Any]
            
            // you'll need to save another very similar dictionary for the recipient of this message...how?
            
            document.setData(data) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message: \(error)"
                    print("Failed to save recent message: \(error)")
                    return
                }
            }
            
            guard let currentUser = FirebaseManager.shared.currentUser else { return }
            let recipientRecentMessageDictionary = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
                FirebaseConstants.email: currentUser.email
            ] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(toId)
                .collection("messages")
                .document(currentUser.uid)
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
                }
        }
        
        private func persistRecentGoogleMessage() {
            guard let chatUser = chatUser else { return }
            
            guard let uid = GIDSignIn.sharedInstance.currentUser?.userID else { return }
            guard let toId = self.chatUser?.uid else { return }
            
            let document = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .document(toId)
            
            let data = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                FirebaseConstants.email: chatUser.email
            ] as [String : Any]
            
            // you'll need to save another very similar dictionary for the recipient of this message...how?
            
            document.setData(data) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message: \(error)"
                    print("Failed to save recent message: \(error)")
                    return
                }
            }
            
            
            
            guard let currentUser = GIDSignIn.sharedInstance.currentUser else { return }
            let recipientRecentMessageDictionary = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: currentUser.profile?.imageURL(withDimension: 300)?.absoluteString ?? "",
                FirebaseConstants.email: currentUser.profile?.email ?? ""
            ] as [String : Any]
            
            FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(toId)
                .collection("messages")
                .document(currentUser.userID ?? "")
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
                }
        }
        
        
        
        @Published var count = 0
    }
    
}
