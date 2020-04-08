# HANDEL MEARGE REMOTE BRANCH TO  ANOTHER  REMOTE DEVELOP AND MASTER
# USEAGE sh this.sh $PROJECT_NAME  $SOURCE_BRANCH_NAME $TARGET_BRANCH_NAME $TO_MASTER
# TODO CHECK BUILD SUCCESSFUL check permeter build js
# TODO  use git rev-parse HEAD TO MODIFY PATH

#紀錄 工作目錄
WORK_PATH=$(cd `dirname $0`; pwd)
echo "work dir : $WORK_PATH"
#Begin init parameter
OUTSIDE_REMOTE_URL=""
INSIDE_REMOTE_URL=""
JENKINS_JOB_URL=""
VERSION_ID=`git rev-parse`
PROJECT_NAME=$1
SOURCE_BRANCH_NAME=$2
TARGET_BRANCH_NAME=$3
TO_MASTER=$4

#function PART u can ingore here  START---->

runBat(){ #讀bat第一行並執行 因為第二行 pause 會error 

	cd $1
	echo "build js $2"
	powershell_exe="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
	echo "$1 $2"
  	runBat_count=0
	exec < $2
	while read line
	do
		runBat_count=`expr $runBat_count + 1`
		if [ $runBat_count -eq 1 ];then
			buildcmd="$powershell_exe $line"
			$buildcmd
		fi
	done
	cd $WORK_PATH/$PROJECT_NAME #返回project root 位置

}

scandirForRunBat(){ #歷遍dir尋找 bat檔

	if [[ "$1" != *"build" ]];then
		for element in `ls $1`
		do
			dir_or_file=$1"/"$element
			#echo "$dir_or_file  dir_or_file"
			if [ -d $dir_or_file ] && [ "dir_or_file" != "./build" ] && [ "dir_or_file" != "./bin" ]
			then
				#echo "$dir_or_file  is dir"
				scandirForRunBat $dir_or_file
			else
				if [ -f $dir_or_file ]
				then
					if [[ "$dir_or_file" == *".bat" ]];then	
						echo "$dir_or_file  bat"
						runBat $1 $element
					fi
				fi
			fi
		done
	fi
}


changePath(){ #讀取PATH 並取代第一次碰到的 public static String EAR_VERSION = 

	cd $1
	echo "build js $2"
	compareStr="EAR_VERSION"
	runPath_count=0
	replaceStr=""
	exec < $2
	while read line
	do
		if [[ $line == *"$compareStr"* ]] && [ runPath_count -eq 0 ]; then #比較出第一次讀到含有 EAR_VERSION 的行數和字串
		  runPath_count=`expr $runBat_count + 1`
		  replaceStr=$line
		fi
	done
	
	if [ -z "$replaceStr" ] ;then
		sed -i ‘s/"$line"/"	public static String EAR_VERSION = \"$VERSION_ID\";// "/g’ $2
	fi
	
	
	cd $WORK_PATH/$PROJECT_NAME #返回project root 位置

}

scandirForChangePath(){ #歷遍dir尋找 bat檔

	if [[ "$1" != *"build" ]];then
		for element in `ls $1`
		do
			dir_or_file=$1"/"$element
			#echo "$dir_or_file  dir_or_file"
			if [ -d $dir_or_file ] && [ "dir_or_file" != "./build" ] && [ "dir_or_file" != "./bin" ]
			then
				#echo "$dir_or_file  is dir"
				scandirForChangePath $dir_or_file
			fi
			if [ -f $dir_or_file ]
			then
				if [[ "$dir_or_file" == *"Path.java" ]];then	
					echo "$dir_or_file  Path.java"
					changePath $1 $element
				fi
			fi
		done
	fi
}

run_all_bat()
{

	scandirForRunBat .

}
#function PART u can ingore here  END <-----


echo "DO JOB GO MERGE $PROJECT_NAME"

#step0 read map file to get remote url for outside
	#file read line
	#and slipe line to get REMOTE URL
	echo "	STEP 0 read appRemoteMap.txt TO GET REMOTE URL"

		filename='appRemoteMap.txt'
		exec < $filename
		while read line
		do
			#使用;切每一行字串 以project mapping 出要讀取資料的行數
			OIFS="$IFS"
			IFS=';'
			read -a new_string <<< "$line"
			IFS="$OIFS"
			count=0
			isProject=0 #用來標記該行數符合 project name
			for i in "${new_string[@]}"
			do     
			   count=`expr $count + 1`
			   if [ $count -eq 1 ] && [ "$PROJECT_NAME" = "$i" ];then
					isProject=1;
			   fi
			   if [ $count -eq 2 ] && [ $isProject -eq 1 ];then	#設定 OUT GITLAB 位置
					OUTSIDE_REMOTE_URL=$i
					echo "		OUTSIDE REMOTE : $OUTSIDE_REMOTE_URL"
			   fi
			   if [ $count -eq 3 ] && [ $isProject -eq 1 ];then #設定 INNER GITLAB 位置
					INSIDE_REMOTE_URL=$i
					echo "		INSIDE REMOTE  : $INSIDE_REMOTE_URL"
			   fi
			   if [ $count -eq 4 ] && [ $isProject -eq 1 ];then #設定 JENKINS_JOB_URL 位置
					JENKINS_JOB_URL=$i
					echo "		JENKINS_JOB_URL: $JENKINS_JOB_URL"
			   fi
			done
		done

#step1 do clone from remote and add inside remote
echo "%%%%step1 do clone from remote and add inside remote =====>"
git clone $OUTSIDE_REMOTE_URL
cd $PROJECT_NAME
git remote add inside $INSIDE_REMOTE_URL
git remote -v
git fetch inside
git branch inside_$TARGET_BRANCH_NAME inside/$TARGET_BRANCH_NAME
echo "%%%%step1 do clone from remote and add inside remote <====="

#step2 do pull and compler
echo "%%%%step2 do pull and compler =====>"
echo "build class js"
git checkout git checkout $SOURCE_BRANCH_NAME
git pull
ant -f build-class.xml
#js
run_all_bat
git add *
git commit -m "build class & js for merge"
git push origin
echo "%%%%step2 do pull and compler <====="

#step3
echo "%%%%step3 do pull and compler =====>"
git checkout inside_$TARGET_BRANCH_NAME
git pull
git merge origin/$SOURCE_BRANCH_NAME
ant -f build-class.xml #class
#js
run_all_bat
git add *
git commit -m "build class & js for merge inside"
git push origin
git push inside HEAD:$TARGET_BRANCH_NAME
echo "%%%%step3 do pull and compler <====="

#step 4 check if need to merge to master
echo "%%%%step4 check if need to merge to masterr =====>"
if [ "$TO_MASTER" == "TO_MASTER" ];then
	echo "do MASTER MERGE";
	git branch inside_master inside/master
	git checkout inside_master
	git pull
	git merge inside_$TARGET_BRANCH_NAME
	git push origin
	git push inside HEAD:master
fi
echo "%%%%step4 check if need to merge to masterr <====="

echo " complete";
cd ../
#rm -r $PROJECT_NAME #刪除目錄

echo " open jenkis browser to check";
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" $JENKINS_JOB_URL

echo "done"
