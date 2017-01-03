//
//  CSVToCoreData.swift
//  SearchWord
//
//  Created by Marek Mako on 01/12/2016.
//  Copyright © 2016 Marek Mako. All rights reserved.
//

import UIKit
import CoreData


class CSVToCoreData {
    
    static let shared = CSVToCoreData()
    
    private let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func dataURL(from category: WordCategory) -> URL {
        return Bundle.main.url(forResource: category.rawValue, withExtension: "csv")!
    }
    
    func `import`(category: WordCategory) {
        // vymazanie starych zaznamov
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: category.entityName())
        let fetchResult = try! managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        for result in fetchResult {
            managedObjectContext.delete(result)
        }
        try! managedObjectContext.save()
        
        // import novych
        if let content = try? String(contentsOf: dataURL(from: category), encoding: .utf8) {
            let rows = content.components(separatedBy: .newlines)
            for row in rows {
                let rowValues = row.components(separatedBy: ";")
                if 2 == rowValues.count {
                    // import
                    let entity = NSEntityDescription.insertNewObject(forEntityName: category.entityName(), into: managedObjectContext)
                    entity.setValue(Int64(rowValues[0])!, forKey: "id")
                    entity.setValue(rowValues[1], forKey: "name")
                }
            }
            
            do {
                try managedObjectContext.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let checkFetchResult = try! managedObjectContext.fetch(fetchRequest)
        print("naimportovanych \(category.entityName()): ", checkFetchResult.count)
    }
    
    func importPoints() {
        // vymazanie starych zaznamov
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Points.self))
        let fetchResult = try! managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
        for result in fetchResult {
            managedObjectContext.delete(result)
        }
        try! managedObjectContext.save()
        
        // import novych
        if let content = try? String(contentsOf: Bundle.main.url(forResource: "points", withExtension: "csv")!, encoding: .utf8) {
            let rows = content.components(separatedBy: .newlines)
            for row in rows {
                let rowValues = row.components(separatedBy: ";")
                if 5 == rowValues.count {
                    // import
                    let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Points.self), into: managedObjectContext) as! Points
                    entity.category = rowValues[1]
                    entity.char = rowValues[2]
                    entity.points = Int16(rowValues[4])!
                }
            }
            
            do {
                try managedObjectContext.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let checkFetchResult = try! managedObjectContext.fetch(fetchRequest)
        print("naimportovanych Points: ", checkFetchResult.count)
    }
    
    deinit {
        print(#function, self)
    }
}
