//
//  FcrAppUIQuickStart+Extension.swift
//  AgoraEducation
//
//  Created by Cavan on 2023/8/22.
//  Copyright © 2023 Agora. All rights reserved.
//

import AgoraUIBaseViews
import AgoraClassroomSDK_iOS

extension FcrAppUIQuickStartViewController: AgoraUIContentContainer {
    func initViews() {
        view.addSubview(contentView)
        
        // Header view
        let headerView = contentView.headerView
        
        headerView.settingButton.addTarget(self,
                                           action: #selector(onSettingsButtonPressed(_ :)),
                                           for: .touchUpInside)
        
        headerView.signButton.addTarget(self,
                                        action: #selector(onSignInButtonPressed(_ :)),
                                        for: .touchUpInside)
        
        // Join room view
        let joinRoomView = contentView.roomInputView.joinRoomView
        
        joinRoomView.roomIdTextField.setShowText(center.room.lastId)
        joinRoomView.userNameTextField.text = try? center.localStorage.readData(key: .nickname,
                                                                                type: String.self)
        
        joinRoomView.joinButton.addTarget(self,
                                          action: #selector(onJoinButtonPressed(_ :)),
                                          for: .touchUpInside)
        
        // Create room view
        let createRoomView = contentView.roomInputView.createRoomView
        
        createRoomView.roomNameTextField.text = center.room.lastName
        createRoomView.userNameTextField.text = try? center.localStorage.readData(key: .nickname,
                                                                                  type: String.self)
        
        createRoomView.roomTypeView.rightButton.addTarget(self,
                                                          action: #selector(onRoomTypeButtonPressed),
                                                          for: .touchUpInside)
        
        createRoomView.createButton.addTarget(self,
                                              action: #selector(onCreateButtonPressed(_ :)),
                                              for: .touchUpInside)
        
        // Policy view
        let policyView = contentView.roomInputView.policyView
        
        policyView.checkBox.addTarget(self,
                                      action: #selector(onPolicyButtonPressed(_ :)),
                                      for: .touchUpInside)
        
        // Footer view
        contentView.footerView.signButton.addTarget(self,
                                                    action: #selector(onSignInButtonPressed(_ :)),
                                                    for: .touchUpInside)
    }
    
    func initViewFrame() {
        contentView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.view)
        }
    }
    
    func updateViewProperties() {
        contentView.backgroundColor = UIColor.fcr_hex_string("#F8FAFF")
        
        let attributedText = FcrAppUIPolicyString().quickStartString(isMainLandChina: center.isMainLandChinaIP)
        
        contentView.roomInputView.policyView.textView.attributedText = attributedText
        
        contentView.updateViewProperties()
    }
}

