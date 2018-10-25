//
//  ImageCollectionVC.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 25.08.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit
import CoreData

protocol closePopoverVCDelegate: class {
    func closePopoverVC()
}

class ImageCollectionVC: UICollectionViewController, CoreDataMethods {
    
    weak var delegate: closePopoverVCDelegate?
    var pictures: [Pictures] = []
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pictures = loadDataInImageCollectionFromPictures()
    }

  
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
        
        if let image = pictures[indexPath.row].picture {
            cell.image.image = UIImage(data: image)
        } else { print("Image upload failed") }
        
        return cell
    }


    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //Локализация текстовых сообщений
        let captionViewer: String = NSLocalizedString("View image", comment: "")
        let postToInstagram: String = NSLocalizedString("Post to Instagram", comment: "")
        let messageDeleteImage: String = NSLocalizedString("Delete image", comment: "")
        let exit: String = NSLocalizedString("Exit", comment: "")
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewImage = UIAlertAction(title: captionViewer, style: .default) { (action) in
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewer") as? ImageViewer else { return }
            let cell = collectionView.cellForItem(at: indexPath) as! ImageViewCell
            vc.image = cell.image.image
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let sendToInsta = UIAlertAction(title: postToInstagram, style: .default) { (action) in
            let cell = collectionView.cellForItem(at: indexPath) as! ImageViewCell
            let instagramApp = InstagramManager.share
            if instagramApp.postImageToInstagramWithCaption(imageInstagram: cell.image.image!, view: self.view) == false {
                self.present(ErrorManager.instagrammMessage(), animated: true)
            }
        }
        let deleteImage = UIAlertAction(title: messageDeleteImage, style: .default) { (action) in
            guard self.deleteImageForPicturesAt(indexPath) else {
                self.present(ErrorManager.errorDelete(), animated: true)
                return
            }
            self.pictures.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }
        let cancel = UIAlertAction(title: exit, style: .cancel)
        
        ac.addAction(viewImage)
        ac.addAction(sendToInsta)
        ac.addAction(deleteImage)
        ac.addAction(cancel)
        present(ac, animated: true)
        
        return true
    }

}
