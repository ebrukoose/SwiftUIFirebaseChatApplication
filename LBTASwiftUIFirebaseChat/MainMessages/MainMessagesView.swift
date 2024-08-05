//
//  MainMessagesView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by EBRU KÖSE on 29.06.2024.
//

import SwiftUI

import SwiftUI
import Firebase




class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut =
            FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
     func  fetchCurrentUser(){
        
        guard let uid =
                FirebaseManager.shared.auth.currentUser?
            .uid else{
            self.errorMessage = "couldnt find firebase uid"
            return
        }
        
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument{ snapshot, error in
                if let error = error {
                    self.errorMessage = "faild to fetch current user:\(error)"
                    
                    print("faild to fetch current user:", error)
                    return
                }
                
                self.errorMessage = "123"
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "NO data found "
                    return}
              //  print(data)
               // self.errorMessage = "Data: \(data.description)"
                self.chatUser = .init(data: data)
                
                
          //      self.errorMessage = chatUser.profileImageUrl
            }
    }
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
       try? FirebaseManager.shared.auth.signOut()
    }
}






struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @State var shouldShowNewMessageScreen = false
    @State var selectedChatUser: ChatUser?
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    if let user = selectedChatUser {
                        ChatLogView(chatUser: user)
                    }
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom
            )
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: " ") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        Text("destination")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                            
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                self.selectedChatUser = user
                self.shouldNavigateToChatLogView = true
            }
        }
    }
}








/* chatlogu taşımadan önceki yeri
struct ChatLogView: View {
    let chatUser: ChatUser?
    
    var body: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                Text("fake message for now")
            }
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}*/


/*
adamınki
class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut =
            FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
     func  fetchCurrentUser(){
        
        guard let uid =
                FirebaseManager.shared.auth.currentUser?
            .uid else{
            self.errorMessage = "couldnt find firebase uid"
            return
        }
        
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument{ snapshot, error in
                if let error = error {
                    self.errorMessage = "faild to fetch current user:\(error)"
                    
                    print("faild to fetch current user:", error)
                    return
                }
                
                self.errorMessage = "123"
                
                guard let data = snapshot?.data() else { 
                    self.errorMessage = "NO data found "
                    return}
              //  print(data)
               // self.errorMessage = "Data: \(data.description)"
                self.chatUser = .init(data: data)
                
                
          //      self.errorMessage = chatUser.profileImageUrl
            }
    }
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
       try? FirebaseManager.shared.auth.signOut()
    }
}









struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    
    var body: some View {
        NavigationView {
            
            VStack {
               // Text("User:\(vm.chatUser?.uid ?? "")")
                customNavBar
                messagesView
                NavigationLink("",isActive:$shouldNavigateToChatLogView){
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                let email=vm.chatUser?.email.replacingOccurrences(of:"@gmail.com", with:" ") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                    .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil)
        {
            LoginView(didCompleteLoginProcess: {self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()})
        }
    }
    
 
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                            Text("destination")} label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .padding(8)
                                        .overlay(RoundedRectangle(cornerRadius: 44)
                                                    .stroke(Color(.label), lineWidth: 1)
                                        )
                                    
                                    
                                    VStack(alignment: .leading) {
                                        Text("Username")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Message sent to user")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(.lightGray))
                                    }
                                    Spacer()
                                    
                                    Text("22d")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                        
                    }

                   
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }
    }
    @State var shouldShowNewMessageScreen = false
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
            
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen ) {
            CreateNewMessageView(didSelectNewUser: {user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    @State var chatUser: ChatUser?
}
struct ChatLogView: View {
    let chatUser: ChatUser?
    var body: some View{
        ScrollView{
            ForEach(0..<10, id: \.self) { num in
                Text("fake message for now ")
            }
            
        }.navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

*/
