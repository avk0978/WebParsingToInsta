//
//  RetrievingImages.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 11.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import Foundation
import SwiftSoup
import CoreData

final class RetrievingImages: CreatingLinksToImages {
    
    var links = [String]() //Массив полученных ссылок
    var linksInPictures = [String]() // Массив сохраненых ссылок
    
    func loadingAndParsingHTML(url: String) {
        do {
            let htmlContext = try String(contentsOf: URL(string: url)!, encoding: .ascii)
            parsing(html: htmlContext, url: url)
        } catch let error {
            print("Ошибка при загрузке HTML: \(error)")
        }
    }
    
    private func parsing(html: String, url: String) {
        links.removeAll()
        do {
            let elements: Elements = try SwiftSoup.parse(html).select("img[src~=(?i)\\.(png|jpe?g)]")
            for element in elements.array(){
                let link = try element.attr("src")
                links.append(link) // Возможно три типа ссылки на изображение
                if let str = fullUrlAddressAddLink(fullAddress: url, link: link) { links.append(str) }
                if let str = mainUrlAddressAddLink(fullAddress: url, link: link) { links.append(str) }
            }
        } catch Exception.Error(let type, let message) {
            print("Ошибка Parsing: \(message), type: \(type)")
        } catch {
            print("error parsing")
        }
    }
    
    func downloadingDataFromPictures() {
        linksInPictures.removeAll()
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Pictures> = Pictures.fetchRequest()
        do {
            let dataInPictures = (try context?.fetch(fetchRequest))!
            for element in dataInPictures {
                linksInPictures.append(element.link!)
            }
        } catch { print("Ошибка при загрузке данных из Core Data\(error.localizedDescription)") }
    }
    
    func downloadImagesBy(imageLink: String) {
        guard let url = URL(string: imageLink), let imageData = try? Data(contentsOf: url) else { return }
        saveInBD(image: imageData, link: imageLink)
    }
    
    private func saveInBD(image: Data, link: String) {
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Pictures", in: context!)
            let object = NSManagedObject(entity: entity!, insertInto: context) as! Pictures
            object.picture = image
            object.link = link
            do {
                try context?.save()
            } catch {
                print("Ошибка при загрузке данных в Core Data\(error.localizedDescription)")
            }
        }
    }
}
