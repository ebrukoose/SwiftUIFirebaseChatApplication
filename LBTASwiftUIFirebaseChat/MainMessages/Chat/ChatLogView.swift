//
//  ChatLogView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by EBRU KÖSE on 1.07.2024.
//




import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage



struct ChatLogView: View {
    let chatUser: ChatUser?
    @ObservedObject var vm = ChatLogViewModel()
    @State private var messageText = ""
    @State private var selectedImage: UIImage?
    @State private var imagePickerPresented = false
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(vm.messages) { message in
                    VStack {
                        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                            HStack {
                                Spacer()
                                VStack {
                                    if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                 .scaledToFit()
                                                 .frame(maxWidth: 200, maxHeight: 200)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                }
                            }
                        } else {
                            HStack {
                                VStack {
                                    if let imageUrl = message.imageUrl, let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                 .scaledToFit()
                                                 .frame(maxWidth: 200, maxHeight: 200)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    }
                                    Text(message.text)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
            
            HStack {
                Button {
                    imagePickerPresented.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                }
                .sheet(isPresented: $imagePickerPresented) {
                    ImagePicker(image: $selectedImage)
                }
                
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    vm.sendMessage(text: messageText, to: chatUser, image: selectedImage)
                    messageText = ""
                    selectedImage = nil
                }
            }
            .padding()
        }
        .onAppear {
            vm.fetchMessages(to: chatUser)
        }
    }
}

class ChatLogViewModel: ObservableObject {
    @Published var messages = [ChatMessage]()
    
    func fetchMessages(to chatUser: ChatUser?) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Failed to listen for messages: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        if let message = ChatMessage(data: data) {
                            DispatchQueue.main.async {
                                self.messages.append(message)
                            }
                        }
                    }
                }
            }
    }
    
    func sendMessage(text: String, to chatUser: ChatUser?, image: UIImage?) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        if let image = image {
            uploadImage(image) { url in
                if let url = url {
                    let data: [String: Any] = [
                        "fromId": fromId,
                        "toId": toId,
                        "text": text,
                        "timestamp": Timestamp(),
                        "imageUrl": url.absoluteString
                    ]
                    document.setData(data)
                    recipientDocument.setData(data)
                }
            }
        } else {
            let data: [String: Any] = [
                "fromId": fromId,
                "toId": toId,
                "text": text,
                "timestamp": Timestamp()
            ]
            document.setData(data)
            recipientDocument.setData(data)
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: UUID().uuidString)
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error)")
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve download URL: \(error)")
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
}

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Timestamp
    let imageUrl: String?
    
    init?(data: [String: Any]) {
        guard let fromId = data["fromId"] as? String,
              let toId = data["toId"] as? String,
              let text = data["text"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else { return nil }
        
        self.fromId = fromId
        self.toId = toId
        self.text = text
        self.timestamp = timestamp
        self.imageUrl = data["imageUrl"] as? String
        self.documentId = UUID().uuidString
    }
}



