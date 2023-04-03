#!/bin/bash

# 安装规则API程序及环境
header(){
	printf "
	###################################################################
	#  RuleAPI便捷安装脚本V1.0.1beta                                  #
	#  详细信息请参考：https://www.ruletree.club/archives/2661/       #
	#-----------------------------------------------------------------#
	#  RuleAPI便捷安装脚本(Ubuntu/Deepin版本)V1.0.0                   #
	#  二次改写站长(清韵云)：https://community.qingyundrive.top       #
	#-----------------------------------------------------------------#
	#  Copyright @2022 ruleree.club All rights reserved.              #
	#  Copyright @2023 QingYun All rights reserved.(二次改写)         #
	###################################################################
	"
}

# 判断是否安装有 OpenJDK
isJdk(){
    echo '------判断是否已存在JDK------'
    dpkg -l | grep openjdk
    if [ $? -eq 0 ]
    then
        read -r -p "继续执行将卸载系统自带JDK? [Y/n] " jdkinput
        case $jdkinput in
            [yY][eE][sS]|[yY])
                apt-get -y remove openjdk* &> /dev/null
                apt-get -y remove tzdata-java* &> /dev/null
                ;;
            [nN][oO]|[nN])
                echo "你放弃了操作。"
                ;;
            *)
                echo "你输入了错误的文字，不过是小问题。"
                echo "重新执行安装脚本就行，不要方，记得是输入y或者n。"
                ;;
        esac
    fi
}


# 确认卸载系统自带后，安装新的 JDK 版本
installJdk(){
    echo '------开始安装 JDK------'
    cd /opt
    wget -c http://shell.ruletree.club/jdk-8u311-linux-x64.tar.gz
    tar zxvf /opt/jdk-8u311-linux-x64.tar.gz -C /opt > /dev/null 2>&1
    echo '# JAVA-8u311' >> /etc/profile
    echo 'JAVA_HOME=/opt/jdk1.8.0_311' >> /etc/profile
    echo 'JAVA_BIN=/opt/jdk1.8.0_311/bin' >> /etc/profile
    echo 'PATH=$PATH:$JAVA_BIN' >> /etc/profile
    echo 'CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
    echo 'export JAVA_HOME JAVA_BIN PATH CLASSPATH' >> /etc/profile
    source /etc/profile
    output=$(java -version)
    echo $output
}
# 获取帮助信息 
showhelp(){
	echo "-install为安装，包括环境和包";
	echo "-start为运行RuleApi包";
	echo "-stop为停止RuleApi包";
	echo "-uninstall为卸载RuleApi包";
	echo "-update为更新RuleApi包";
	echo "-restart为重启RuleApi包";
	echo "-uninstall为卸载RuleApi包（不删除环境和配置文件）";
}

# 安装并运行 RuleAPI
installApi(){
    echo "------开始安装coreutils------"
    apt-get install coreutils -y 
	echo "------开始运行RuleAPI------"
	# 确认卸载系统自带后，安装新的jdk版本 
	cd /opt
	wget -c http://shell.ruletree.club/RuleApi.jar
	wget -c http://shell.ruletree.club/application.properties
	wget -c http://shell.ruletree.club/apiResult.php
	chmod 777 application.properties
	chmod 777 RuleApi.jar
	chmod 777 ruleapi.sh
	mkdir -p '/opt/files/static'
	cd /opt
	echo "本地文件存放配置成功"
	echo "------参数设置环节"
	echo "------开始运行这里用于设置基本的信息，设置错误也没有关系。"
	echo "------可以前往服务器/opt/application.properties进行手动编辑修改，修改完成后，重启RuleApi生效"
	echo "------Mysql和Redis默认链接是本地，所以自己提前安装好吧，如果是远程的，就去/opt/application.properties手动修改"
	echo "------如果全都搞不懂，可加入官方交流群。"
	echo "------最后，请确认你已经安装了typecho，并且Ruleapi和typecho使用同一个数据库"
	echo " "
	echo " "
	echo -n "请输入运行端口（输入8080或者其它端口，千万别80或者443）："
	read port
	echo -n "请输入数据库名："
	read sqlname
	echo -n "请输入数据库用户名:"
	read sqluser
	echo -n "请输入数据库密码:"
	read sqlpass
	echo -n "请输入redis密码（一般是空）:"
	read redispass
	echo -n "请输入系统管理密码（建议英文加数字）:"
	read webkey
	echo " "
	echo "-------基础配置"
	echo "RuleApi运行端口 $port"
	echo "RuleApi数据库名 $sqlname"
	echo "RuleApi数据库用户名 $sqluser"
	echo "RuleApi数据库密码 $sqlpass"
	echo "RuleApi Redis密码 $redispass"
	echo "系统管理密码 $webkey"
	#开始写入 
	read -r -p "将写入配置文件并运行RuleApi? [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
    		sed -i "s/server.port=8080/server.port=${port}/g" /opt/application.properties
    		sed -i "s/typechoapi/${sqlname}/g" /opt/application.properties
    		sed -i "s/spring.datasource.username=root/spring.datasource.username=${sqluser}/g" /opt/application.properties
    		sed -i "s/spring.datasource.password=root/spring.datasource.password=${sqlpass}/g" /opt/application.properties
    		sed -i "s/spring.redis.password=/spring.redis.password=${redispass}/g" /opt/application.properties
    		sed -i "s/webinfo.title=/webinfo.title=${sitename}/g" /opt/application.properties
    		sed -i "s/webinfo.key=/webinfo.key=${webkey}/g" /opt/application.properties
    		
    		echo "RuleApi开始启动，请及时配置域名访问！"
    		cd /opt
    		nohup java -jar RuleApi.jar >out.txt 2>&1 &
    		echo "RuleApi启动成功！，日志输出至out.txt"
    		;;
        [nN][oO]|[nN])
    		echo "你放弃了操作，那就去手动修改吧"
           	;;
        *)
            echo "你输入了错误的文字，不过是小问题。"
            echo "去/opt/application.properties手动修改，再执行重启指令就好了。"
           	;;
   esac
}

