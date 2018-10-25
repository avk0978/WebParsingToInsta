//
//  ErrorManager.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 13.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit

class ErrorManager {
    
    
    static func instagrammMessage() -> UIAlertController {
        let ac = UIAlertController(title: NSLocalizedString("ERROR", comment: ""),
                                   message: NSLocalizedString("Instagramm application is not installed", comment: ""),
                                   preferredStyle: .alert)
        let oK = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .default)
        ac.addAction(oK)
        return ac
    }
    
    static func errorDelete() -> UIAlertController {
        let ac = UIAlertController(title: NSLocalizedString("ERROR", comment: ""),
                                   message: NSLocalizedString("Uninstall error", comment: ""),
                                   preferredStyle: .alert)
        let oK = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .default) { (action) in
            NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
        }
        ac.addAction(oK)
        return ac
    }
    
    static func nameMutch() -> UIAlertController {
        let ac = UIAlertController(title: NSLocalizedString("ERROR", comment: ""),
                                   message: NSLocalizedString("This name already exists", comment: ""),
                                   preferredStyle: .alert)
        let oK = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .default) { (action) in
            NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
        }
        ac.addAction(oK)
        return ac
    }
    
    static func defaultLink() -> UIAlertController {
        let ac = UIAlertController(title: NSLocalizedString("ERROR", comment: ""),
                                   message: NSLocalizedString("This link is used to load the default site. To remove it, assign another link by default", comment: ""),
                                   preferredStyle: .alert)
        let oK = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .default)
        ac.addAction(oK)
        return ac
    }
    
    static func noСonnectionToSite() -> UIAlertController {
        let ac = UIAlertController(title: NSLocalizedString("ERROR", comment: ""),
                                   message: NSLocalizedString("Failed to load site. Check your internet connection and correct address", comment: ""),
                                   preferredStyle: .alert)
        let oK = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .default)
        ac.addAction(oK)
        return ac
    }
}
