

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
        
        
        setKeyboardObervers()
    }
    func setKeyboardObervers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowObserver), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    
    @objc func keyboardShowObserver(notification: NSNotification) {
        self.scrollToEnd()
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
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeMovie as String]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


        if let vedioURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            // we selected a vedio
            handleSelectVedioForUrl(url: vedioURL)
        }
        else {
            // we selected an image
            handleSelectImageForInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func handleSelectVedioForUrl(url: URL){
        var UploadedVedioURL:String?
        let someFileName = "VedioFile.mp4"
        let storageRef =  Storage.storage().reference().child(someFileName)
        storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
            if let error = error {
                print("erro uploading vedio to storage")
                print(error.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (storageURL, error) in
                if let error = error {
                    print("error getting the uploaded vedio from storage")
                    print(error.localizedDescription)
                    return
                }
                UploadedVedioURL = storageURL?.absoluteString
                self.navigationItem.title = self.user?.name
                
                // write and send the vedio
                //"imageURL": imageURL
                if let thumbnailImage = self.thumbnailImageForFileURL(fileUrl: storageURL!) {
                    let values = ["imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "vedioURL": UploadedVedioURL as AnyObject] as [String : AnyObject]
                    self.sendmessageWithParameters(parameters: values)
                }
            })
            }.observe(.progress) { (snapshot) in
                self.navigationItem.title = "\(String(describing: (snapshot.progress?.completedUnitCount)!))"
        }
    }
    
    private func thumbnailImageForFileURL(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 600), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print("error generating thumbnail image")
            print(error)
            return nil
        }
    }
    
    
    func handleSelectImageForInfo(info: [UIImagePickerController.InfoKey : Any]){
        var selectedImageFormPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage{
            selectedImageFormPicker = editedImage
        } else if let originalImage = info [.originalImage] as? UIImage{
            selectedImageFormPicker = originalImage
        }
        
        if let selectedImage = selectedImageFormPicker {
            uploadImageMessage(image: selectedImage) { (imageUrl) in
                self.sendImageMessage(imageURL: imageUrl, image: selectedImage)
            }
        }
    }
    
    
    func uploadImageMessage(image: UIImage, completion: (_ urlString: String)->()){
        let imageName = NSUUID().uuidString
        var theStringValueOfImageURL: String?
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
                    theStringValueOfImageURL = url?.absoluteString
                })
            }
            completion(theStringValueOfImageURL!)
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
                    let message = Message(dictionary: dictionary)
