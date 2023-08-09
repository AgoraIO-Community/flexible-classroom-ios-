//
//  FcrAppExtension.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2021/12/16.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraUIBaseViews
import CommonCrypto
import Foundation
import UIKit

func printDebug(_ text: String) {
    print(">>>>>>>>>> \(text)")
}

extension Bundle {
    var version: String {
        guard let infoDictionary = infoDictionary,
              let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
}

extension UIDevice {
    var isSmallPhone: Bool {
        guard UIDevice.current.agora_is_pad else {
            return false
        }
        
        if UIScreen.main.bounds.size.height < 700 {
            return true
        } else {
            return false
        }
    }
}

extension NotificationCenter {
    func observerKeyboard(listening: (((endFrame: CGRect, duration: Double)) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil,
                                               queue: nil) { (notify) in
            guard let userInfo = notify.userInfo else {
                return
            }
            
            let endKeyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let endKeyboardFrame = endKeyboardFrameValue?.cgRectValue
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
            let duration = durationValue?.doubleValue
            
            if let listening = listening {
                let callbackParameter = (endFrame: endKeyboardFrame!,
                                         duration: duration!)
                listening(callbackParameter)
            }
        }
    }
}

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!,
               strLen,
               result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        
        return hash as String
    }
    
    func localized() -> String {
        let bundle = Bundle.main
        
        if let language = agora_ui_language,
           let languagePath = bundle.path(forResource: language,
                                          ofType: "lproj"),
           let bundle = Bundle(path: languagePath) {
            
            return bundle.localizedString(forKey: self,
                                          value: nil,
                                          table: nil)
        } else {
            let text = bundle.localizedString(forKey: self,
                                              value: nil,
                                              table: nil)
            
            return text
        }
    }
}
