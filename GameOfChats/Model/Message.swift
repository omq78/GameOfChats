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
    var text: String?
    var timestamp: NSNumber?
    var toID: String?
    var imageURL: String?
    
    func chatPartnerID() -> String {
        return (Auth.auth().currentUser?.uid == fromID ? toID : fromID)!
    }
}

