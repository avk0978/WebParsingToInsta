//
//  SitesList.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 24.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit


class SitesList: UITableViewController, CoreDataMethods {
    
    var sites: [Sites] = []
    
    @IBAction func exitButton(_ sender: Any) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       sites = loadingDataFromSites()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        if sites[indexPath.row].isActive {
            cell.name.textColor = #colorLiteral(red: 1, green: 0.1536788642, blue: 0.2014161646, alpha: 1)
            cell.link.textColor = #colorLiteral(red: 1, green: 0.1536788642, blue: 0.2014161646, alpha: 1)
        } else {
            cell.name.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            cell.link.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        }
        cell.name.text = sites[indexPath.row].name
        cell.link.text = sites[indexPath.row].link
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Локализация текстовых сообщений
        let showWebsite: String = NSLocalizedString("Show website", comment: "")
        let loadedWhenOpeningTheApplication: String = NSLocalizedString("Loaded when opening the application", comment: "")
        let deleteLink: String = NSLocalizedString("Delete link", comment: "")
        let messageClose: String = NSLocalizedString("Close", comment: "")
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let downloadingSite = UIAlertAction(title: showWebsite, style: .default) { (action) in
            downloadLink = (tableView.cellForRow(at: indexPath) as! TableViewCell).link.text!
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("loadSiteByDownloadLink"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
            }
        }
        let changeDefaultStatus = UIAlertAction(title: loadedWhenOpeningTheApplication, style: .default) { (action) in
            guard self.changeDefaultDownloadSite(indexPath) else { return }
            self.sites.removeAll()
            self.sites = self.loadingDataFromSites()
            tableView.reloadData()
        }
        let delete = UIAlertAction(title: deleteLink, style: .default) { (action) in
            let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
            guard cell.name.textColor == #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1) else {
                self.present(ErrorManager.defaultLink(), animated: true)
                return
            }

            if self.deleteRecordFromEntitieSiteAt(indexPath: indexPath) {
                self.sites.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                self.present(ErrorManager.errorDelete(), animated: true)
            }
        }
        let close = UIAlertAction(title: messageClose, style: .cancel)
        ac.addAction(downloadingSite)
        ac.addAction(changeDefaultStatus)
        ac.addAction(delete)
        ac.addAction(close)
        present(ac, animated: true)
    }
    
}
