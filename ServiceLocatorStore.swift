//
//  ServiceLocatorStore.swift
//  ContractApp
//
//  Created by 刘兆娜 on 16/4/29.
//  Copyright © 2016年 金军航. All rights reserved.
//

import Foundation
import CoreData

class ServiceLocatorStore {
    var coreDataStack = CoreDataStack(modelName: "jufangzhushou")
    
    func GetServiceLocator() -> ServiceLocatorEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ServiceLocatorEntity")
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = nil
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [ServiceLocatorEntity]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.fetch(fetchRequest) as? [ServiceLocatorEntity]
            }
            catch let error {
                fetchRequestError = error
                NSLog("GetServiceLocator()出现异常")
            }
        }
        
        if fetchRequestError == nil {
            if mainQueueUsers?.count == 0 {
                return nil
            } else {
                let entity = mainQueueUsers![0]
                //print("serverName = \(entity.serverName)")
                return entity
            }
        }
        return nil
    }
    
    func saveServiceLocator(serviceLocator: ServiceLocator) -> Bool {
        //存储登录的信息
        let context = coreDataStack.mainQueueContext
        var entity: ServiceLocatorEntity!
        context.performAndWait() {
            entity = NSEntityDescription.insertNewObject(forEntityName: "ServiceLocatorEntity", into: context) as! ServiceLocatorEntity
            entity.http = serviceLocator.http
            entity.serverName = serviceLocator.serverName
            entity.port = serviceLocator.port as! NSNumber
            entity.isUseServiceLocator = serviceLocator.isUseServiceLocator
        }
        
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
    }
    
    func UpdateServiceLocator() -> Bool {
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            print("Core Data save failed: \(error)")
            return false
        }
        return true
        
    }
    
}
