import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SpriteKit
import SDWebImageSwiftUI


struct ChatLogView: View {
    
    
    
    @StateObject var vm: ChatLogViewModel
    
    
    
    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            vm.firestoreListener?.remove()
        }
        
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        VStack {
            if #available(iOS 15.0, *) {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack {
                            ForEach(vm.chatMessages) { message in
                                MessageView(message: message)
                            }
                            
                            HStack{ Spacer() }
                                .id(Self.emptyScrollToString)
                        }
                        .onReceive(vm.$count) { _ in
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                .safeAreaInset(edge: .bottom) {
                    chatBottomBar
                        .background(Color(.systemBackground).ignoresSafeArea())
                }
            } else {
                // Fallback on earlier versions
            }
        }
        .fullScreenCover(isPresented: $vm.ShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $vm.image)
                .ignoresSafeArea()
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            if let image = vm.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        vm.ShowImagePicker.toggle()
                    }
            }
            else{
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
                    .onTapGesture {
                        vm.ShowImagePicker.toggle()
                    }
                
            }
            ZStack {
                
                
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                
            }
            .frame(height: 40)
            
            Button {
                vm.buttonHandleMessageSend()
                
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 24))
                    .rotationEffect(.init(degrees: 45))
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(24)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    

    
    private struct DescriptionPlaceholder: View {
        var body: some View {
            
            HStack {
                Text("Description")
                    .foregroundColor(Color(.gray))
                    .font(.system(size: 17))
                    .padding(.leading, 5)
                    .padding(.top, -4)
                Spacer()
            }
        }
    }
    
    struct ChatLogView_Previews: PreviewProvider {
        static var previews: some View {
            MainMessagesView()
        }
    }
}
