//
//  FcrAppUIMain+Extension.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2023/8/22.
//  Copyright © 2023 Agora. All rights reserved.
//

import AgoraClassroomSDK_iOS
import AgoraUIBaseViews
import AgoraProctorSDK

extension FcrAppUIMainViewController: AgoraUIContentContainer {
    func initViews() {
        view.addSubview(headerView)
        view.addSubview(roomListComponent.view)
        
        roomListComponent.delegate = self
        
        // Join view
        headerView.joinActionView.button.addTarget(self,
                                                   action: #selector(onJoinButtonPressed(_ :)),
                                                   for: .touchUpInside)
        
        // Create view
        headerView.createActionView.button.addTarget(self,
                                                     action: #selector(onCreateButtonPressed(_:)),
                                                     for: .touchUpInside)
        
        // Setting button
        headerView.settingButton.addTarget(self,
                                           action: #selector(onSettingButtonPressed(_:)),
                                           for: .touchUpInside)
    }
    
    func initViewFrame() {
        headerView.mas_makeConstraints { make in
            let height: CGFloat = (UIDevice.current.isSmallPhone ? 198 : 226)
            
            make?.left.top().right().equalTo()(0)
            make?.height.equalTo()(height)
        }
        
        roomListComponent.view.mas_makeConstraints { make in
            let offset: CGFloat = FcrAppUIFrameGroup.cornerRadius24
            
            make?.top.equalTo()(headerView.mas_bottom)?.offset()(-offset)
            make?.left.right().bottom().equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        headerView.updateViewProperties()
        
        roomListComponent.updateViewProperties()
        
        headerView.backgroundColor = .clear
        
        view.backgroundColor = .white
    }
    
    func createSettingList() -> [FcrAppUISettingItem] {
        let list: [FcrAppUISettingItem]
        
        if center.isMainLandChinaIP {
            list = [.generalSetting(FcrAppUISettingItem.GeneralItem.mainLandStartList()),
                    .aboutUs(FcrAppUISettingItem.AboutUsItem.allCases)]
        } else {
            list = [.generalSetting(FcrAppUISettingItem.GeneralItem.startList()),
                    .aboutUs(FcrAppUISettingItem.AboutUsItem.allCases)]
        }
        
        return list
    }
    
    func refreshRoomList() {
        guard center.isLogined else {
            return
        }
        
        roomListComponent.refresh()
    }
}

private extension FcrAppUIMainViewController {
    @objc func onJoinButtonPressed(_ sender: UIButton) {
//        let vc = FcrAppUIJoinRoomController(center: center) { [weak self] config in
//            self?.joinRoomPreCheck(config: config)
//        }
//        
//        presentViewController(vc,
//                              animated: true)
    }
     
    @objc func onCreateButtonPressed(_ sender: UIButton) {
        let vc = FcrAppUICreateRoomViewController(center: center,
                                                  roomTypeList: roomTypeList,
                                                  optionList: createRoomOptionList) { [weak self] result in
            self?.roomListComponent.addedNotice()
            
            if result.joinImmediately {
                let config = FcrAppJoinRoomPreCheckConfig(roomId: result.roomId,
                                                          userId: result.userId,
                                                          userName: result.userName,
                                                          userRole: result.userRole)
                
                self?.joinRoomPreCheck(config: config)
            }
        }
        
        present(vc,
                animated: true)
    }
    
    @objc func onSettingButtonPressed(_ sender: UIButton) {
        let vc = FcrAppUISettingsViewController(center: center,
                                                dataSource: settingItems)
        
        navigationController?.pushViewController(vc,
                                                 animated: true)
    }
}

extension FcrAppUIMainViewController: FcrAppUIRoomListControllerDelegate {
    func onSelectedRoomToJoin(roomInfo: FcrAppUIRoomListItem) {
        guard let userId = center.localUser?.userId else {
            showToast("user id nil")
            return
        }
        
        let newId = FcrAppRoomUserIdCreater().start(userId: userId,
                                                    userName: roomInfo.userName,
                                                    userRole: roomInfo.userRole,
                                                    roomType: roomInfo.roomType)
        
        let config = FcrAppJoinRoomPreCheckConfig(roomId: roomInfo.getRoomId(),
                                                  userId: newId,
                                                  userName: roomInfo.userName,
                                                  userRole: roomInfo.userRole)
        
        joinRoomPreCheck(config: config)
    }
}

extension FcrAppUIMainViewController: FcrAppCenterDelegate {
    func onLanguageUpdated(_ language: FcrAppLanguage) {
        agora_ui_language = language.proj()
        
        guard let navigation = navigationController else {
            return
        }
        
        for vc in navigation.viewControllers {
            if let `vc` = vc as? AgoraUIContentContainer {
                vc.updateViewProperties()
            }
        }
        
        updateViewProperties()
    }
    
    func onLoginExpired() {
        printDebug("login expired")
        
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Tester
extension FcrAppUIMainViewController: FcrAppTesterDelegate {
    func tester() {
        headerView.titleLabel.addTarget(self,
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
        headerView.testTag.isHidden = !isTest
        
        if isTest {
            settingItems = [.generalSetting(FcrAppUISettingItem.GeneralItem.startTestList()),
                            .aboutUs(FcrAppUISettingItem.AboutUsItem.allCases)]
        } else {
            settingItems = createSettingList()
        }
    }
}
