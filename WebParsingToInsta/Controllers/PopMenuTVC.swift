//
//  PopMenuTVC.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 11.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit

// Делегирование (изменение цвета кнопки SelectButton в WebBrowser)
protocol ChangeSelectButtonColorDelegate: class {
    func  changeSelectButtonColor() -> Void
}


class PopMenuTVC: UITableViewController, CoreDataMethods {
    
    weak var delegateChangeColor: ChangeSelectButtonColorDelegate?
    let uploadImages = NSLocalizedString("Upload images", comment: "")
    let viewImages = NSLocalizedString("View images", comment: "")
    let saveLinkToWebsite = NSLocalizedString("Save link to website", comment: "")
    let listOfLinks = NSLocalizedString("List of links", comment: "")
    let deleteAllImages = NSLocalizedString("Delete all images", comment: "")
    
    var url = ""
    var menuItemNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closePopoverVC),
                                               name: Notification.Name("closePopopverVC"),
                                               object: nil)
        menuItemNames.append(uploadImages)
        menuItemNames.append(viewImages)
        menuItemNames.append(saveLinkToWebsite)
        menuItemNames.append(listOfLinks)
        menuItemNames.append(deleteAllImages)
    }
    
    @objc func closePopoverVC() {
        dismiss(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 300, height: tableView.contentSize.height)
    }
    
    //     popover view будет закрыт. SelectButton - меняет цвет
    override func viewWillDisappear(_ animated: Bool) {
        delegateChangeColor?.changeSelectButtonColor()
        NotificationCenter.default.post(name: NSNotification.Name("PopMenuClose"), object: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItemNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = menuItemNames[indexPath.row]
        cell.contentView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Локализация текстовых сообщений
        let enterSiteName: String = NSLocalizedString("Enter site name", comment: "")
        let siteNameWithImages: String = NSLocalizedString("Site name with images", comment: "")
        let ok: String = NSLocalizedString("OK", comment: "")
        let messageCancel: String = NSLocalizedString("Cancel", comment: "")
        
        switch indexPath.row {
        case 0:
            let image = RetrievingImages()
            image.downloadingDataFromPictures()
            
            DispatchQueue.global().async {
                image.loadingAndParsingHTML(url: self.url)
                let linksForDownload = image.links.filter({!image.linksInPictures.contains($0)})
                for element in linksForDownload {
                    image.downloadImagesBy(imageLink: element)
                }
                DispatchQueue.main.async {
                    let iCVC = self.storyboard?.instantiateViewController(withIdentifier: "navigationICVC")
                    self.present(iCVC!, animated: true)
                }
            }
            
        case 1:
            let iCVC = self.storyboard?.instantiateViewController(withIdentifier: "navigationICVC")
            self.present(iCVC!, animated: true)
        case 2:
            let ac = UIAlertController(title: nil, message: enterSiteName, preferredStyle: .alert)
            ac.addTextField { (textField: UITextField!) in
                textField.placeholder = siteNameWithImages
            }
            let oK = UIAlertAction(title: ok, style: .default) { (action) in
                let siteName = ac.textFields![0] as UITextField
                if siteName.text == "" { siteName.text = self.url} //Если пользователь не ввел название сайта то подставится ссылка
                if self.theSiteNameIsUnique(name: siteName.text!) { // Проверка на уникальность названия сайта
                    self.addSiteNameToEntitiesSites(name: siteName.text!, link: self.url, isActive: false)
                    self.dismiss(animated: true)
                } else {
                    self.present(ErrorManager.nameMutch(), animated: true)
                }
            }
            let cancel = UIAlertAction(title: messageCancel, style: .cancel) { (action) in
                self.dismiss(animated: true)
            }
            ac.addAction(oK)
            ac.addAction(cancel)
            present(ac, animated: true)
        case 3:
            let iCVC = self.storyboard?.instantiateViewController(withIdentifier: "navigationSitesList")
            self.present(iCVC!, animated: true)
        case 4:
            if deleteAllRecordsInPicturers() { dismiss(animated: true) }
            else { self.present(ErrorManager.errorDelete(), animated: true) }
        default:
            break
        }
    }
    
    
}
