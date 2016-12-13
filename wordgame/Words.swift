//
//  Words.swift
//  wordgame
//
//  Created by Marek Mako on 12/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import CoreData

enum WordCategory: String {
    case names, nouns
    
    static let allValues = [names, nouns]
    
    func entityName() -> String {
        switch self {
        case .names:
            return String(describing: Names.self)
        case .nouns:
            return String(describing: Nouns.self)
        }
    }
}

class WordRepository {
    
    static let shared = WordRepository()
    
    private let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func findRandomOne(for category: WordCategory) -> NSManagedObject {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: category.entityName())
        let result = try! managedObjectContext.fetch(request)
        
        let rand = Int(arc4random_uniform(UInt32(result.count + 1)))
        
        return result[rand] as! NSManagedObject
    }
    
    func findRandomOne(for category: WordCategory, startWith char: String) -> NSManagedObject {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: category.entityName())
        request.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", char)
        let result = try! managedObjectContext.fetch(request)
        
        let rand = Int(arc4random_uniform(UInt32(result.count + 1)))
        
        return result[rand] as! NSManagedObject
    }
    
    func findPoints(forCategory category: WordCategory, startsWith char: String) -> Points {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Points.self))
        request.predicate = NSPredicate(format: "category = %@ and char = %@", category.rawValue, char)
        
        let result = try! managedObjectContext.fetch(request)
        
        return result.first as! Points
    }
    
    func wordExists(for category: WordCategory, word: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: category.entityName())
        request.predicate = NSPredicate(format: "name = %@", word)
        
        let result = try! managedObjectContext.fetch(request)
        
        return result.count > 0
    }
}
