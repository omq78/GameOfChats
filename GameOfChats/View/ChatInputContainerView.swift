//
//  ChatInputContainerView.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 6/16/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import Foundation
import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
   
    let sendButton = UIButton(type: .system)

    var chatLog: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLog, action: #selector(ChatLogController.sendMessage), for: .touchUpInside)

            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLog, action: #selector(ChatLogController.handleUploadTap)))
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
        
    }()

    let uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        return uploadImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)
        
        // need x, y, width and height
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        addSubview(inputTextField)
        // need x, y, width and height
        
        addSubview(uploadImageView)
        
        // need x, y, width and height
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo:
            centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.black
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        
        // neex x, y, width and height
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLog?.sendMessage()
        return true
    }

}
