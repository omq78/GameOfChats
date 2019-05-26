//
//  ChatMessageCell.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/27/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
       return tv
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(messageTextView)
        
        // IOS 9 constraints
        // need x, y, width and height
        messageTextView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        messageTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageTextView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
