//
//  LoginController+Handlers.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/8/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit
import Firebase


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        var selectedImageFormPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImageFormPicker = editedImage
        } else if let originalImage = info [.originalImage] as? UIImage{
            selectedImageFormPicker = originalImage
        }
        
        if let selectedImage = selectedImageFormPicker {
            self.profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }

    func handleRegister(){
        // create auth user
        if let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (authdataresult, error) in
                if let error = error {
                    print("error craete user")
                    print(error.localizedDescription)
                    return
                }
                // auth user created now save user image
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
                if let image = self.profileImageView.image?.pngData() {
                    storageRef.putData(image, metadata: nil, completion: { (storedImageURL, error) in
                        if let error = error {
                            print("error saving image")
                            print(error.localizedDescription)
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            if let error = error {
                                print("could not catch image saved")
                                print(error.localizedDescription)
                                return
                            }
                            let imageURL = url?.absoluteString
                            // auth craeted and image saved create node in database
                            if let uid = Auth.auth().currentUser?.uid {
                                let dbRef = Database.database().reference().child("users").child(uid)
                                let values = ["name": name, "email": email, "profileImageURL": imageURL] as [String: AnyObject]
                                dbRef.updateChildValues(values, withCompletionBlock: { (error, databaseReference) in
                                    if let error = error {
                                        print("error creating user in database")
                                        print(error.localizedDescription)
                                        return
                                    }
                                    self.dismiss(animated: true, completion: nil)
                                })
                            }
                        })
                    })
                }
            }
        }
    }
    
    private func registerUserItoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                print("error creating user node in database")
                print(error.localizedDescription)
                return
            }
            // uesr node created in database
            self.dismiss(animated: true, completion: nil)
        })
    }

}
