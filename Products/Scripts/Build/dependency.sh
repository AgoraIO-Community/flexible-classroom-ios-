#!/bin/sh

# Difference
# Dependency libs
# AgoraClassroomSDK_iOS
# AgoraEduUI
# AgoraProctorSDK
# AgoraProctorUI
# AgoraWidgets
# AgoraEduCore 
# AgoraWidget
# AgoraUIBaseViews
Artifactory_iOS_URL="https://artifactory.agoralab.co/artifactory/AD_repo/aPaaS/iOS"

AgoraClassroomSDK_iOS_URL="${Artifactory_iOS_URL}/AgoraClassroomSDK_iOS/feature_2.8.105_im_group/dev/AgoraClassroomSDK_iOS_2.8.105.zip"
AgoraEduUI_URL="${Artifactory_iOS_URL}/AgoraEduUI/feature_2.8.105_im_group/dev/AgoraEduUI_2.8.105.zip"

AgoraProctorSDK_URL="${Artifactory_iOS_URL}/AgoraProctorSDK/release_1.0.2/dev/AgoraProctorSDK_1.0.2.zip"
AgoraProctorUI_URL="${Artifactory_iOS_URL}/AgoraProctorUI/release_1.0.2/dev/AgoraProctorUI_1.0.2.zip"

AgoraWidgets_URL="${Artifactory_iOS_URL}/AgoraWidgets/feature_2.8.105_im_group/dev/AgoraWidgets_2.8.105.zip"

AgoraEduCore_URL="${Artifactory_iOS_URL}/AgoraEduCore/release_2.8.105/dev/AgoraEduCore_2.8.105.zip"
AgoraWidget_URL="${Artifactory_iOS_URL}/AgoraWidget/release_2.8.105/dev/AgoraWidget_2.8.0.zip"
AgoraFoundation_URL="${Artifactory_iOS_URL}/AgoraFoundation/feature_3.4.0_rx/dev/AgoraFoundation_3.4.0_dev.zip"
AgoraUIBaseViews_URL="${Artifactory_iOS_URL}/AgoraUIBaseViews/release_2.8.105/dev/AgoraUIBaseViews_2.8.101.zip"

Dep_Array_URL=("${AgoraClassroomSDK_iOS_URL}" 
               "${AgoraEduUI_URL}"
               "${AgoraProctorSDK_URL}"
               "${AgoraProctorUI_URL}"
               "${AgoraWidgets_URL}"
               "${AgoraEduCore_URL}"
               "${AgoraWidget_URL}"
               "${AgoraFoundation_URL}"
               "${AgoraUIBaseViews_URL}")

Dep_Array=(AgoraClassroomSDK_iOS
           AgoraEduUI
           AgoraProctorSDK
           AgoraProctorUI 
           AgoraWidgets
           AgoraEduCore
           AgoraWidget
           AgoraFoundation
           AgoraUIBaseViews)

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# parameters
Repo_Name=$1

startPrint "${Repo_Name} Download Dependency Libs"

parameterCheckPrint ${Repo_Name}

# path
Root_Path="../../.."

for SDK_URL in ${Dep_Array_URL[*]} 
do
    echo ${SDK_URL}
    python3 ${WORKSPACE}/artifactory_utils.py --action=download_file --file=${SDK_URL}
done

errorPrint $? "${Repo_Name} Download Dependency Libs"

echo Dependency Libs

ls

for SDK in ${Dep_Array[*]}
do
    Zip_File=${SDK}*.zip

    # move
    mv -f ./${Zip_File}  ${Root_Path}/

    # unzip
    ${Root_Path}/../apaas-cicd-ios/Products/Scripts/SDK/Build/v1/unzip.sh ${SDK} ${Repo_Name}
done

endPrint $? "${Repo_Name} Download Dependency Libs"