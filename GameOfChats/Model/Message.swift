//
//  Message.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/20/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit
import Firebase


class Message: NSObject {
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    
    var text: String?

    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(dictionary: [String: AnyObject]){
        self.fromID = dictionary["fromID"] as? String
        self.toID = dictionary["toID"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.text = dictionary["text"] as? String
        self.imageURL = dictionary["imageURL"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
    }
    
    func chatPartnerID() -> String {
        return (Auth.auth().currentUser?.uid == fromID ? toID : fromID)!
    }
}

