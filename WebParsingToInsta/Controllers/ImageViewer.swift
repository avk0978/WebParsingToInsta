//
//  ImageViewer.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 03.10.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit

class ImageViewer: UIViewController {    
    
    @IBOutlet weak var picture: UIImageView!
    
    weak var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picture.image = image
    }
    
}
