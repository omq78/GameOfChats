//
//  ViewController.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/1/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "newmessageicon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        checkIfUserLoggedIn()
        
        observeMessages()
    }
    
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.fromID = dictionary["fromID"] as? String
                message.toID = dictionary["toID"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? NSNumber
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CELLID")
        cell.textLabel?.text = messages[indexPath.row].toID
        cell.detailTextLabel?.text = messages[indexPath.row].text
        return cell
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            // no user logged
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("for some reason logged user id is null")
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profielImageURL = dictionary["profileImageURL"] as? String
                self.setupNavBarWithUser(user: user)
//                self.navigationItem.title = dictionary["name"] as? String
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        let containerView = UIView()
        
//        titleView.backgroundColor = UIColor.red
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleView
        
        
        let titleImageView = UIImageView()
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.contentMode = .scaleAspectFill
        titleImageView.layer.cornerRadius = 20
        titleImageView.clipsToBounds = true
        if let userImageURL = user.profielImageURL {
            titleImageView.loadImageUsingCashWithURLString(urlString: userImageURL)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = user.name
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        

        titleView.addSubview(containerView)
        containerView.addSubview(titleImageView)
        containerView.addSubview(titleLabel)

        // ios 9 constraints
        // need x, y, width and height
        titleImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        titleImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        titleImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        titleImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: titleImageView.rightAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleImageView.centerYAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: titleImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
//        self.navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    @objc func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        } catch let logoutErorr {
            print("Error try to log out")
            print(logoutErorr.localizedDescription)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
}

