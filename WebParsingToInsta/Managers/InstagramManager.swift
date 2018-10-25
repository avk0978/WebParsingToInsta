//
//  InstagramManager.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 25.08.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import Foundation
import UIKit


class InstagramManager {
    
    var documentInteractionController = UIDocumentInteractionController()
    
    // singleton pattern
    static var share = InstagramManager()
    private init() {}
    
    // Передает изображение в инстаграм (без коментариев!!! ))))
    func postImageToInstagramWithCaption(imageInstagram: UIImage,view: UIView) -> Bool {
        
        let instagramURL = NSURL(string: "https://instagram://app")
        
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
            
            do {
                try imageInstagram.jpegData(compressionQuality: 1.0)?.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
            } catch {
                print(error)
            }
            
            let rect = CGRect(x: 0, y: 0, width: 612, height: 612)
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            documentInteractionController.url = fileURL
            documentInteractionController.uti = "com.instagram.exclusivegram"
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
            return true
        } else {
            return false
        }
    }
}
