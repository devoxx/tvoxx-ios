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
    case NotAuthenticated
    case BackendError(rootCause:NSError)
}

class WatchList: NSObject {
    static let sharedWatchList = WatchList()
    
    private override init() {
        super.init()
    }
    
    func isTalkAlreadyInWatchList(talk:TalkDetail, callback:(Bool?,WatchListError?) -> Void){
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus:CKAccountStatus, error:NSError?) in
            if accountStatus == CKAccountStatus.NoAccount {
                dispatch_async(dispatch_get_main_queue(), {
                    callback(nil, WatchListError.NotAuthenticated)
                })
            } else {
                /*let query = CKQuery(recordType: "Talk", predicate: NSPredicate(format: "talkId = %@", talk.talkId))
                CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(nil, WatchListError.BackendError(rootCause: error))
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(records != nil && records?.count > 0, nil)
                        })
                    }
                })*/
                CKContainer.defaultContainer().privateCloudDatabase.fetchRecordWithID(CKRecordID(recordName: talk.talkId), completionHandler: { (record:CKRecord?, error:NSError?) in
                    if let error = error where error.code != CKErrorCode.UnknownItem.rawValue {
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(nil, WatchListError.BackendError(rootCause: error))
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { 
                            callback(record != nil, nil)
                        })
                    }
                })
            }
        }
    }
    
    func moviesInWatchList(callback:([TalkListItem]?,WatchListError?) -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus:CKAccountStatus, error:NSError?) in
            if accountStatus == CKAccountStatus.NoAccount {
                dispatch_async(dispatch_get_main_queue(), {
                    callback(nil, WatchListError.NotAuthenticated)
                })
            } else {
                let query = CKQuery(recordType: "Talk", predicate: NSPredicate(value: true))
                CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records:[CKRecord]?, error:NSError?) in
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(nil, WatchListError.BackendError(rootCause: error))
                        })
                    } else {
                        var talks = [TalkListItem]()
                        for record in records! {
                            talks.append(TalkListItem(withRecord:record))
                        }
                        dispatch_async(dispatch_get_main_queue(), { 
                            callback(talks, nil)
                        })
                    }
                })
            }
        }
    }
    
    func addTalkToWatchList(talk:TalkDetail, callback:WatchListError? -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus:CKAccountStatus, error:NSError?) in
            if accountStatus == CKAccountStatus.NoAccount {
                dispatch_async(dispatch_get_main_queue(), { 
                    callback(WatchListError.NotAuthenticated)
                })
            } else {                
                CKContainer.defaultContainer().privateCloudDatabase.saveRecord(talk.record) { (savedRecord:CKRecord?, error:NSError?) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let error = error {
                            callback(WatchListError.BackendError(rootCause: error))
                        } else {
                            callback(nil)
                        }
                    })
                }
            }
        }
    }
    
    func removeTalkFromWatchList(talk:TalkDetail, callback:WatchListError? -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus:CKAccountStatus, error:NSError?) in
            if accountStatus == CKAccountStatus.NoAccount {
                dispatch_async(dispatch_get_main_queue(), {
                    callback(WatchListError.NotAuthenticated)
                })
            } else {
                CKContainer.defaultContainer().privateCloudDatabase.deleteRecordWithID(CKRecordID(recordName: talk.talkId), completionHandler: { (recordID:CKRecordID?, error:NSError?) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let error = error {
                            callback(WatchListError.BackendError(rootCause: error))
                        } else {
                            callback(nil)
                        }
                    })
                })
            }
        }
    }
}
