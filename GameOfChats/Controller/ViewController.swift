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
        // Do any additional setup after loading the view.

//        let ref = Database.database().reference()
//        ref.updateChildValues(["some value":123123] as [String: Any])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    @objc func handleLogout(){
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

