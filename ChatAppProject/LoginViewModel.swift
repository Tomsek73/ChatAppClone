//
//  LoginViewModel.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 20.01.2023.
//

import Foundation
import Firebase

import GoogleSignIn
import GoogleSignInSwift

extension LoginView{
    
    
    @MainActor class LoginViewModel : ObservableObject{
        @Published var isLoginMode = false
        @Published var email = ""
        @Published var password = ""
        @Published var image: UIImage?
        @Published var shouldShowImagePicker = false
        @Published var loginStatusMessage = ""
        
        var didCompleteLoginProcess: () -> ()
        
        init(isLoginMode: Bool = false, email: String = "", password: String = "", image: UIImage? = nil, shouldShowImagePicker: Bool = false, loginStatusMessage: String = "", didCompleteLoginProcess: @escaping () -> Void) {
            self.isLoginMode = isLoginMode
            self.email = email
            self.password = password
            self.image = image
            self.shouldShowImagePicker = shouldShowImagePicker
            self.loginStatusMessage = loginStatusMessage
            self.didCompleteLoginProcess = didCompleteLoginProcess
        }
        
        func handleAction() {
            if isLoginMode {
    //            print("Should log into Firebase with existing credentials")
                loginUser()
            } else {
                createNewAccount()
    //            print("Register a new account inside of Firebase Auth and then store image in Storage somehow....")
            }
        }
        
        func googleButtonLogin(){
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootControler()){ usr, err in
                if let err = err{
                    print(err.localizedDescription)
                    return
                }
                if let usr{
                    self.logGoogleUser(u: usr.user)
                    self.storeGoogleUserInformation(u: usr.user)
                }
                
            }
        }
        
        func loginUser() {
            FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
                if let err = err {
                    print("Failed to login user:", err)
                    self.loginStatusMessage = "Failed to login user: \(err)"
                    return
                }
                
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
                
                self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
                
                self.didCompleteLoginProcess()
            }
        }
        
        func logGoogleUser(u: GIDGoogleUser) {
            Task{
                do{
                    
                    guard let idtoken = u.idToken?.tokenString else {return}
                    let accessToken = u.accessToken.tokenString
                    let credential = GoogleAuthProvider.credential(withIDToken: idtoken, accessToken: accessToken)
                    
                    try await Auth.auth().signIn(with: credential)
                    print("Google success")
                }catch {
                    print("error")
                }
            }
        }

        
        
        
        func createNewAccount() {
            if self.image == nil {
                self.loginStatusMessage = "You must select an avatar image"
                return
            }
            
            FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
                if let err = err {
                    print("Failed to create user:", err)
                    self.loginStatusMessage = "Failed to create user: \(err)"
                    return
                }
                
                print("Successfully created user: \(result?.user.uid ?? "")")
                
                self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
                
                self.persistImageToStorage()
            }
        }
        
        func persistImageToStorage() {
    //        let filename = UUID().uuidString
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let ref = FirebaseManager.shared.storage.reference(withPath: uid)
            guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
            ref.putData(imageData, metadata: nil) { metadata, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                    return
                }
                
                ref.downloadURL { url, err in
                    if let err = err {
                        self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                        return
                    }
                    
                    self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                    print(url?.absoluteString)
                    
                    guard let url = url else { return }
                    self.storeUserInformation(imageProfileUrl: url)
                }
            }
        }
        
        func storeUserInformation(imageProfileUrl: URL) {
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
            let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
            FirebaseManager.shared.firestore.collection("users")
                .document(uid).setData(userData) { err in
                    if let err = err {
                        print(err)
                        self.loginStatusMessage = "\(err)"
                        return
                    }
                    
                    print("Success")
                    
                    self.didCompleteLoginProcess()
                }
        }
        
        func storeGoogleUserInformation(u: GIDGoogleUser) {
            
             
            guard let uid = u.userID else { return }
            let userData = ["email": u.profile?.email, "uid": u.userID, "profileImageUrl": u.profile?.imageURL(withDimension: 300)?.absoluteString]
            FirebaseManager.shared.firestore.collection("users")
                .document(uid).setData(userData as [String : Any]) { err in
                    if let err = err {
                        print(err)
                        self.loginStatusMessage = "\(err)"
                        return
                    }
                    
                    print("Success")
                    
                    self.didCompleteLoginProcess()
                }
        }
        
    }
    
}
