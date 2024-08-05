//
//  CreateNewMessageView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by EBRU KÖSE on 1.07.2024.
//

import SwiftUI
class CreateNewMessageViewModel: ObservableObject{
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init(){
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments{ documentSnapshot, error in
                if let error = error {
                    self.errorMessage = "failed to fetch users\(error)"
                    print("failed to fetch users:\(error)")
                    return
                }
                
                documentSnapshot?.documents.forEach({ snapshot  in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid !=
                        FirebaseManager.shared.auth.currentUser?.uid{
                        self.users.append(.init(data: data))
                    }
                })
                //self.errorMessage = "fetched users successfully"
            }
    }
}

struct CreateNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.email)
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("New message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}






