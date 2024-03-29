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
    var messagesDictionary = [String: Message]()
    
    var cellID = "CellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "newmessageicon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        checkIfUserLoggedIn()
        
//        observeMessages()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let loginID = Auth.auth().currentUser?.uid
        let messageToId = messages[indexPath.row].chatPartnerID()
        Database.database().reference().child("user-messages").child(loginID!).child(messageToId).removeValue { (error, ref) in
            if let error = error {
                print("Error deleting message")
                print(error)
                return
            }
            
            self.messagesDictionary.removeValue(forKey: messageToId)
            self.attemptReloadTable()
        }
    }
    
    
    
    func observeUserMessages(){
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(userID)
        ref.observe(.childAdded) { (snapshot) in
            let chatKey = snapshot.key
            let chatRef = ref.child(chatKey)
            
            chatRef.observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithId(messageId: messageID)

            }, withCancel: nil)
        }
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }, withCancel: nil)
        
    }

    private func fetchMessageWithId(messageId: String){
        let userMessagesRef = Database.database().reference().child("messages").child(messageId)
        userMessagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
//                message.fromID = dictionary["fromID"] as? String
//                message.toID = dictionary["toID"] as? String
//                message.text = dictionary["text"] as? String
//                message.timestamp = dictionary["timestamp"] as? NSNumber
                
                let chatPartnerID = message.chatPartnerID()
                self.messagesDictionary[chatPartnerID] = message
                self.attemptReloadTable()
            }
        }, withCancel: nil)    }
    
    private func attemptReloadTable(){
        self.reloadTiemr?.invalidate()
        self.reloadTiemr = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.performReloadData), userInfo: nil, repeats: false)
    }
    
    
    var reloadTiemr: Timer?
    
    @objc func performReloadData(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let selectedUser = message.chatPartnerID()
        let checkUser = User()
        let userRef = Database.database().reference().child("users").child(selectedUser)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                checkUser.id = selectedUser
                checkUser.name = dictionary["name"] as? String
                checkUser.email = dictionary["email"] as? String
                checkUser.profielImageURL = dictionary["profileImageURL"] as? String
            }
            self.showChatControllerForUser(user: checkUser)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        let  message = messages[indexPath.row]
        cell.message = message
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
        
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        observeUserMessages()

        
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

