# --------------------------------------------------------------------------------------------------------------------------
# =====================================
# ========== Guidelines ===============
# =====================================
#
# -------------------------------------
# ---- Common Environment Variable ----
# -------------------------------------
# ${Package_Publish} (boolean): Indicates whether it is build package process, e.g. If you want to get one CI SDK package.
# ${Clean_Clone} (boolean): Indicates whether it is clean build. If true, CI will clean ${output} for each build process.
# ${is_tag_fetch} (boolean): If true, git checkout will work as tag fetch mode.
# ${is_official_build} (boolean): Indicates whether it is official build release.
# ${arch} (string): Indicates build arch set in build pipeline.
# ${short_version} (string): CI auto generated short version string.
# ${release_version} (string): CI auto generated version string.
# ${build_date} (string(yyyyMMdd)): Build date generated by CI.
# ${build_timestamp} (string (yyyyMMdd_hhmm)): Build timestamp generated by CI.
# ${platform} (string): Build platform generated by CI.
# ${BUILD_NUMBER} (string): Build number generated by CI.
# ${WORKSPACE} (string): Working dir generated by CI.
#
# -------------------------------------
# ------- Job Custom Parameters -------
# -------------------------------------
# If you added one custom parameter via rehoboam website, e.g. extra_args.
# You could use $extra_args to get its value.
#
# -------------------------------------
# ------------- Input -----------------
# -------------------------------------
# ${source_root}: Source root which checkout the source code.
# ${WORKSPACE}: project owned private workspace.
#
# -------------------------------------
# ------------- Output ----------------
# -------------------------------------
# Generally, we should put the output files into ${WORKSPACE}
# 1. for pull request: Output files should be zipped to test.zip, and then copy to ${WORKSPACE}.
# 2. for pull request (options): Output static xml should be static_${platform}.xml, and then copy to ${WORKSPACE}.
# 3. for others: Output files should be zipped to anything_you_want.zip, and then copy it to {WORKSPACE}.
#
# -------------------------------------
# --------- Avaliable Tools -----------
# -------------------------------------
# Compressing & Decompressing: 7za a, 7za x
#
# -------------------------------------
# ----------- Test Related ------------
# -------------------------------------
# PR build, zip test related to test.zip
# Package build, zip package related to package.zip
#
# -------------------------------------
# ------ Certification Related --------
# -------------------------------------
# ./sign /Users/yy/Downloads/WayangFFmpeg_for_iOS_rel.v4.0.1_57517_20220914_0306.ipa
# This command will auto-sign the ipa specified according to project dailybuild setting on rehoboam.
# The output is:
#  ./WayangFFmpeg_for_iOS_rel.v4.0.1_57517_20220914_0306_${alias}.ipa
#
# -------------------------------------
# ------ Publish to artifactory -------
# -------------------------------------
# [Download] artifacts from artifactory:
# python3 ${WORKSPACE}/artifactory_utils.py --action=download_file --file=ARTIFACTORY_URL
#
# [Upload] artifacts to artifactory:
# python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=FILEPATTERN --project
# Sample Code:
# python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=*.zip --project
#
# [Upload] artifacts folder to artifactory
# python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=FILEPATTERN --project --with_folder
# Sample Code:
# python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=./folder --project --with_folder
#
# ========== Guidelines End=============
# --------------------------------------------------------------------------------------------------------------------------

echo Package_Publish: $Package_Publish
echo is_tag_fetch: $is_tag_fetch
echo arch: $arch
echo source_root: %source_root%
echo output: /tmp/jenkins/${project}_out
echo build_date: $build_date
echo build_time: $build_time
echo release_version: $release_version
echo short_version: $short_version
echo pwd: `pwd`
echo BUILD_NUMBER: ${BUILD_NUMBER}

export all_proxy=http://10.80.1.174:1080

# difference
App_Name="AgoraCloudClass"
Target_Name="AgoraEducation"
Project_Name="AgoraEducation"
Repo_Name="open-flexible-classroom-ios"

# import
. ../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# mode
App_Array=(Debug)

if [ ${is_official_build} = true ]; then
    App_Array=(Release)
fi

# path
CICD_Scripts_Path="../apaas-cicd-ios/Products/Scripts"
CICD_Build_Path="${CICD_Scripts_Path}/App/Build"
CICD_Pack_Path="${CICD_Scripts_Path}/App/Pack"
CICD_Upload_Path="${CICD_Scripts_Path}/App/Upload"

Products_Path="./Products"
Build_Path="${Products_Path}/Scripts/Build"
Products_App_Path="${Products_Path}/App"

# dependency
${Build_Path}/dependency.sh ${Repo_Name}

# podfile
${Build_Path}/podfile.sh 1

# build
for Mode in ${App_Array[*]} 
do
  ${CICD_Build_Path}/v1/build.sh ${App_Name} ${Target_Name} ${Project_Name} ${Mode} ${Repo_Name} false
  
  errorPrint $? "${App_Name} ${Mode} build"
done

# sign
echo pwd: `pwd`

${WORKSPACE}/sign ${Products_App_Path}/${App_Name}.ipa

ls ${Products_App_Path}

errorPrint $? "${App_Name} sign"

# publish
if [ "${Package_Publish}" = true ]; then
    ${CICD_Pack_Path}/v1/package.sh ${App_Name} ${Repo_Name}

    errorPrint $? "${App_Name} package"

    ${CICD_Upload_Path}/v1/upload_artifactory.sh ${App_Name} ${Repo_Name}

    errorPrint $? "${App_Name} upload"
fi

unset all_proxy
