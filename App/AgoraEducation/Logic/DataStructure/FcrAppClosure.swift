//
//  FcrAppClosure.swift
//  FlexibleClassroom
//
//  Created by Cavan on 2023/7/13.
//  Copyright © 2023 Agora. All rights reserved.
//

import Foundation

typealias FcrAppCompletion = () -> (Void)
typealias FcrAppSuccess = () -> (Void)
typealias FcrAppFailure = (FcrAppError) -> (Void)
typealias FcrAppRequestSuccess = (FcrAppServerResponseObject) throws -> (Void)
typealias FcrAppStringCompletion = (String) -> (Void)
typealias FcrAppBoolCompletion = (Bool) -> (Void)
typealias FcrAppDateCompletion = ((Date) -> Void)
typealias FcrAppUICreatedRoomResultCompletion = (FcrAppUICreatedRoomResult) -> (Void)
typealias TestTokenSuccessCompletion = (String,String) -> (Void)
