//
//  UserSettingsView.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 16.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
struct UserSettingsView: View {
    
    @Binding var shouldNavigateToUserSettingsView: Bool
    @StateObject private var userViewModel = UserSettingsViewModel()
    
        
    var body: some View {
        NavigationView{
            VStack{
                
                Text("User Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                    if let image = userViewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .cornerRadius(64)
                            .onTapGesture {
                                userViewModel.ShowImagePicker.toggle()
                            
                            }
                    } else {
                        Image(systemName: "photo.circle")
                            .font(.system(size: 128))
                            .padding()
                            .foregroundColor(Color(.label))
                            .onTapGesture {
                                userViewModel.ShowImagePicker.toggle()
                            
                            }
                    }

                
                    HStack{
                        
                        Image(systemName: "envelope.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.leading, 3)
                        
                        TextField("Email", text: $userViewModel.userEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.leading, 12).font(.system(size: 20))
                            
                        
                    }
                    .padding(12)
                    .background(Color(.white))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    HStack{
                        
                        Image(systemName: "lock.fill")
                            .resizable()
                            .frame(width: 15, height: 20)
                            .padding(.leading, 3)
                        
                        SecureField("Password", text: $userViewModel.userPassword)
                            .padding(.leading, 12).font(.system(size: 20))
                    }
                    .padding(12)
                    .background(Color(.white))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    
                    Button {
                        userViewModel.buttonUpdate()
                        shouldNavigateToUserSettingsView.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.mint)
                        .cornerRadius(20)
                        
                    }
                    
                }
                .padding(.horizontal, 18)
                .toolbar{
                    Button("Cancel"){
                        shouldNavigateToUserSettingsView.toggle()
                        
                    }
                }
                
               
            }
            .navigationBarHidden(true)
            .padding()
            .fullScreenCover(isPresented: $userViewModel.ShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $userViewModel.image)
                                .ignoresSafeArea()
            }
        }
    
}



