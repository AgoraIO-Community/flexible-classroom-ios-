//
//  FcrAppURLGroup.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2023/7/5.
//  Copyright © 2023 Agora. All rights reserved.
//

import Foundation

class FcrAppURLGroup {
    private var host: String {
        switch environment {
        case .dev:
           return "https://api-solutions-dev.bj2.agoralab.co"
        case .pt:
            return "https://api-solutions-dev.sh2.agoralab.co"
        case .pre:
            return "https://api-solutions-pre.bj2.agoralab.co"
        case .pro:
            switch region {
            case .CN:
                return "https://api-solutions-cn.shengwang.cn"
            case .NA:
                return "https://api-solutions-na.agoralab.co"
            case .EU:
                return "https://api-solutions-eu.agoralab.co"
            case .AP:
                return "https://api-solutions-ap.agoralab.co"
            }
        }
    }
    
    private let edu = "edu"
    private let companys = "companys"
    private let rooms = "rooms"
    private let sso = "sso"
    private let users = "users"
    private let auth = "auth"
    private let oauth = "oauth"
    private let info = "info"
    private let redirectUrl = "redirectUrl"
    private let refresh = "refresh"
    private let refreshTokenKey = "refreshToken"
    private let preflight = "preflight"
    private let logout = "logout"
    
    private let version1 = "v1"
    private let version2 = "v2"
    private let version3 = "v3"
    
    var companyId = "" {
        didSet {
            localStorage.writeData(companyId,
                                   key: .companyId)
        }
    }
    
    /// Access token is used outside the room
    var accessToken = "" {
        didSet {
            localStorage.writeData(accessToken,
                                   key: .accessToken)
        }
    }
    
    /// Using a refreshToken to request an updated accessToken
    var refreshToken = "" {
        didSet {
            localStorage.writeData(refreshToken,
                                   key: .refreshToken)
        }
    }
    
    var environment = FcrAppEnvironment.pro {
        didSet {
            localStorage.writeData(environment.rawValue,
                                   key: .environment)
        }
    }
    
    var region = FcrAppRegion.CN {
        didSet {
            localStorage.writeData(region.rawValue,
                                   key: .region)
        }
    }
    
    private let localStorage: FcrAppLocalStorage
    
    init(localStorage: FcrAppLocalStorage) {
        self.localStorage = localStorage
        
        if let companyId = try? localStorage.readData(key: .companyId,
                                                      type: String.self) {
            self.companyId = companyId
        }
        
        if let accessToken = try? localStorage.readData(key: .accessToken,
                                                        type: String.self) {
            self.accessToken = accessToken
        }
        
        if let refreshToken = try? localStorage.readData(key: .refreshToken,
                                                        type: String.self) {
            self.refreshToken = refreshToken
        }
        
        if let environment = try? localStorage.readStringEnumData(key: .environment,
                                                                  type: FcrAppEnvironment.self) {
            self.environment = environment
        }
        
        if let region = try? localStorage.readStringEnumData(key: .region,
                                                             type: FcrAppRegion.self) {
            self.region = region
        }
    }
    
    func headers() -> [String: String] {
        return ["Authorization": "Bearer \(accessToken)"]
    }
    
    //
    func needLogin() -> String {
        let array = [host, edu, version1,
                     preflight]
        let url = array.joined(separator: "/")
        return url
    }
    
    // Room
    func createRoom() -> String {
        let array = [host, edu, companys,
                     companyId, version1, rooms]
        let url = array.joined(separator: "/")
        return url
    }
    
    func joinRoom() -> String {
        let array = [host, edu, companys,
                     companyId, version1, rooms]
        let url = array.joined(separator: "/")
        return url
    }
    
    func roomInfo(roomId: String) -> String {
        let array = [host, edu, companys,
                     companyId, version1, rooms,
                     roomId]
        let url = array.joined(separator: "/")
        return url
    }
    
    func quickCreateRoom() -> String {
        let array = [host, edu, companys,
                     version1, rooms]
        let url = array.joined(separator: "/")
        return url
    }
    
    func quickJoinRoom() -> String {
        let array = [host, edu, companys,
                     version1, rooms]
        let url = array.joined(separator: "/")
        return url
    }
    
    func quickRoomInfo(roomId: String) -> String {
        let array = [host, edu, companys,
                     version1, rooms, roomId]
        
        let url = array.joined(separator: "/")
        return url
    }
    
    func roomList() -> String {
        let array = [host, edu, companys,
                     companyId, version1, rooms]
        let url = array.joined(separator: "/")
        return url
    }
    
    // User
    /// For login & register
    func agoraConsole() -> String {
        let array = [host, sso, version2,
                     users, oauth, redirectUrl]
        let url = array.joined(separator: "/")
        return url
    }
    
    func userInfo() -> String {
        let array = [host, sso, version2,
                     users, info]
        let url = array.joined(separator: "/")
        return url
    }
    
    func closeAccount() -> String {
        let array = [host, sso, version2,
                     users, logout]
        let url = array.joined(separator: "/")
        return url
    }
    
    func invitation(roomId: String,
                    inviterName: String) -> String {
        let web = "https://solutions-apaas.agora.io/apaas/demo/index.html#/invite?sc="
        
        let parameter: [String: Any] = ["roomId": roomId,
                                        "owner": inviterName,
                                        "region": region.rawValue,
                                        "role": 2]
        
        let json = parameter.jsonString()!
        
        let link = (web + json.base64Encoded!)
        
        return link
    }
    
    // Token
    func refreshAccessToken() -> String {
        let array = [host, sso, version2,
                     users, refresh, refreshTokenKey,
                     refreshToken]
        let url = array.joined(separator: "/")
        return url
    }
}
