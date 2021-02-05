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
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ]) { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

struct User{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var profilePictureFileName:String{
        //sample: dvdlk100@hotmail.com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail:String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