private extension FcrAppUIQuickStartViewController {
    @objc func onSettingsButtonPressed(_ sender: UIButton) {
        let vc = FcrAppUISettingsViewController(center: center,
                                                dataSource: settingItems,
                                                needLougout: false)
        
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
    
    @objc func onRoomTypeButtonPressed(_ sender: UIButton) {
        let roomTypeView = contentView.roomInputView.createRoomView.roomTypeView
        
        let vc = FcrAppUIQuickStartRoomTypeViewController(roomTypeList: roomTypeList,
                                                          selected: roomTypeView.selectedRoomType)
        
        vc.onDismissed = { [weak roomTypeView, weak vc] in
            guard let `roomTypeView` = roomTypeView,
                  let `vc` = vc
            else {
                return
            }
            
            roomTypeView.selectedRoomType = vc.selected
        }
        
        presentViewController(vc,
                              animated: true)
    }
    
    @objc func onSignInButtonPressed(_ sender: UIButton) {
        if !center.tester.isTest {
           showLoginViewController()
        } else {
            if !popToMainViweController() {
                showLoginViewController()
            }
        }
    }
    
    @objc func onJoinButtonPressed(_ sender: UIButton) {
        
        let userId = "222222"
        let userName = userId
        let userRole = AgoraEduUserRole.student
        
        let roomType = AgoraEduRoomType.lecture
        let roomId = "999888777"
        let roomName = roomId
        
        let appId = "f488493d1886435f963dfb3d95984fd4"
        let token = "007eJxTYEhcw7X76Mtnr5Iu98m83Np/Sm2/ir5Ljbib/dkav9fzKt0UGNJMLCxMLI1TDC0szEyMTdMszYxT0pKMUyxNLS1M0lJMak85pjcEMjJMuv7WkpmBiYERCEF8NgYjMGBlYGBQYEg1Tk5NMrWwMEw0SDRMS0lMTDEwNLI0SzE3NTWxMLNIYYfr42SwtLS0sLAwNzeHGcHEAABqFC23"

        let region = AgoraEduRegion.CN
        let streamLatency = AgoraEduLatencyLevel.low
        
        // The language and mode displayed in the room are determined by
        // the global variables `agora_ui_language` and `agora_ui_mode`.
        agora_ui_language = self.center.language.proj()
        agora_ui_mode = self.center.uiMode.toAgoraType()
        
        // Is the watermark displayed in the room
        let hasWatermark = false
        
        let options = AgoraEduLaunchConfig(userName: userName,
                                           userUuid: userId,
                                           userRole: userRole,
                                           roomName: roomName,
                                           roomUuid: roomId,
                                           roomType: roomType,
                                           appId: appId,
                                           token: token)
        
        options.mediaOptions.latencyLevel = streamLatency
        options.region = region
        
        self.joinClassroom(config: options,
                           hasWatermark: hasWatermark)
        
//
//        let joinRoomView = contentView.roomInputView.joinRoomView
//        
//        guard let roomId = joinRoomView.roomIdTextField.getText() else {
//            showToast("fcr_login_free_toast_room_id_null".localized(),
//                      type: .error)
//            return
//        }
//        
//        if roomId.count != 9 {
//            showToast("fcr_login_free_tips_num_length".localized(),
//                      type: .error)
//            return
//        }
//        
//        guard let userName = joinRoomView.userNameTextField.getText() else {
//            showToast("fcr_login_free_toast_nick_name_null".localized(),
//                      type: .error)
//            return
//        }
//        
//        if userName.count < 2 || userName.count > 20 {
//            showToast("fcr_home_toast_content_length".localized(),
//                      type: .error)
//            return
//        }
//        
//        guard contentView.roomInputView.policyView.checkBox.isSelected else {
//            showToast(FcrAppUIPolicyString().toastString(),
//                      type: .error)
//            return
//        }
//        
//        let userRole = joinRoomView.selectedUserRole
//        
//        AgoraLoading.loading()
//        
//        center.room.getRoomInfo(roomId: roomId,
//                                isQuickStart: true) { [weak self] object in
//            AgoraLoading.hide()
//            
//            let userId = FcrAppRoomUserIdCreater().quickStart(userName: userName,
//                                                              userRole: userRole,
//                                                              roomType: object.sceneType)
//            
//            let config = FcrAppJoinRoomPreCheckConfig(roomId: roomId,
//                                                      userId: userId,
//                                                      userName: userName,
//                                                      userRole: userRole,
//                                                      isQuickStart: true)
//            
//            self?.center.localStorage.writeData(userName,
//                                                key: .nickname)
//            
//            self?.joinRoomPreCheck(config: config)
//        } failure: { [weak self] error in
//            AgoraLoading.hide()
//            self?.showErrorToast(error)
//        }
    }
    
    @objc func onCreateButtonPressed(_ sender: UIButton) {
        let createRoomView = contentView.roomInputView.createRoomView
        
        guard let roomName = createRoomView.roomNameTextField.getText() else {
            showToast("fcr_login_free_toast_room_name_null".localized(),
                      type: .error)
            return
        }
        
        guard let userName = createRoomView.userNameTextField.getText() else {
            showToast("fcr_login_free_toast_nick_name_null".localized(),
                      type: .error)
            return
        }
        
        if userName.count < 2 || userName.count > 20 {
            showToast("fcr_home_toast_content_length".localized(),
                      type: .error)
            return
        }
        
        guard contentView.roomInputView.policyView.checkBox.isSelected else {
            showToast(FcrAppUIPolicyString().toastString(),
                      type: .error)
            return
        }
     
        let roomType = createRoomView.roomTypeView.selectedRoomType
        let latency = center.room.mediaStreamLatency
        
        let startTime = Int64(Date().timeIntervalSince1970 * 1000)
        let duration = Int64(center.room.duration * 60 * 1000)
        
        let userRole = FcrAppUserRole.teacher
        
        let userId = FcrAppRoomUserIdCreater().quickStart(userName: userName,
                                                          userRole: userRole,
                                                          roomType: roomType)
        
        let config = FcrAppCreateRoomConfig(roomName: roomName,
                                            roomType: roomType,
                                            userId: userId,
                                            userName: userName,
                                            startTime: startTime,
                                            duration: duration,
                                            mediaStreamLatency: latency,
                                            isQuickStart: true)
        
        center.localStorage.writeData(userName,
                                      key: .nickname)
        
        createRoom(config: config)
    }
    
    @objc func onPolicyButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    func showLoginViewController() {
        let vc = FcrAppUILoginViewController(center: center,
                                             closeIsHidden: false)
        
        let navigation = FcrAppUINavigationController(rootViewController: vc)
        
        present(navigation,
                animated: true)
    }
}

extension FcrAppUIQuickStartViewController: FcrAppCenterDelegate {
    func onLanguageUpdated(_ language: FcrAppLanguage) {
        agora_ui_language = language.proj()
        
        guard let navigation = navigationController else {
            return
        }
        
        for vc in navigation.viewControllers {
            if let `vc` = vc as? AgoraUIContentContainer {
                vc.updateViewProperties()
                
                printDebug("ui" + vc.description)
            } else {
                printDebug(vc.description)
            }
        }
        
        updateViewProperties()
    }
}

extension FcrAppUIQuickStartViewController: FcrAppRoomDelegate {
    func onRoomDurationUpdated(duration: UInt) {
        contentView.roomInputView.createRoomView.roomDuration = duration
    }
}

// MARK: - Tester
extension FcrAppUIQuickStartViewController: FcrAppTesterDelegate {
    func tester() {
        contentView.headerView.titleLabel.addTarget(self,
                                                    action: #selector(onTestButtonPressed(_ :)),
                                                    for: .touchUpInside)
    }
    
    @objc func onTestButtonPressed(_ sender: UIButton) {
        center.tester.switchMode()
    }
    
    func isTest() {
        center.tester.delegate = self
        onIsTestMode(center.tester.isTest)
    }
    
    func onIsTestMode(_ isTest: Bool) {
        contentView.headerView.testTag.isHidden = !isTest
        
        contentView.roomInputView.policyView.checkBox.isSelected = isTest
        
        if isTest {
            settingItems = [.generalSetting(FcrAppUISettingItem.GeneralItem.quickStartTestList()),
                            .aboutUs(FcrAppUISettingItem.AboutUsItem.allCases)]
        } else {
            settingItems = [.generalSetting(FcrAppUISettingItem.GeneralItem.quickStartList()),
                            .aboutUs(FcrAppUISettingItem.AboutUsItem.allCases)]
        }
    }
    
    func popToMainViweController() -> Bool {
        guard let navigation = navigationController else {
            return false
        }
            
        for vc in navigation.viewControllers where vc is FcrAppUIMainViewController {
            navigation.popViewController(animated: true)
            return true
        }
        
        return false
    }
}
