//
//  StorageManager.swift
//  SampleCrypto
//
//  Created by Administrator on 2/4/21.
//

import Foundation
import FirebaseStorage


final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    /// Upload pictures to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data:Data, fileName: String, completionHandler: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else{
                //failed
                print("failed to upload data to firebase for profile pic")
                completionHandler(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else{
                    print("")
                    completionHandler(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completionHandler(.success(urlString))
            }
        }
        
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path:String, completion: @escaping  (Result<URL,Error>)->Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
