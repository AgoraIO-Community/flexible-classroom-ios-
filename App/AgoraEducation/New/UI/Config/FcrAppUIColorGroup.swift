//
//  FcrAppUIColorGroup.swift
//  AgoraEducation
//
//  Created by Cavan on 2023/8/7.
//  Copyright © 2023 Agora. All rights reserved.
//

import UIKit

struct FcrAppUIColorGroup {
    static var fcr_v2_light1: UIColor {
        return hexString("#F2F2FA")
    }
    
    static var fcr_v2_light_text1: UIColor {
        return .black
    }
    
    static var fcr_v2_light_input_background: UIColor {
        return hexString("#F9F9FC")
    }
    
    static var fcr_light_textline: UIColor {
        return hexString("#EFEFEF")
    }
    
    static var fcr_v2_brand6: UIColor {
        return hexString("#4262FF")
    }
    
    private static func hexString(_ text: String) -> UIColor {
        UIColor(hexString: text) ?? .clear
    }
}
