//
//  DatabaseManager.swift
//  SampleCrypto
//
//  Created by Administrator on 2/2/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(email:String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public enum DatabaseError:Error{
        case failedToFetch
    }
   
}

// MARK: - Account Management

extension DatabaseManager{
    /// Validates a user in database
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard  snapshot.value as? String != nil else{
                //return false when email doesn't exist
                completion(false)
                return
            }
            //return true if email exists
            completion(true)
        })
    }
    
    /// Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Bool)-> Void){
        let safeEmail = DatabaseManager.safeEmail(email: user.emailAddress)
        database.child(safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ]) { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            /// Create new collection table in database to save expensive db calls
            /*
             [
                [
                    "name":
                    "safe_email":
                ],
                [
                    "name":
                    "safe_email":
                ]
             ]
             */
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            return
                        }
                        completion(true)
                    })
                }
                else{
                    //create that array - only occurs in very first user
                    let newCollection: [[String:String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            return
                        }
                        completion(true)
                    })
                }
            })
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String:String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String:String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

// MARK: - Messages
extension DatabaseManager{
    /*
     
     "uniqueID" {
        "messages" : [
             {
                "id": String
                "type": text, photo, video
                "content": String
                "date":Date()
                "sender_email":String
                "isRead": true/false
             }
        ]
     }
     
     Conversation => [
        [
            "conversation_id": "uniqueID"
            "other_user_email":
            "latest_message": => {
                "date": Date()
                "latest_message: "message"
                "is_read": true/false
            }
        ],
     ]
     */
    
    ///Creates new conversation with other user and first message sent
    public func createNewConversation(with otherUserEmail:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: {snapshot in
            guard var userNode = snapshot.value as? [String:Any] else{
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateformatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind{
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String:Any] = [
                "id":conversationId,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "latest_message": message,
                    "is_read":false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                //conversation array exists for current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationId: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
            else{
                //this is a new conversation
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(conversationId: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConversation(conversationId:String, firstMessage: Message, completion: @escaping (Bool) -> Void){

//                   "id": String
//                   "type": text, photo, video
//                   "content": String
//                   "date":Date()
//                   "sender_email":String
//                   "isRead": true/false
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateformatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind{
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let safeCurrentUserEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        let collectionMessage:[String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date":dateString,
            "sender_email":safeCurrentUserEmail,
            "is_read": false
        ]
        
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationId)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }

    }
    
    ///Fetches and returns all conversation with email
    public func getAllConversations(for email:String, completion: @escaping (Result<String,Error>) -> Void){
        
    }
    
    ///Fetches all messages for given conversation
    public func getAllMessagesForConversation(with conversationId:String, completion: @escaping (Result<String,Error>)->Void){
        
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation:String, message: Message, completion: @escaping (Bool)-> Void){
        
    }
    
}


struct User{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName:String{
        //sample: dvdlk100@hotmail.com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
