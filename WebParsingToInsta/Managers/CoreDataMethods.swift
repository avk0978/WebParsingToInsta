//
//  CoreDataMethods.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 13.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import Foundation
import UIKit
import  CoreData

protocol CoreDataMethods {
    func deleteImageForPicturesAt(_ indexPath: IndexPath) -> Bool
    func deleteAllRecordsInPicturers() -> Bool
    func loadDataInImageCollectionFromPictures() -> [Pictures]
    func entitiesSitesIsEmpty() -> Bool?
    func addSiteNameToEntitiesSites(name: String, link: String, isActive: Bool) -> Void
    func fetchSiteLink() -> String
    func loadingDataFromSites() -> [Sites]
    func changeDefaultDownloadSite(_ indexPath: IndexPath) -> Bool
    func theSiteNameIsUnique(name: String) -> Bool
    func deleteRecordFromEntitieSiteAt(indexPath: IndexPath) -> Bool
}

extension CoreDataMethods {
    
    func deleteImageForPicturesAt(_ indexPath: IndexPath) -> Bool {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return false }
            let fetchRequest: NSFetchRequest = Pictures.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "picture", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: context,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)
            do {
                try fetchResultController.performFetch()
            } catch { print(error.localizedDescription) }
            let imageToDelete = fetchResultController.object(at: indexPath)
            context.delete(imageToDelete)
            do {
                try context.save()
            } catch { print(error.localizedDescription) }

        return true
    }
    
    func deleteAllRecordsInPicturers() -> Bool {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return false }
        let fetchAllrecords = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchAllrecords)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
            return false
        }

        return true
    }
    
    func loadDataInImageCollectionFromPictures() -> [Pictures] {
        var data: [Pictures] = []
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return data}
        let fetchRequest: NSFetchRequest<Pictures> = Pictures.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "picture", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            data = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return data
    }
    
    func loadingDataFromSites() -> [Sites]{
            var data: [Sites] = []
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return data}
            let fetchRequest: NSFetchRequest<Sites> = Sites.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                data = try context.fetch(fetchRequest)
            } catch {
                print(error.localizedDescription)
            }
            return data
        }

    
    func entitiesSitesIsEmpty() -> Bool? {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return nil }
        let fetchReqest: NSFetchRequest<Sites> = Sites.fetchRequest()
        var recordsCount: Int = 0
        do {
            recordsCount = try context.count(for: fetchReqest)
        } catch { print(error.localizedDescription) }
        if recordsCount == 0 { return true }
        else { return false}
    }
    
    func addSiteNameToEntitiesSites(name: String, link: String, isActive: Bool){
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        let entity = NSEntityDescription.entity(forEntityName: "Sites", in: context)
        let object = NSManagedObject(entity: entity!, insertInto: context) as! Sites
        object.isActive = isActive
        object.link = link
        object.name = name
        do {
            try context.save()
        } catch { print(error.localizedDescription) }
    }
    
    func fetchSiteLink() -> String {
        var siteLink: String = ""
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return siteLink}
        let fetchRequest: NSFetchRequest<Sites> = Sites.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "isActive == true")
        fetchRequest.sortDescriptors = [sort]
        do {
            siteLink = try (context.fetch(fetchRequest).first?.link)!
        } catch { print(error.localizedDescription) }
        return siteLink
    }

    func changeDefaultDownloadSite(_ indexPath: IndexPath) -> Bool {
        deleteTrueStatusLink()
        setDefaultStatusAt(indexPath: indexPath)
        return true
    }
    
    private func deleteTrueStatusLink() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        let fetchRequest: NSFetchRequest<Sites> = Sites.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "isActive == true")
        fetchRequest.sortDescriptors = [sort]
        do {
            let object = try context.fetch(fetchRequest).first!
            object.isActive = false
            try context.save()
        } catch { print(error.localizedDescription) }

    }
    
    private func setDefaultStatusAt(indexPath: IndexPath) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
        let fetchRequest: NSFetchRequest = Sites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: context,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
        do {
            try fetchResultController.performFetch()
            fetchResultController.object(at: indexPath).isActive = true
            try context.save()
        } catch { print(error.localizedDescription) }
    }

//    private func printListEntitiesSites() {
//        var data: [Sites] = []
//        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
//        let fetchRequest: NSFetchRequest<Sites> = Sites.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        do {
//            data = try context.fetch(fetchRequest)
//        } catch {
//            print(error.localizedDescription)
//        }
//        for record in data {
//            print("""
//                Запись: \(record.name!)
//                Ссылка: \(record.link!)
//                Статус: \(record.isActive)
//                ------------------------
//                """)
//        }
//    }
    
    func theSiteNameIsUnique(name: String) -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return false}
        let fetchRequest: NSFetchRequest<Sites> = Sites.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.sortDescriptors = [sort]
        do {
            let object = try context.fetch(fetchRequest)
            if object.count == 0 { return true }
            else { return false }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func deleteRecordFromEntitieSiteAt(indexPath: IndexPath) -> Bool {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return false }
        let fetchRequest: NSFetchRequest = Sites.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: context,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
        do {
            try fetchResultController.performFetch()
            let imageToDelete = fetchResultController.object(at: indexPath)
            context.delete(imageToDelete)
            try context.save()
        } catch {
            print(error.localizedDescription)
            return false
        }
        
        return true
    }
    
}