//                    message.fromID = dictionary["fromID"] as? String
//                    message.text =  dictionary["text"] as? String
//                    message.timestamp = dictionary["timestamp"] as? NSNumber
//                    message.toID = dictionary["toID"] as? String
//                    message.imageURL = dictionary["imageURL"] as? String
                    
                    self.messagesList.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.scrollToEnd()
                    }
                    
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func scrollToEnd(){
        if messagesList.count > 1 {
            let indexItem = IndexPath(item: messagesList.count - 1, section: 0)
            collectionView.scrollToItem(at: indexItem, at: .top, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messagesList.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        
        cell?.chatLog = self
        
        let message = self.messagesList[indexPath.item]
        if let text = message.text {
            cell?.chatImageView.isHidden = true
            cell?.messageTextView.isHidden = false
            cell?.messageTextView.text = text
            cell?.bubbleViewWidth?.constant = estimatedFrameForText(text: message.text!).width + 38
        } else
        if let imageURL = message.imageURL {
            cell?.chatImageView.isHidden = false
            cell?.messageTextView.isHidden = true
            cell?.bubbleViewWidth?.constant = 200
            cell?.chatImageView.loadImageUsingCashWithURLString(urlString: imageURL)
        }
        
        performCellLayoutByMessage(cell: cell!, message: message)
        
        return cell!
    }
    
    func performCellLayoutByMessage(cell: ChatMessageCell, message: Message){
        if self.user?.id == message.fromID {
            // do gray
            if message.text != nil {
                cell.bubbleView.backgroundColor = ChatMessageCell.grayBubble
            } else {
                cell.bubbleView.backgroundColor = UIColor.clear
            }
            cell.messageTextView.textColor = UIColor.black
            cell.messageImageView.loadImageUsingCashWithURLString(urlString: user!.profielImageURL!)
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        } else {
            // do blue
            if message.text != nil {
                cell.bubbleView.backgroundColor = ChatMessageCell.blueBubble
            } else {
                cell.bubbleView.backgroundColor = UIColor.clear
            }
            cell.messageTextView.textColor = UIColor.white
            cell.messageImageView.image = nil
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let itemMessage = messagesList[indexPath.item]
        if let text = itemMessage.text {
            height = estimatedFrameForText(text: text).height + 30
        } else if itemMessage.imageURL != nil {
            if let imageHeigt = itemMessage.imageHeight, let imageWidth = itemMessage.imageWidth {
                // two similer reqtangles have same relation between their w and h
                // h1 / w1 = h2 / w2 means h1 = h2 / w2 * h1
                // where h1, w1 is the width and height of the bubble
                // and h2, w2 is the width and height of the image
                height = CGFloat(imageHeigt.floatValue / imageWidth.floatValue * 200)
            }
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
    
    @objc func sendmessageWithParameters(parameters: [String: AnyObject])
    {
        let ref = Database.database().reference().child("messages")
        let toID = self.user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp: NSNumber = NSNumber(value: NSDate().timeIntervalSince1970)
        let childRef = ref.childByAutoId()
        var values = ["toID": toID!, "fromID": fromID!, "timestamp": timeStamp] as [String : Any]
        parameters.forEach({values[$0] = $1})
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
    
    
    @objc func sendMessage(){
        let values = ["text": self.inputTextField.text!] as [String : Any]
        sendmessageWithParameters(parameters: values as [String : AnyObject])
        inputTextField.text = nil
        }
    
    func sendImageMessage(imageURL: String, image: UIImage){
        let values = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String : Any]
        sendmessageWithParameters(parameters: values as [String : AnyObject])
    }

    var startingImageView: UIImageView?
    let blackBackgroundView = UIView(frame: UIApplication.shared.keyWindow!.frame)
    var startingImageFrame: CGRect?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView){
        self.startingImageView = startingImageView
        self.startingImageFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomImageView = UIImageView(frame: self.startingImageFrame!)
//        zoomImageView.backgroundColor = UIColor.red
        zoomImageView.image = startingImageView.image
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOut)))
        if let keyWindow = UIApplication.shared.keyWindow {
            // get image height
            // h1/w1 = h2/w2
            //h1 = h2 / w1 * w2
            // h1, w1: key window image (zooming image) width and height
            // h2, w2: staring image width and height
            let height = keyWindow.frame.height / keyWindow.frame.width * startingImageView.frame.height
            self.blackBackgroundView.backgroundColor = UIColor.black
            self.blackBackgroundView.alpha = 0
            keyWindow.addSubview(self.blackBackgroundView)
            keyWindow.addSubview(zoomImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                let zoomImageFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomImageView.frame = zoomImageFrame
                zoomImageView.center = keyWindow.center
                self.blackBackgroundView.alpha = 1
                self.inputContainerView.alpha = 0
            }) { (completed) in
                self.startingImageView?.isHidden = true
            }
        }
    }

    @objc func performZoomOut(gesture: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.blackBackgroundView.alpha = 0
            self.inputContainerView.alpha = 1
            if let zoomOutImageView = gesture.view as? UIImageView {
                zoomOutImageView.frame = self.startingImageFrame!
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.layer.masksToBounds = true
            }
        }) { (completed) in
            gesture.view?.removeFromSuperview()
            self.startingImageView?.isHidden = false
        }
    }
}


