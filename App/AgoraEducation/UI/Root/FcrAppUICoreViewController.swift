//
//  FcrAppUICoreViewController.swift
//  AgoraEducation
//
//  Created by Cavan on 2023/8/24.
//  Copyright © 2023 Agora. All rights reserved.
//

import AgoraClassroomSDK_iOS
import AgoraUIBaseViews
import AgoraProctorSDK

class FcrAppUICoreViewController: FcrAppUIViewController {
    let center: FcrAppCenter
    
    var proctor: AgoraProctor?
    
    init(center: FcrAppCenter) {
        self.center = center
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func joinRoomPreCheck(config: FcrAppJoinRoomPreCheckConfig) {
        AgoraLoading.loading()
        
        center.room.joinRoomPreCheck(config: config) { [weak self] object in
            guard let `self` = self else {
                return
            }
            
            let userId = config.userId
            let userName = object.roomDetail.userName
            let userRole = config.userRole
            
            let roomType = object.roomDetail.sceneType
            let roomName = object.roomDetail.roomName
            let roomId = object.roomDetail.roomId
            
            let appId = object.appId
            let token = object.token
            
            let region = self.center.urlGroup.region
            let streamLatency = object.roomDetail.roomProperties.latencyLevel
            
            // The language and mode displayed in the room are determined by
            // the global variables `agora_ui_language` and `agora_ui_mode`.
            agora_ui_language = self.center.language.proj()
            agora_ui_mode = self.center.uiMode.toAgoraType()
            
            // Is the watermark displayed in the room
            let hasWatermark = object.roomDetail.roomProperties.watermark
            
            switch roomType {
            case .oneToOne, .smallClass, .lectureHall:
                let options = AgoraEduLaunchConfig(userName: userName,
                                                   userUuid: userId,
                                                   userRole: userRole.toClassroomType(),
                                                   roomName: roomName,
                                                   roomUuid: roomId,
                                                   roomType: roomType.toClassroomType(),
                                                   appId: appId,
                                                   token: token)
                
                options.mediaOptions.latencyLevel = streamLatency.toClassroomType()
                options.region = region.toClassroomType()
                
                self.joinClassroom(config: options,
                                   hasWatermark: hasWatermark)
            case .proctor:
                let video = AgoraProctorVideoEncoderConfig()
                let media = AgoraProctorMediaOptions(videoEncoderConfig: video,
                                                     latencyLevel: streamLatency.toProctorType())
                
                let options = AgoraProctorLaunchConfig(userName: userName,
                                                       userUuid: userId,
                                                       userRole: userRole.toProctorType(),
                                                       roomName: roomName,
                                                       roomUuid: roomId,
                                                       appId: appId,
                                                       token: token,
                                                       region: region.toProctorType(),
                                                       mediaOptions: media)
                
                self.joinProctorRoom(config: options)
            default:
                break
            }
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.showErrorToast(error)
        }
    }

    func joinClassroom(config: AgoraEduLaunchConfig,
                       hasWatermark: Bool) {
        insertWidgetSampleToClassroom(config,
                                      hasWatermark: hasWatermark)

        AgoraClassroomSDK.setDelegate(self)
        let sel = NSSelectorFromString("setEnvironment:")
        AgoraClassroomSDK.perform(sel, with: center.urlGroup.environment.intValue)
        let version = AgoraClassroomSDK.version()
        AgoraClassroomSDK.launch(config) {
            AgoraLoading.hide()
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.showErrorToast(error)
        }
    }

    func joinProctorRoom(config: AgoraProctorLaunchConfig) {
        let proctor = AgoraProctor(config: config)

        proctor.delegate = self
        
        proctor.launch {
            AgoraLoading.hide()
        } failure: { [weak self] error in
            AgoraLoading.hide()
            self?.showErrorToast(error)
        }
        
        self.proctor = proctor
    }
    
    func insertWidgetSampleToClassroom(_ config: AgoraEduLaunchConfig,
                                       hasWatermark: Bool) {
        // Widget Doc CN: https://doc.shengwang.cn/doc/flexible-classroom/ios/advanced-features/widget
        // Widget Doc EN: https://docs.agora.io/en/flexible-classroom/develop/embed-custom-plugin?platform=ios
        // This provides an example of how to register a widget in the room.
        
        let sample = FcrAppWidgetSample()
        
        let link = center.urlGroup.invitation(roomId: config.roomUuid,
                                              inviterName: config.userName)
        
        config.widgets[sample.sharingLinkWidgetId] = sample.createSharingLink(link)
        
        if let cloudDrive = config.widgets[sample.cloudDriveId],
           config.userRole == .teacher {
            cloudDrive.extraInfo = sample.cloudDriveExCourseware()
        }
        
        if hasWatermark {
            config.widgets[sample.watermarkWidgetId] = sample.createWatermark(text: config.userName)
        }
    }
}

// MARK: - AgoraEduClassroomSDKDelegate
extension FcrAppUICoreViewController: AgoraEduClassroomSDKDelegate {
    func classroomSDK(_ classroom: AgoraClassroomSDK,
                      didExit reason: AgoraEduExitReason) {
        AgoraLoading.initProperties()
    }
}

// MARK: - AgoraProctorDelegate
extension FcrAppUICoreViewController: AgoraProctorDelegate {
    func onExit(reason: AgoraProctorExitReason) {
        self.proctor = nil
        
        AgoraLoading.initProperties()
    }
}
