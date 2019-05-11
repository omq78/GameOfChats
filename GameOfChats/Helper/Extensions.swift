//
//  Extensions.swift
//  GameOfChats
//
//  Created by Omar Alqabbani on 5/12/19.
//  Copyright © 2019 OmarALqabbani. All rights reserved.
//

import UIKit


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCashWithURLString(urlString: String) {
        
        self.image = nil
        
        if let image = imageCache.object(forKey: urlString as AnyObject ) as? UIImage {
            self.image = image
            return
        }

        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("error downlaod iamge")
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            }.resume()
    }
}
