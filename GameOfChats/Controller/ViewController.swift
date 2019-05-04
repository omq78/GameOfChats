//
//  ViewController.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/1/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if Auth.auth().currentUser?.uid == nil {
            // no user logged
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        } catch let logoutErorr {
            print("Error try to log out")
            print(logoutErorr.localizedDescription)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

