#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import os
import re
from enum import Enum

# Base Enum
class PODMODE(Enum):
    Source = 0
    Binary = 1

# Base Data
ExtcuteDir = "../../../App/".strip()
BaseProjPath = ExtcuteDir + "AgoraEducation" + ".xcodeproj"

SourcePodContent = """
  pod 'AgoraClassroomSDK_iOS/Source',   :path => '../../open-cloudclass-ios/AgoraClassroomSDK_iOS_Local.podspec'
  pod 'AgoraEduUI/Source',              :path => '../../open-cloudclass-ios/AgoraEduUI_Local.podspec'
    
  pod 'AgoraProctorSDK/Source',         :path => '../../open-proctor-ios/AgoraProctorSDK_Local.podspec'
  pod 'AgoraProctorUI/Source',          :path => '../../open-proctor-ios/AgoraProctorUI_Local.podspec'
    
  pod 'AgoraWidgets/Source',            :path => '../../open-apaas-extapp-ios/AgoraWidgets_Local.podspec'
  
  # close source libs
  pod 'AgoraEduCore/Source',            :path => '../../cloudclass-ios/AgoraEduCore_Local.podspec'
  pod 'AgoraRte/Source',                :path => '../../common-scene-sdk/AgoraRte_Local.podspec'
  
  pod 'AgoraFoundation/Source',             :path => '../../apaas-common-libs-ios-ng/AgoraFoundation_Local.podspec'
  pod 'AgoraUIBaseViews/Source',        :path => '../../apaas-common-libs-ios/AgoraUIBaseViews_Local.podspec'
  pod 'AgoraWidget/Source',             :path => '../../apaas-common-libs-ios/AgoraWidget_Local.podspec'
"""

BinaryPodContent = """
  pod 'AgoraClassroomSDK_iOS/Binary', :path => '../AgoraClassroomSDK_iOS_Local.podspec'
  pod 'AgoraEduUI/Binary‘,            :path => '../AgoraEduUI_Local.podspec'
  
  pod 'AgoraProctorSDK/Binary',       :path => '../AgoraProctorSDK_Local.podspec'
  pod 'AgoraProctorUI/Binary‘,        :path => '../AgoraProctorUI_Local.podspec'
  
  pod 'AgoraWidgets/Binary',          :path => '../AgoraWidgets_Local.podspec'
  
  # close source libs
  pod 'AgoraEduCore/Binary',          :path => '../AgoraEduCore_Local.podspec'
  pod 'AgoraUIBaseViews/Binary',      :path => '../AgoraUIBaseViews_Local.podspec'
  pod 'AgoraWidget/Binary',           :path => '../AgoraWidget_Local.podspec'
  pod 'AgoraFoundation/Binary',       :path => '../AgoraFoundation_Local.podspec'
"""

BaseParams = {"podMode": PODMODE.Source,
              "updateFlag": False}

# Base Functions
def HandlePath(path):
    path = path.strip()
    if os.path.exists(path) == False:
        print  ('Invalid Path!' + path)
        sys.exit(1)

def generatePodfile():
    podFilePath = ExtcuteDir + '%s' % 'Podfile'
    
    headerKey = "# agora libs header"
    footerKey = "# agora libs footer"
    
    lineNumber = 0
    headerFoundLine = 0
    footerFoundLine = 0
    
    with open(podFilePath,'r') as file:
        lines = file.readlines()

    for line in lines:
        lineNumber += 1
        
        if headerKey in line:
            headerFoundLine = (lineNumber - 0)

        if footerKey in line:
            footerFoundLine = (lineNumber - 1)

    if BaseParams["podMode"] == PODMODE.Source:
        lines[headerFoundLine:footerFoundLine] = SourcePodContent.lstrip("\n")
    elif BaseParams["podMode"] == PODMODE.Binary:
        lines[headerFoundLine:footerFoundLine] = BinaryPodContent.lstrip("\n")
    
    with open(podFilePath,'w') as file:
        file.writelines(lines)
 
def executePod():
    podFilePath = ExtcuteDir + '/%s' % 'Podfile'
    HandlePath(BaseProjPath)
    HandlePath(podFilePath)

    generatePodfile()

    # 改变当前工作目录到指定的路径
    os.chdir(ExtcuteDir)
    
    print('====== pod install log ======')
    
    os.system('export LANG=en_US.UTF-8')

    os.system('rm -rf Podfile.lock')

    if BaseParams["updateFlag"] == True:
        os.system('pod install --repo-update')
    else:
        os.system('pod install --no-repo-update')

def main():
    paramsLen = len(sys.argv)
    if paramsLen == 1:
        sys.exit(1)
    else:
        # 0为source pod, 1为binary pod
        PodMode = sys.argv[1]
    
    if PodMode == "0":
        BaseParams["podMode"] = PODMODE.Source
    else:
        BaseParams["podMode"] = PODMODE.Binary
    
    print('Pod Mode: ' + BaseParams["podMode"].name)
    
    executePod()

if __name__ == '__main__':
    main()
