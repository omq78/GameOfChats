//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/27/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    static let blueBubble = UIColor(r: 0, g: 137, b: 249)
    static let grayBubble = UIColor(r: 224, g: 224, b: 224)
    
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
       return tv
    }()
    
    
    let bubbleView: UIView = {
      let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.layer.cornerRadius = 16
        bubble.layer.masksToBounds = true
        bubble.backgroundColor = blueBubble
        return bubble
    }()
    
    
    let messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    var bubbleViewWidth: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(messageTextView)
        addSubview(messageImageView)

        // IOS 9 constraints
        // need x, y, width and height
//        messageTextView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        messageTextView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageTextView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
//        messageTextView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        // IOS 9 constraints
        // need x, y, width and height
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: messageImageView.rightAnchor, constant: 8)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        
        bubbleViewLeftAnchor?.isActive = false
        bubbleViewRightAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true


        messageImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        messageImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        messageImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
