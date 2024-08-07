import subprocess

def insertPrivateMethod(findTag: str, 
                        content: str, 
                        filePath: str):
        file_path = filePath  # 文件路径

        # 读取文件内容
        with open(file_path, "r") as file:
            lines = file.readlines()
        
        # 寻找目标行的索引
        index = -1
        for i in range(len(lines)):
            if findTag in lines[i]:
                index = i
                break

        print("insert private method: find index " + str(index))

        # 插入新行
        if index != -1:
            lines.insert(index - 1, content)

        # 写入修改后内容
        with open(file_path, "w") as file:
            file.writelines(lines)

def insert1():
    tag_code = "AgoraClassroomSDK.launch(config)"

    insert_content_1 = "let sel = NSSelectorFromString(\"setEnvironment:\")"
    insert_content_2 = "AgoraClassroomSDK.perform(sel, with: center.urlGroup.environment.intValue)"

    environment_code = "\n\t\t" + insert_content_1 + "\n\t\t" + insert_content_2 + "\n"
    file_path = "../../../App/AgoraEducation/UI/Root/FcrAppUICoreViewController.swift"

    insertPrivateMethod(tag_code, 
                        environment_code,
                        file_path)
    
def insert2():
    tag_code = "proctor.launch"

    insert_content_1 = "proctor.setParameters([\"environment\": center.urlGroup.environment.intValue])"
    
    environment_code = "\n\t\t" + insert_content_1 + "\n"
    file_path = "../../../App/AgoraEducation/UI/Root/FcrAppUICoreViewController.swift"

    insertPrivateMethod(tag_code, 
                        environment_code,
                        file_path)
    
def printFile():
        file_path = "../../../App/AgoraEducation/UI/Root/FcrAppUICoreViewController.swift"
        
        result = subprocess.run(['cat', file_path],
                                capture_output=True,
                                text=True)
        
        print(result.stdout)

insert1()
insert2()
printFile()
