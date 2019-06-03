

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        
//        setKeyboardObervers()
    }
    func setKeyboardObervers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowObserver), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHideObserver), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyboardShowObserver(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keybaordHeight = keyboardFrame?.height
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        containerViewButtomAnchor?.constant = -keybaordHeight!
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    lazy var inputContainerView: UIView = {
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width  , height: 50)
        containerView.backgroundColor = UIColor.white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        // need x, y, width and height
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        // need x, y, width and height

        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        // need x, y, width and height
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
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
        
        return containerView
    }()
    
    @objc func handleUploadTap(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
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
            uploadImageMessage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    func uploadImageMessage(image: UIImage){
        let imageName = NSUUID().uuidString
        if let imageData = image.jpegData(compressionQuality: 0.2) {
            let ref = Storage.storage().reference().child("message-images").child("\(imageName).jpg")
            ref.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("error uploading image message")
                    print(error.localizedDescription)
                    return
                }
                ref.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print("can not get the image back???")
                        print(error.localizedDescription)
                        return
                    }
                    self.sendImageMessage(imageURL: url!.absoluteString)
                })
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func keyboardHideObserver(notification: NSNotification){
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        containerViewButtomAnchor?.constant = -16
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func obsereMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let chatUserId = self.user!.id else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(chatUserId)
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
                    message.imageURL = dictionary["imageURL"] as? String
                    
                    self.messagesList.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
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
        
        
        if let text = message.text {
            cell?.messageTextView.text = text
            cell?.bubbleViewWidth?.constant = estimatedFrameForText(text: message.text!).width + 38
        }
        if let imageURL = message.imageURL {
            cell?.bubbleViewWidth?.constant = estimatedFrameForText(text: imageURL).width + 38
            cell?.chatImageView.loadImageUsingCashWithURLString(urlString: imageURL)
        }
        
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
    
    var containerViewButtomAnchor: NSLayoutConstraint?

    
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
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromID!).child(toID!)
            if let messageID = childRef.key {
                userMessagesRef.updateChildValues([messageID: "OO"])
            }
            
            let recipientMessageRef = Database.database().reference().child("user-messages").child(toID!).child(fromID!)
            if let messageID = childRef.key {
                recipientMessageRef.updateChildValues([messageID: "00"])
            }
        }
        // user messages link
        //clear input text
        inputTextField.text = nil
    }
    
    func sendImageMessage(imageURL: String){
        let ref = Database.database().reference().child("messages")
        let toID = self.user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let childRef = ref.childByAutoId()
        let values = ["imageURL": imageURL, "toID": toID!, "fromID": fromID!, "timestamp": timeStamp] as [String : Any]
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Can not insert message Record")
                print(error.localizedDescription)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromID!).child(toID!)
            if let messageID = childRef.key {
                userMessagesRef.updateChildValues([messageID: "OO"])
            }
            
            let recipientMessageRef = Database.database().reference().child("user-messages").child(toID!).child(fromID!)
            if let messageID = childRef.key {
                recipientMessageRef.updateChildValues([messageID: "00"])
            }
        }
        // user messages link
        //clear input text
        inputTextField.text = nil
    }
}


