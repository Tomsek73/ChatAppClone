//
//  CreateNewMessageViewModel.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 20.01.2023.
//


import SwiftUI
import SDWebImageSwiftUI
import GoogleSignIn
import GoogleSignInSwift

extension CreateNewMessageView{
    
    @MainActor class CreateNewMessageViewModel: ObservableObject {
        
        @Published var users = [ChatUser]()
        @Published var errorMessage = ""
        @Published var query = ""
        
        init() {
            fetchAllUsers()
        }
        
        private func fetchAllUsers() {
            FirebaseManager.shared.firestore.collection("users")
                .getDocuments { documentsSnapshot, error in
                    if let error = error {
                        self.errorMessage = "Failed to fetch users: \(error)"
                        print("Failed to fetch users: \(error)")
                        return
                    }
                    
                    documentsSnapshot?.documents.forEach({ snapshot in
                        let data = snapshot.data()
                        let user = ChatUser(data: data)
                        if (user.uid != FirebaseManager.shared.auth.currentUser?.uid) && (user.uid != GIDSignIn.sharedInstance.currentUser?.userID){
                            self.users.append(.init(data: data))
                        }
                        
                    })
                }
        }
        
        func filterUsers(query: String)->[ChatUser]{
            if query == ""{
                return users
            }else{
                return users.filter{$0.email.lowercased().contains(query.lowercased())}
            }
        }
    }
    
}
