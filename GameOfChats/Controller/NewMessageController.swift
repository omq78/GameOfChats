//
//  NewMessageControllerTableViewController.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/5/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellID = "cellID"
    var users = [User]()
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        fetchUser()
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profielImageURL = dictionary["profileImageURL"] as? String
                self.users.append(user)
                
                //this will crash because of the back ground thread, so lets use dispatch asynch to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // we use a hack for now actullay we need to dequeue our cells for memory effeciency
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImage = user.profielImageURL {
            cell.profileImageView.loadImageUsingCashWithURLString(urlString: profileImage)
//            let url = URL(string: profileImage)
//            URLSession.shared.dataTask(with: url!) { (data, response, error) in
//                if let error = error {
//                    print("error downlaod iamge")
//                    print(error.localizedDescription)
//                    return
//                }
//                DispatchQueue.main.async {
//                    cell.profileImageView.image = UIImage(data: data!)
//                }
//            }.resume()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
