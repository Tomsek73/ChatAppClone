//
//  LoginView.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 11.01.2023.
//

import SwiftUI
import Firebase

import GoogleSignIn
import GoogleSignInSwift


struct LoginView: View {
    
    @StateObject var vm: LoginViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                    
                    VStack(spacing: 16) {
                        Picker(selection: $vm.isLoginMode, label: Text("Picker here")) {
                            Text("Login")
                                .tag(true)
                            Text("Create Account")
                                .tag(false)
                        }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.mint)
                             
                        
                        Text(vm.isLoginMode ? "Log In" : "Create Account")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        if !vm.isLoginMode {
                            Button {
                                vm.shouldShowImagePicker.toggle()
                            } label: {
                                
                                VStack {
                                    if let image = vm.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 128, height: 128)
                                            .cornerRadius(64)
                                    } else {
                                        Image(systemName: "photo.circle")
                                            .font(.system(size: 128))
                                            .padding()
                                            .foregroundColor(Color(.label))
                                    }
                                }
      
                            }
                        }
                        
                        VStack {
                            HStack{
                                
                                Image(systemName: "envelope.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.leading, 3)
                                
                                TextField("Email", text: $vm.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding(.leading, 12).font(.system(size: 20))
                                
                            }
                            .padding(12)
                            .background(Color(.white))
                            .cornerRadius(20)
                            
                            HStack{
                                
                                Image(systemName: "lock.fill")
                                    .resizable()
                                    .frame(width: 15, height: 20)
                                    .padding(.leading, 3)
                                
                                SecureField("Password", text: $vm.password)
                                    .padding(.leading, 12).font(.system(size: 20))
                            }
                            .padding(12)
                            .background(Color(.white))
                            .cornerRadius(20)
                            
                            
                            Spacer()
                            
                            Button {
                                vm.handleAction()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(vm.isLoginMode ? "Log In" : "Create Account")
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
                        Spacer()
                        if vm.isLoginMode{
                            
                            GoogleSignInButton{
                                vm.googleButtonLogin()
                                vm.didCompleteLoginProcess()
                            }
                            .cornerRadius(20)
                        }

                    }
                    .padding()
                
            }
            .navigationBarHidden(true)
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $vm.shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $vm.image)
                .ignoresSafeArea()
        }
    }
    
    
    
    
    
    
}


