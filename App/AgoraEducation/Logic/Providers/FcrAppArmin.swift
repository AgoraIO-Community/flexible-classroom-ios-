//
//  FcrAppArmin.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2023/7/6.
//  Copyright © 2023 Agora. All rights reserved.
//

import Foundation
import AgoraFoundation

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
        
        self.objc_request(url: url,
                          headers: headers,
                          parameters: parameters,
                          method: method,
                          event: event,
                          timeout: 10,
                          responseQueue: DispatchQueue.main,
                          retryCount: 0,
                          jsonSuccess: { json in
            do {
                let responseObject = try FcrAppServerResponseObject(json: json)
                try success?(responseObject)
            } catch var error as FcrAppError {
                error.message = event + ", " + error.message
                printDebug("Error: " + "\(error.message)")
                failure?(error)
            } catch {
                printDebug("Unexpected error: \(error)")
                let appError = FcrAppError(code: -1,
                                           message: "Unexpected error: \(error)")
                failure?(appError)
            }
        }) { [weak self] error in
            let appError = FcrAppError(code: error.code,
                                       message: error.localizedDescription)
            
            self?.failureDelegate?.onRequestFailure(error: appError)
            
            failure?(appError)
        } cancelRetry: { error in
            return true
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
