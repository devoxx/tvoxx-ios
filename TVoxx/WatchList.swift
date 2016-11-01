//
//  WatchList.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 24/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import Foundation
import CloudKit

enum WatchListError {
    case notAuthenticated
    case backendError(rootCause:Error)
}

class WatchList: NSObject {
    static let sharedWatchList = WatchList()
    
    fileprivate override init() {
        super.init()
    }
    
    fileprivate var container:CKContainer {
        return CKContainer(identifier: "iCloud.com.devoxx.TVoxx")
    }
    
    func isTalkAlreadyInWatchList(_ talk:TalkDetail, callback:@escaping (Bool?,WatchListError?) -> Void){
        self.container.accountStatus { (accountStatus:CKAccountStatus, error:Error?) in
            if accountStatus == CKAccountStatus.noAccount {
                DispatchQueue.main.async(execute: {
                    callback(nil, WatchListError.notAuthenticated)
                })
            } else {
                self.container.privateCloudDatabase.fetch(withRecordID: CKRecordID(recordName: talk.talkId), completionHandler: { (record:CKRecord?, error:Error?) in
                    if let error = error as? NSError, error.code != CKError.unknownItem.rawValue {
                        DispatchQueue.main.async(execute: {
                            callback(nil, WatchListError.backendError(rootCause: error))
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            callback(record != nil, nil)
                        })
                    }
                })
            }
        }
    }
    
    func moviesInWatchList(_ callback:@escaping ([TalkListItem]?,WatchListError?) -> Void) {
        self.container.accountStatus { (accountStatus:CKAccountStatus, error:Error?) in
            if accountStatus == CKAccountStatus.noAccount {
                DispatchQueue.main.async(execute: {
                    callback(nil, WatchListError.notAuthenticated)
                })
            } else {
                let query = CKQuery(recordType: "Talk", predicate: NSPredicate(value: true))
                self.container.privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records:[CKRecord]?, error:Error?) in
                    if let error = error {
                        DispatchQueue.main.async(execute: {
                            callback(nil, WatchListError.backendError(rootCause: error))
                        })
                    } else {
                        var talks = [TalkListItem]()
                        for record in records! {
                            talks.append(TalkListItem(withRecord:record))
                        }
                        DispatchQueue.main.async(execute: {
                            callback(talks, nil)
                        })
                    }
                })
            }
        }
    }
    
    func addTalkToWatchList(_ talk:TalkDetail, callback:@escaping (WatchListError?) -> Void) {
        self.container.accountStatus { (accountStatus:CKAccountStatus, error:Error?) in
            if accountStatus == CKAccountStatus.noAccount {
                DispatchQueue.main.async(execute: { 
                    callback(WatchListError.notAuthenticated)
                })
            } else {
                self.container.privateCloudDatabase.save(talk.record, completionHandler: { (savedRecord:CKRecord?, error:Error?) in
                    DispatchQueue.main.async(execute: {
                        if let error = error {
                            callback(WatchListError.backendError(rootCause: error))
                        } else {
                            callback(nil)
                        }
                    })
                }) 
            }
        }
    }
    
    func removeTalkFromWatchList(_ talk:TalkDetail, callback:@escaping (WatchListError?) -> Void) {
        self.container.accountStatus { (accountStatus:CKAccountStatus, error:Error?) in
            if accountStatus == CKAccountStatus.noAccount {
                DispatchQueue.main.async(execute: {
                    callback(WatchListError.notAuthenticated)
                })
            } else {
                self.container.privateCloudDatabase.delete(withRecordID: CKRecordID(recordName: talk.talkId), completionHandler: { (recordID:CKRecordID?, error:Error?) in
                    DispatchQueue.main.async(execute: {
                        if let error = error {
                            callback(WatchListError.backendError(rootCause: error))
                        } else {
                            callback(nil)
                        }
                    })
                })
            }
        }
    }
}
