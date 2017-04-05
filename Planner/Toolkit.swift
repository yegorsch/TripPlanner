//
//  Toolkit.swift
//  Planner
//
//  Created by Егор on 3/28/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import Foundation
import CoreData

class Toolkit {
    
    private init(){
        
    }
    
    class func getContext() -> NSManagedObjectContext{
        return Toolkit.persistentContainer.viewContext
    }
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Planner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    class func formatDate(date:Any) -> String{
        if let dateParam = date as? Date{
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("GMT")
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: dateParam)
        }else if let nsDateParam = date as? NSDate{
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("GMT")
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: nsDateParam as Date)
        }
        return ""
    }
    class func formatDateAndTime(date:Any) -> String{
        if let dateParam = date as? Date{
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("GMT")
            formatter.dateFormat = " dd.MM.yyyy hh:mm"
            return formatter.string(from: dateParam)
        }else if let nsDateParam = date as? NSDate{
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("GMT")
            formatter.dateFormat = " dd.MM.yyyy hh:mm"
            return formatter.string(from: nsDateParam as Date)
        }
        return ""
    }
    class func dateFromNSDate(date:NSDate) -> Date{
        let timeInterval = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: timeInterval)
    }
}
