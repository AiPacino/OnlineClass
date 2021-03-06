//
//  KeyValueStore.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/6/25.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import CoreData
import QorumLogs


class KeyValueStore {
    
    static let key_jifen = "key_jifen"
    static let key_chaifu = "key_chaifu"
    static let key_tuandui = "key_tuandui"
    static let key_tuijian = "key_tuijian"
    static let key_zhidian = "key_zhidian"
    static let key_ordercount = "key_ordercount"
    static let key_vipenddate = "key_vipenddate"
    static let key_popupAdImageUrl = "key_popupAdImageUrl"
    static let key_isweixinbind = "key_isweixinbind"
    static let key_hasnewmessage = "key_hasnewmessage"
    static let key_hasbindphone = "key_hasbindphone"
    
    static let key_local_wallet = "key_local_wallet"  //存取未登陆用户充值的知点
    static let BuyRecordSeparator = "___"
    static let key_buy_records = "key_buy_records"  //存放购买记录（tickets)，这些tickets使用###连接起来，发送给服务器进行验证
    
    var coreDataStack = CoreDataStack(modelName: "jufangzhushou")
    
    @discardableResult
    func save(key: String, value: String) -> Bool {
        
        //首先查询key是否存在
        let oldKeyValuePair: KeyValueEntity?
        
        do {
            oldKeyValuePair = try getKeyValuePair(key: key)  //error happens
        } catch {
            return false
        }
        
        
        if oldKeyValuePair == nil {  //the key is not exist
            let context = coreDataStack.mainQueueContext
            var entity: KeyValueEntity!
            context.performAndWait() {
                entity = NSEntityDescription.insertNewObject(forEntityName: "KeyValueEntity", into: context) as! KeyValueEntity
                entity.key = key
                entity.value = value
            }
            
        } else {                     //the key is exist
            oldKeyValuePair?.value = value
        }
        
        do {
            try coreDataStack.saveChanges()
        }
        catch let error {
            QL4("Core Data save failed: \(error)")
            return false
        }
        
        return true
        
    }
    
    private func getKeyValuePair(key: String) throws -> KeyValueEntity?  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KeyValueEntity")
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = NSPredicate(format: "key = %@", key)
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueUsers: [KeyValueEntity]?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueueUsers = try mainQueueContext.fetch(fetchRequest) as? [KeyValueEntity]
            }
            catch let error {
                fetchRequestError = error
                QL4("isKeyExist()出现异常")
            }
        }
        
        if fetchRequestError == nil {
            if mainQueueUsers?.count == 0 {
                return nil
            } else {
                return mainQueueUsers![0]
            }
        } else {
            throw fetchRequestError!
        }
    }
    
    
    func get(key: String, defaultValue: String = "") -> String? {
        var result : String?
        do {
            let pair = try getKeyValuePair(key: key)
            
            if pair == nil {
                result = defaultValue
            } else {
                result = pair?.value
            }
        } catch {
            result = defaultValue
        }
        //QL1("key = \(key), default: \(defaultValue), result = \(result != nil ? result! : "nil")")
        return result
    }
    
    func hasNewMessage() -> Bool {
        return checkBoolean(KeyValueStore.key_hasnewmessage)
    }
    
    func isBindWeixin() -> Bool {
       return checkBoolean(KeyValueStore.key_isweixinbind)
    }
    
    func hasBindPhone() -> Bool {
        return checkBoolean(KeyValueStore.key_hasbindphone)
    }
    
    private func checkBoolean(_ key : String) -> Bool {
        return self.get(key: key, defaultValue: "0") == "1"
    }
}
