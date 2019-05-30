

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            obsereMessages()
        }
    }
    
    let cellId = "cellId"
    
    var messagesList = [Message]()
    override func viewDidLoad() {
         super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        setupInputComponents()
    }
    
    func obsereMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messagesKey = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messagesKey)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.fromID = dictionary["fromID"] as? String
                    message.text =  dictionary["text"] as? String
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    message.toID = dictionary["toID"] as? String
                    
                    if message.chatPartnerID() == self.user!.id {
                        self.messagesList.append(message)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messagesList.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        
        let message = self.messagesList[indexPath.item]
        cell?.messageTextView.text = message.text
        
        cell?.bubbleViewWidth?.constant = estimatedFrameForText(text: message.text!).width + 38
        
        performCellLayoutByMessage(cell: cell!, message: message)
        
        return cell!
    }
    
    func performCellLayoutByMessage(cell: ChatMessageCell, message: Message){
        if self.user?.id == message.fromID {
            // do gray
            cell.bubbleView.backgroundColor = ChatMessageCell.grayBubble
            cell.messageTextView.textColor = UIColor.black
            cell.messageImageView.loadImageUsingCashWithURLString(urlString: user!.profielImageURL!)
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        } else {
            // do blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueBubble
            cell.messageTextView.textColor = UIColor.white
            cell.messageImageView.image = nil
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messagesList[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 30
        }
        
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
        
    }()

    func setupInputComponents(){
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //IOS 9 Constraints
        // neex x, y, width and height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)

        // neex x, y, width and height
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        // neex x, y, width and height
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.black
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)

        // neex x, y, width and height
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
    @objc func sendMessage(){
        let ref = Database.database().reference().child("messages")
        let toID = self.user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let childRef = ref.childByAutoId()
        let values = ["text": self.inputTextField.text!, "toID": toID!, "fromID": fromID!, "timestamp": timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Can not insert message Record")
                print(error.localizedDescription)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromID!)
            if let messageID = childRef.key {
                userMessagesRef.updateChildValues([messageID: "OO"])
            }
            
            let recipientMessageRef = Database.database().reference().child("user-messages").child(toID!)
            if let messageID = childRef.key {
                recipientMessageRef.updateChildValues([messageID: "00"])
            }
        }
        // user messages link
        //clear input text
        inputTextField.text = nil
    }
}