# 停止RuleAPI 
stopApi(){
	tmp=`ps -ef | grep RuleApi | grep -v grep | awk '{print $2}'`
	# echo ${tmp}
	for id in $tmp
	do
	kill -9 $id
	# echo "killed $id"
	done
}

# 检查RuleAPI进程是否运行
monitor(){
    tmp=`ps -ef | grep RuleApi | grep -v grep | awk '{print $2}'`
    if [ ! -n "$tmp" ]; then
      echo "RuleApi无进程，开始执行重启"
      stopApi 
	  startApi
    else
      echo ${tmp}
      echo "RuleApi运行正常"
    fi
}

rmApi(){
    stopApi
    cd /opt
    rm -f /opt/RuleApi.jar
    rm -f /opt/application.properties
    rm -rf $0
    echo "RuleApi卸载成功，再见！"
}
# 重启RuleAPI
startApi(){
	source /etc/profile
	cd /opt
	nohup java -jar RuleApi.jar >out.txt 2>&1 &
    echo "RuleApi启动成功！，日志输出至out.txt"
}
# 更新项目
update(){
    stopApi
    sudo apt-get install coreutils -y
    
    cd /opt
    rm -rf $0
    wget -c http://shell.ruletree.club/ruleapi.sh
    chmod 777 ruleapi.sh
    
    cd /opt
    rm -f /opt/RuleApi.jar
    wget -c http://shell.ruletree.club/RuleApi.jar
    chmod 777 RuleApi.jar
    
    rm -f /opt/upfile/application.properties
    rm -f /opt/upfile/apiResult.php
    
    mkdir upfile
    cd /opt/upfile
    wget -c http://shell.ruletree.club/application.properties
    wget -c http://shell.ruletree.club/apiResult.php
    
    cd /opt
    
    echo "文件更新成功！"
    echo "新版配置文件和apiResult.php，已下载至/opt/upfile"
    echo "开始启动RuleApi"
    startApi
}
# 更新至 beta 版本
updateBeta(){
    stopApi
    sudo apt-get install coreutils -y
    
    cd /opt
    rm -rf $0
    wget -c http://shell.ruletree.club/ruleapi.sh
    chmod 777 ruleapi.sh
    
    cd /opt
    rm -f /opt/RuleApi.jar
    wget -c http://shell.ruletree.club/beta/RuleApi.jar
    chmod 777 RuleApi.jar
    
    rm -f /opt/upfile/application.properties
    rm -f /opt/upfile/apiResult.php
    
    mkdir upfile
    cd /opt/upfile
    wget -c http://shell.ruletree.club/beta/application.properties
    wget -c http://shell.ruletree.club/beta/apiResult.php
    
    cd /opt
    
    echo "已更新是最新beta版本！"
    echo "新版配置文件和apiResult.php，已下载至/opt/upfile"
    echo "开始启动RuleApi"
    startApi
}

while [ $1 ]; do
	case $1 in
		'install')
			header
			isJdk
			installJdk
			installApi
			exit
			;;
		'monitor')
		    monitor
			exit
			;;
		'start')
		    stopApi
			startApi
			exit
			;;
		'stop')
			stopApi
			exit
			;;
		'restart')
			stopApi
			startApi
			exit
			;;
		'update')
			update
			exit
			;;
		'updateBeta')
			updateBeta
			exit
			;;
		'uninstall')
			rmApi
			exit
			;;
		'help')
			showhelp
			exit
			;;
		* )
			showhelp
			exit
			;;
	esac
	shift
done

