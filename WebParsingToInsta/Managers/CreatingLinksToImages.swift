//
//  CreatingLinksToImages.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 11.09.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import Foundation

protocol CreatingLinksToImages {
    func mainUrlAddressAddLink(fullAddress: String, link: String) -> String?
    func fullUrlAddressAddLink(fullAddress: String, link: String) -> String?
}

extension CreatingLinksToImages {
    
    func mainUrlAddressAddLink(fullAddress: String, link: String) -> String? {
        
        let index = link.index(of: ":") ?? link.endIndex //Проверка на самодостасточность ссылки
        guard link[..<index] != "http", link[..<index] != "https" else { return nil }
        
        var address = ""
        var counterSlash: Int = 0
        for chrapter in fullAddress {
            if chrapter == "/" { counterSlash += 1 }
            if counterSlash == 3 { break }
            address += String(chrapter)
        }
        if link[link.startIndex] == "/" { return address + link }
        else { return address + "/" + link }
    }
    
    func fullUrlAddressAddLink(fullAddress: String, link: String) -> String? {
        
        let index = link.index(of: ":") ?? link.endIndex //Проверка на самодостасточность ссылки
        guard link[..<index] != "http", link[..<index] != "https" else { return nil }
        
        var fAddress = fullAddress
        var fLink = link
        
        if fAddress[fAddress.index(before: fAddress.endIndex)] == "/" { fAddress.remove(at: fAddress.index(before: fAddress.endIndex)) }
        if fLink[fLink.startIndex] == "/" { fLink.remove(at: fLink.startIndex)}
        
        return fAddress + "/" + fLink
    }

}
