# auto-merge-two-remote-branch-shell
this shell can help you merge two diff remote branch and cab push merge to master if you want


#中文說明
#如果有compler 需求 請安裝 ant 並設置 ANT_HOME and ADD %ANT_HOME%/bin to path
#shell 會 嘗試執行 根目錄的 build-class.xml 進行ant -->有需要可自行改成 for build.xml
#shell 會 嘗試搜尋資料夾下的 bat檔 如果發現 會執行--->for 包裝 min.js  --->使用 powershell 執行 如果沒有 powershell 請自己實作這一部分
#shell 最後會嘗試開啟一個網頁 是製作者想要他執行完後 直接開jenkis讓使用者按下佈署案件-->使用 windows edge 如果有需求可以自己修改想要的瀏覽器
可參考 https://codertw.com/%E7%A8%8B%E5%BC%8F%E8%AA%9E%E8%A8%80/320609/
ANT下載位置 http://apache.stu.edu.tw//ant/binaries/apache-ant-1.10.7-bin.zip


要自行維護 appRemoteMap.txt 資料
範例如下
projectName;remote one URL;remore two URL;結束後你想開啟的網站URL
like below
myproject;ssh://git@gitlab.gittest.com.tw:10022/CLOUD/myproject.git;ssh://git@127.0.0.1:10022/CLOUD/myproject.git;http://127.0.0.1:8080/job/CLOUD_/

參數範例 開啟 git bash 並執行
sh uploadEdition.sh myproject develop develop TO_MASTER
結果-->將remote one branch develop merge to remote two branch develop and mergee to master (if u did not add TO_MASTER then mergee to master will not happen)

如果完成後須要刪除資料夾可以自己打開註解
