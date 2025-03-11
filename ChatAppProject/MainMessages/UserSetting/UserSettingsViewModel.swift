//
//  UserSettingsViewModel.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 19.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

extension UserSettingsView{
    
   @MainActor class UserSettingsViewModel : ObservableObject {
       
       @Published var ShowImagePicker = false
       @Published var userEmail = ""
       @Published var userPassword = ""
       @Published var image: UIImage?
       @Published var imgURL: String = ""
       
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
                   self.updateUserInfo(imageProfileUrl: url.absoluteString)
               }
           }
       }
       
       func buttonUpdate(){
           if image != nil{
               persistImageToStorage()
           }
           updateUserInfo(imageProfileUrl: imgURL)
       }
       
       func updateUserInfo(imageProfileUrl: String){
           
           let currentUserEmail = FirebaseManager.shared.currentUser?.email
           let userID = FirebaseManager.shared.currentUser?.uid
           let currentUser = FirebaseManager.shared.auth.currentUser
           
           
           if image != nil{
               FirebaseManager.shared.firestore.collection("users").document("\(userID ?? "")").updateData(["profileImageUrl": imageProfileUrl])
               
           }
           
           if userEmail != ""{
               FirebaseManager.shared.firestore.collection("users").document("\(userID ?? "")").updateData(["email": userEmail])
               if userEmail != currentUserEmail{
                   currentUser?.updateEmail(to: userEmail){ error in
                       if let error = error{
                           print(error.localizedDescription)
                       }
                   }
               }
               
           }
           
           if userPassword != ""{
               currentUser?.updatePassword(to: userPassword){ error in
                   if let error = error{
                       print(error.localizedDescription)
                   }
               }
           }
       }

    }
    
    
    
}
