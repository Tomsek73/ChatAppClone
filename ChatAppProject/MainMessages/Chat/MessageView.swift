//
//  MessageView.swift
//  ChatAppProject
//
//  Created by Tomáš Zatloukal on 22.01.2023.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SpriteKit
import SDWebImageSwiftUI

struct MessageView: View {
    let message: ChatMessage
    var body: some View {
        VStack {
            if (message.fromId == FirebaseManager.shared.auth.currentUser?.uid) || (message.fromId == GIDSignIn.sharedInstance.currentUser?.userID) {
                HStack
                {
                    Spacer()
                    VStack {
                        Text(message.text)
                            .foregroundColor(.white)
                            .padding()
                        
                        if message.profileImageUrl != ""{
                            WebImage(url: URL(string: message.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                
                        }
                    }
                    .background(message.text == "" ? Color(.init(white: 0.95, alpha: 1)) : Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack
                {
                    VStack {
                        Text(message.text)
                            .foregroundColor(.black)
                            .padding()
                        
                        if message.profileImageUrl != ""{
                            WebImage(url: URL(string: message.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                
                        }
                    }
                    .background(message.text == "" ? Color(.init(white: 0.95, alpha: 1)) : Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
