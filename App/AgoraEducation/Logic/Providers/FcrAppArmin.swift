//
//  FcrAppArmin.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2023/7/6.
//  Copyright © 2023 Agora. All rights reserved.
//

import Foundation
import Armin

protocol FcrAppArminFailureDelegate: NSObjectProtocol {
    func onRequestFailure(error: FcrAppError)
}

class FcrAppArmin: ArminClient {
    weak var failureDelegate: FcrAppArminFailureDelegate?
    
    func request(url: String,
                 headers: [String: String]? = nil,
                 parameters: [String: Any]? = nil,
                 method: ArHttpMethod,
                 event: String,
                 success: FcrAppRequestSuccess? = nil,
                 failure: FcrAppFailure? = nil) {
        if let headers = headers {
            printDebug("event: \(event), headers: \(headers)")
        }
        
        let type = ArRequestType.http(method,
                                      url: url)
        
        let requestTask = ArRequestTask(event: ArRequestEvent(name: event),
                                        type: type,
                                        timeout: .medium,
                                        header: headers,
                                        parameters: parameters)
        
        let response: ArResponse = ArResponse.json { (json) in
            do {
                let responseObject = try FcrAppServerResponseObject(json: json)
                try success?(responseObject)
            } catch var error as FcrAppError {
                error.message = event + ", " + error.message
                printDebug("Error: " + "\(error.message)")
                failure?(error)
            }
        }
        
        request(task: requestTask,
                responseOnMainQueue: true,
                success: response) { [weak self] (error) in
            let appError = FcrAppError(code: error.code ?? -1,
                                       message: error.localizedDescription)
            
            self?.failureDelegate?.onRequestFailure(error: appError)
            
            failure?(appError)
                
            return .resign
        }
    }
    
    func convertableRequest<T: FcrAppCodable>(url: String,
                                              headers: [String: String]? = nil,
                                              parameters: [String: Any]? = nil,
                                              method: ArHttpMethod,
                                              event: String,
                                              success: ((T) -> Void)? = nil,
                                              failure: FcrAppFailure? = nil) {
        request(url: url,
                headers: headers,
                parameters: parameters,
                method: method,
                event: event,
                success: { response in
            let json = try response.dataConvert(type: [String: Any].self)
            let data = try T.decode(from: json)
            success?(data)
        }, failure: failure)
    }
}
