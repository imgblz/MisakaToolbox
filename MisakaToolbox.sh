#!/bin/bash

version="v4.1.1(20220730)"
version_log="优化dd服务器的部分"


RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN="\033[0m"

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')") 

for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && break
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
    fi
done

[[ $EUID -ne 0 ]] && red "注意：请在root用户下运行脚本" && exit 1
[[ -z $SYSTEM ]] && red "换个系统？俺这不兼容..." && exit 1

about(){
    echo "#####################################################"
    echo -e "#            ${RED}Misaka Linux Toolbox  ${PLAIN}               #"
    echo -e "# ${GREEN}我的博客${PLAIN}: https://blog.imgblz.cn                  #"
    echo -e "# ${GREEN}项目地址${PLAIN}: https://github.com/imgblz/MisakaToolbox #"
    echo -e "# ${GREEN}Raw加速${PLAIN}: https://ghraw.imgblz.cn                #"
    echo "#####################################################"
}

dd_vps(){
    clear
    echo -e "脚本来自 https://github.com/bohanyang/debi"
    echo -e "此脚本过于精简，缺少大部分组件，请自行apt install -y <组件名称> 安装"
    echo -e "甲骨文ARM服务器请选择 Ubuntu 20.04 或 18.04 系统模板，暂不支持 Oracle Linux"
    echo -e "dd后你的端口为 22 账号为 root"
    echo -e "请输入密码"
    read -p "(默认: useradmin):" dd_password
    [[ -z "$dd_password" ]] && dd_password="useradmin"
    echo -e "使用中国镜像？[y/n]"
    read -p "(默认: y):" dd_china
    [[ -z "$dd_china" ]] && dd_china="y"
    curl -fLO https://ghraw.imgblz.cn/bohanyang/debi/master/debi.sh 
    chmod a+rx debi.sh
    if [[ "$dd_china" == "y" ]]; then
       sudo ./debi.sh --cdn --network-console --ethx --bbr --user root --dns '223.5.5.5 223.6.6.6' --mirror-protocol https --mirror-host mirrors.aliyun.com --security-repository mirror --ntp ntp.aliyun.com --password $dd_password
    else
       sudo ./debi.sh --cdn --network-console --ethx --bbr --user root --password $dd_password
    fi
    echo -e "确定无报错请输入y重启"
    read -p "(默认: y):" dd_reboot
    [[ -z "$dd_reboot" ]] && dd_reboot="y"
    if [[ "$dd_reboot" == "y" ]]; then
        sudo shutdown -r now 
    else
        echo -e "请截图反馈"
    fi
}

aboutx(){
    clear
    echo -e "                 About"
    echo -e "这个只是一个一堆脚本的合集罢了，方便搞事情，并无什么技术含量"
    echo -e "维护这个东东只是因为我懒！！！"
    echo -e "github反代项目都可以用，只要大家不搞事情，我就继续放这用"
    echo -e "CDN由Cloudflare提供，国内由自建反向代理提供"
    echo -e "我就是一个准大专生，啥都不会，脚本能用就行"
    echo " -------------"
    echo -e " ${GREEN}1.${PLAIN} 返回主菜单"
    echo -e " ${GREEN}2.${PLAIN} 更新到Beat版(仅供开发测试用)"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) menux ;;
        2) wget -N --no-check-certificate https://ghraw.imgblz.cn/imgblz/MisakaToolbox/Beat/MisakaToolbox.sh && bash MisakaToolbox.sh ;;
        *) menux ;;
    esac
}

check_status(){
    yellow "等下！你这vps就是逊了..."
    if [[ -z $(type -P curl) ]]; then
        yellow "安装curl..."
        if [[ ! $SYSTEM == "CentOS" ]]; then
            ${PACKAGE_UPDATE[int]}
        fi
        ${PACKAGE_INSTALL[int]} curl
    fi
    if [[ -z $(type -P sudo) ]]; then
        yellow "安装sudo..."
        if [[ ! $SYSTEM == "CentOS" ]]; then
            ${PACKAGE_UPDATE[int]}
        fi
        ${PACKAGE_INSTALL[int]} sudo
    fi

    IPv4Status=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
    IPv6Status=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)

    if [[ $IPv4Status =~ "on"|"plus" ]] || [[ $IPv6Status =~ "on"|"plus" ]]; then
        wg-quick down wgcf >/dev/null 2>&1
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
        wg-quick up wgcf >/dev/null 2>&1
    else
        v66=`curl -s6m8 https://ip.gs -k`
        v44=`curl -s4m8 https://ip.gs -k`
    fi

    if [[ $IPv4Status == "off" ]]; then
        w4="${RED}未使用WARP${PLAIN}"
    fi
    if [[ $IPv6Status == "off" ]]; then
        w6="${RED}未使用WARP${PLAIN}"
    fi
    if [[ $IPv4Status == "on" ]]; then
        w4="${YELLOW}WARP free账户${PLAIN}"
    fi
    if [[ $IPv6Status == "on" ]]; then
        w6="${YELLOW}WARP free账户${PLAIN}"
    fi
    if [[ $IPv4Status == "plus" ]]; then
        w4="${GREEN}WARP+ 或 Teams账户${PLAIN}"
    fi
    if [[ $IPv6Status == "plus" ]]; then
        w6="${GREEN}WARP+ 或 Teams账户${PLAIN}"
    fi

    if [[ -n $v66 ]] && [[ -z $v44 ]]; then
        VPSIP=0
    elif [[ -z $v66 ]] && [[ -n $v44 ]]; then
        VPSIP=1
    elif [[ -n $v66 ]] && [[ -n $v44 ]]; then
        VPSIP=2
    fi

    v4=$(curl -s4m8 https://ip.gs -k)
    v6=$(curl -s6m8 https://ip.gs -k)
    c4=$(curl -s4m8 https://ip.gs/country -k)
    c6=$(curl -s6m8 https://ip.gs/country -k)
    s5p=$(warp-cli --accept-tos settings 2>/dev/null | grep 'WarpProxy on port' | awk -F "port " '{print $2}')
    w5p=$(grep BindAddress /etc/wireguard/proxy.conf 2>/dev/null | sed "s/BindAddress = 127.0.0.1://g")
    if [[ -n $s5p ]]; then
        s5s=$(curl -sx socks5h://localhost:$s5p https://www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 8 | grep warp | cut -d= -f2)
        s5i=$(curl -sx socks5h://localhost:$s5p https://ip.gs -k --connect-timeout 8)
        s5c=$(curl -sx socks5h://localhost:$s5p https://ip.gs/country -k --connect-timeout 8)
    fi
    if [[ -n $w5p ]]; then
        w5s=$(curl -sx socks5h://localhost:$w5p https://www.cloudflare.com/cdn-cgi/trace -k --connect-timeout 8 | grep warp | cut -d= -f2)
        w5i=$(curl -sx socks5h://localhost:$w5p https://ip.gs -k --connect-timeout 8)
        w5c=$(curl -sx socks5h://localhost:$w5p https://ip.gs/country -k --connect-timeout 8)
    fi

    if [[ -z $s5s ]] || [[ $s5s == "off" ]]; then
        s5="${RED}未启动${PLAIN}"
    fi
    if [[ -z $w5s ]] || [[ $w5s == "off" ]]; then
        w5="${RED}未启动${PLAIN}"
    fi
    if [[ $s5s == "on" ]]; then
        s5="${YELLOW}WARP 免费账户${PLAIN}"
    fi
    if [[ $w5s == "on" ]]; then
        w5="${YELLOW}WARP 免费账户${PLAIN}"
    fi
    if [[ $s5s == "plus" ]]; then
        s5="${GREEN}WARP+ / Teams${PLAIN}"
    fi
    if [[ $w5s == "plus" ]]; then
        w5="${GREEN}WARP+ / Teams${PLAIN}"
    fi
}

open_ports(){
    systemctl stop firewalld.service 2>/dev/null
    systemctl disable firewalld.service 2>/dev/null
    setenforce 0 2>/dev/null
    ufw disable 2>/dev/null
    iptables -P INPUT ACCEPT 2>/dev/null
    iptables -P FORWARD ACCEPT 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    iptables -t nat -F 2>/dev/null
    iptables -t mangle -F 2>/dev/null
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    netfilter-persistent save 2>/dev/null
    green "VPS的防火墙端口已放行！"
}


bbr_script(){
    virt=$(systemd-detect-virt)
    TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
    if [[ ${virt} =~ "kvm"|"zvm"|"microsoft"|"xen"|"vmware" ]]; then
        wget -N --no-check-certificate "https://ghraw.imgblz.cn/chiakge/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
    elif [[ ${virt} == "openvz" ]]; then
        if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
            wget -N --no-check-certificate https://ghraw.imgblz.cn/mzz2017/lkl-haproxy/master/lkl-haproxy.sh && bash lkl-haproxy.sh
        else
            wget -N --no-check-certificate https://ghraw.imgblz.cn/mzz2017/lkl-haproxy/master/lkl-haproxy.sh && bash lkl-haproxy.sh
        fi
    else
        red "抱歉，你的VPS虚拟化架构暂时不支持bbr加速脚本"
    fi
}

v6_dns64(){
    wg-quick down wgcf 2>/dev/null
    v66=`curl -s6m8 https://ip.gs -k`
    v44=`curl -s4m8 https://ip.gs -k`
    if [[ -z $v44 && -n $v66 ]]; then
        echo -e "nameserver 2a01:4f8:c2c:123f::1" > /etc/resolv.conf
        green "设置DNS64服务器成功！"
    else
        red "非纯IPv6 VPS，设置DNS64服务器失败！"
    fi
    wg-quick up wgcf 2>/dev/null
}

warp_script(){
    green "请选择你接下来使用的脚本"
    echo "1. fscarmen"
    echo "2. fscarmen-docker"
    echo "3. fscarmen warp解锁奈飞流媒体脚本"
    echo "4. P3TERX"
    echo "0. 返回主菜单"
    echo ""
    read -rp "请输入选项:" warpNumberInput
	case $warpNumberInput in
        1) wget -N https://ghraw.imgblz.cn/fscarmen/warp/main/menu.sh && bash menu.sh ;;
        2) wget -N https://ghraw.imgblz.cn/fscarmen/warp/main/docker.sh && bash docker.sh ;;
        3) bash <(curl -sSL https://ghraw.imgblz.cn/fscarmen/warp_unlock/main/unlock.sh) ;;
        4) bash <(curl -fsSL https://ghraw.imgblz.cn/P3TERX/warp.sh/main/warp.sh) menu ;;
        0) menux ;;
        *) warp_script ;;
    esac
}


setChinese(){
    chattr -i /etc/locale.gen
    cat > '/etc/locale.gen' << EOF
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
EOF
    locale-gen
    update-locale
    chattr -i /etc/default/locale
    cat > '/etc/default/locale' << EOF
LANGUAGE="zh_CN.UTF-8"
LANG="zh_CN.UTF-8"
LC_ALL="zh_CN.UTF-8"
EOF
    export LANGUAGE="zh_CN.UTF-8"
    export LANG="zh_CN.UTF-8"
    export LC_ALL="zh_CN.UTF-8"
}

aapanel(){
    if [[ $SYSTEM = "CentOS" ]]; then
        yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh forum
    elif [[ $SYSTEM = "Debian" ]]; then
        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh forum
    else
        wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && sudo bash install.sh forum
    fi
}

bt(){
    if [[ $SYSTEM = "CentOS" ]]; then
        curl -sSO http://io.bt.sy/install/install_panel.sh && bash install_panel.sh forum
    elif [[ $SYSTEM = "Debian" ]]; then
        wget -O install.sh http://io.bt.sy/install/install-ubuntu_6.0.sh && sudo bash install.sh forum
    else
        wget -O install.sh http://io.yu.al/install/install-ubuntu_6.0.sh && sudo bash install.sh forum
    fi
}

tools(){
    if [[ $SYSTEM = "CentOS" ]]; then
        green "不行！用debian去"
    elif [[ $SYSTEM = "Debian" ]]; then
        apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update && apt-get install sudo curl screen -y && curl -LO https://ghraw.imgblz.cn/johnrosen1/vpstoolbox/master/vps.sh && sudo screen -U bash vps.sh
    else
        apt -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true update && apt-get install sudo curl screen -y && curl -LO https://ghraw.imgblz.cn/johnrosen1/vpstoolbox/master/vps.sh && sudo screen -U bash vps.sh
    fi
}

xui() {
    echo "                            "
    green "请选择你接下来使用的X-ui面板版本"
    echo "1. 使用X-ui官方原版"
    echo "2. 使用FranzKafkaYu魔改版"
    echo "0. 返回主菜单"
    read -rp "请输入选项:" xuiNumberInput
    case "$xuiNumberInput" in
        1) bash <(curl -Ls https://ghraw.imgblz.cn/vaxilu/x-ui/master/install.sh) ;;
        2) bash <(curl -Ls https://ghraw.imgblz.cn/FranzKafkaYu/x-ui/master/install.sh) ;;
        0) menx ;;
        *) xui ;;
    esac
}

qlpanel(){
    [[ -z $(docker -v 2>/dev/null) ]] && curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    read -rp "请输入将要安装的青龙面板容器名称：" qlPanelName
    read -rp "请输入外网访问端口：" qlHTTPPort
    docker run -dit --name $qlPanelName --hostname $qlPanelName --restart always -p $qlHTTPPort:5700 -v $PWD/QL/config:/ql/config -v $PWD/QL/log:/ql/log -v $PWD/QL/db:/ql/db -v $PWD/QL/scripts:/ql/scripts -v $PWD/QL/jbot:/ql/jbot whyour/qinglong:latest
    wg-quick down wgcf 2>/dev/null
    v66=`curl -s6m8 https://ip.gs -k`
    v44=`curl -s4m8 https://ip.gs -k`
    yellow "青龙面板安装成功！！！"
    if [[ -n $v44 && -z $v66 ]]; then
        green "IPv4访问地址为：http://$v44:$qlHTTPPort"
    elif [[ -n $v66 && -z $v44 ]]; then
        green "IPv6访问地址为：http://[$v66]:$qlHTTPPort"
    elif [[ -n $v44 && -n $v66 ]]; then
        green "IPv4访问地址为：http://$v44:$qlHTTPPort"
        green "IPv6访问地址为：http://[$v66]:$qlHTTPPort"
    fi
    yellow "请稍等1-3分钟，等待青龙面板容器启动"
    wg-quick up wgcf 2>/dev/null
}

serverstatus() {
    wget -N https://ghraw.imgblz.cn/cokemine/ServerStatus-Hotaru/master/status.sh
    echo "                            "
    green "请选择你需要安装探针的客户端类型"
    echo "1. 服务端"
    echo "2. 监控端"
    echo "0. 返回主页"
    echo "                            "
	read -rp "请输入选项:" menuNumberInput1
    case "$menuNumberInput1" in
        1) bash status.sh s ;;
        2) bash status.sh c ;;
        0) menu ;;
        *) serverstatus ;;
    esac
}

menu() {
    clear
    echo "检查更新..."
    wget -q -O /tmp/version.txt https://ghraw.imgblz.cn/imgblz/MisakaToolbox/main/version.txt
    if [ "$(cat /tmp/version.txt)" != "$version" ]; then
        echo "发现新版本，请及时更新！"
        wget -q -O /tmp/tools_uplog.txt https://ghraw.imgblz.cn/imgblz/MisakaToolbox/main/log.txt
        menuu
    else
        echo "当前已经是最新版本 版本：$version"
        menuz
    fi
}

menuu(){
    clear
    echo "发现新版本，建议更新"
    echo ""
    echo -e "${YELLOW}当前版本${PLAIN}：$version"
    echo -e "${YELLOW}最新版本${PLAIN}：$(cat /tmp/version.txt)"
    echo "更新日志：$(cat /tmp/tools_uplog.txt)"
    echo ""
    read -rp "是否更新？[y/n]" menuNumberInput
    case "$menuNumberInput" in
        y) wget -N --no-check-certificate https://ghraw.imgblz.cn/imgblz/MisakaToolbox/main/MisakaToolbox.sh && bash MisakaToolbox.sh ;;
        n) menuz ;;
        *) menuu ;;
    esac
}

menuz(){
    check_status
    clear
    about
    echo ""
    echo -e "${YELLOW}当前版本${PLAIN}：$version"
    echo -e "${YELLOW}更新日志${PLAIN}：$version_log"
    echo ""
    if [[ -n $v4 ]]; then
        echo -e "IPv4 地址：$v4"  
        echo -e "地区：$c4  WARP状态：$w4"
    fi
    if [[ -n $v6 ]]; then
        echo -e "IPv6 地址：$v6 " 
        echo -e "地区：$c6  WARP状态：$w6"
    fi
    if [[ -n $w5p ]]; then
        echo -e "WireProxy代理端口: 127.0.0.1:$w5p  WireProxy状态: $w5"
        if [[ -n $w5i ]]; then
            echo -e "WireProxy IP: $w5i  地区: $w5c"
        fi
    fi
    echo ""
    read -rp "---按下enter运行脚本---" menuInput
    case $menuInput in
        *) menux ;;
    esac
}

menux(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 系统相关"
    echo -e " ${GREEN}2.${PLAIN} 面板相关"
    echo -e " ${GREEN}3.${PLAIN} 节点相关"
    echo -e " ${GREEN}4.${PLAIN} 性能测试"
    echo -e " ${GREEN}5.${PLAIN} 一键更换（dd）系统"
    echo -e " ${RED}9.${PLAIN} 回到欢迎页"
    echo -e " ${RED}10.${PLAIN} 关于"
    echo -e " ${RED}0.${PLAIN} 退出"
    echo ""
    echo -e "${YELLOW}版本号${PLAIN}：$version"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) menu1 ;;
        2) menu2 ;;
        3) menu3 ;;
        4) menu4 ;;
        5) menu5 ;;
        9) menuz ;;
        10) aboutx ;;
	    0) exit 1 ;;
        *) menux ;;
    esac
}

menu1(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 关闭系统防火墙端口"
    echo -e " ${GREEN}2.${PLAIN} BBR加速系列脚本"
    echo -e " ${GREEN}3.${PLAIN} 纯IPv6 VPS设置DNS64服务器"
    echo -e " ${GREEN}4.${PLAIN} 设置CloudFlare WARP"
    echo -e " ${GREEN}5.${PLAIN} 下载并安装Docker"
    echo -e " ${GREEN}6.${PLAIN} 修改Linux系统软件源"
    echo -e " ${GREEN}7.${PLAIN} 切换系统语言为中文"
    echo -e " ${GREEN}8.${PLAIN} 添加swap"
    echo -e " ${GREEN}9.${PLAIN} vpstoolbox（全自动化解放双手）"
    echo -e " ${GREEN}10.${PLAIN} vps改root登陆"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回主菜单"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) open_ports ;;
        2) bbr_script ;;
        3) v6_dns64 ;;
        4) warp_script ;;
        5) curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun ;;
        6) bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh) ;;
        7) setChinese ;;
    	8) wget https://www.moerats.com/usr/shell/swap.sh && bash swap.sh ;;
        9) tools ;;
        10) wget https://ghraw.imgblz.cn/imgblz/vpsroot/main/root.sh && bash root.sh ;;
        0) menux ;;
        *) menu1 ;;
    esac
}

menu2(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 服务器面板"
    echo -e " ${GREEN}2.${PLAIN} 下载（aria2）面板"
    echo -e " ${GREEN}3.${PLAIN} 青龙面板"
    echo -e " ${GREEN}4.${PLAIN} 节点面板"
    echo -e " ${GREEN}5.${PLAIN} 服务器探针"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回主菜单"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) menu2a ;;
        2) menu2b ;;
        3) menu2c ;;
        4) menu2d ;;
        5) menu2e ;;
        0) menux ;;
        *) menu2 ;;
    esac
}

menu2a(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} aapanel面板"
    echo -e " ${GREEN}2.${PLAIN} 宝塔快乐版"
    echo -e " ${GREEN}3.${PLAIN} CyberPanel面板"
    echo -e " ${GREEN}4.${PLAIN} AMH面板"
    echo -e " ${GREEN}5.${PLAIN} kangle彩虹版(CentOS6/7/8)"
    echo -e " ${GREEN}6.${PLAIN} mdserver(代替宝塔的新面板？)"
    echo -e " ${GREEN}7.${PLAIN} NewPanel（lnmp环境）"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回上一页"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) aapanel ;;
        2) bt ;;
        3) sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh) ;;
        4) wget http://dl.amh.sh/amh.sh && bash amh.sh ;;
        5) wget http://kangle.cccyun.cn/start;sh start ;;
        6) curl -fsSL  https://ghraw.imgblz.cn/midoks/mdserver-web/master/scripts/install.sh | bash ;;
        7) wget http://panel.ropon.top/panel/lnmp.tar.gz && tar xf lnmp.tar.gz && cd lnmp && ./install.sh ;;
        0) menu2 ;;
        *) menu2a ;;
    esac
}

menu2b(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} CCAA（Aria下载器）"
    echo -e " ${GREEN}2.${PLAIN} aria2(面板为远程链接)"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回上一页"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) bash <(curl -Lsk https://ghraw.imgblz.cn/helloxz/ccaa/master/ccaa.sh) ;;
        2) ${PACKAGE_INSTALL[int]} ca-certificates && wget -N git.io/aria2.sh && chmod +x aria2.sh && bash aria2.sh ;;
        0) menu2 ;;
        *) menu2b ;;
    esac
}

menu2c(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 官方版"
    echo -e " ${GREEN}2.${PLAIN} 傻瓜式一键带仓库"
    echo -e " ${GREEN}3.${PLAIN} 青龙面板一键依赖（需要默认容器名）"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回上一页"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) qlpanel ;;
        2) wget https://ghraw.imgblz.cn/shidahuilang/QL-/main/lang1.sh && bash lang1.sh ;;
        3) docker exec -it qinglong bash -c "$(curl -fsSL https://ghraw.imgblz.cn/FlechazoPh/QLDependency/main/Shell/QLOneKeyDependency.sh | sh)" ;;
        0) menu2 ;;
        *) menu2c ;;
    esac
}

menu2d(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} Trojan面板"
    echo -e " ${GREEN}2.${PLAIN} x-ui面板"
    echo -e " ${GREEN}3.${PLAIN} 青龙面板"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回上一页"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) source <(curl -sL https://git.io/trojan-install) ;;
        2) xui ;;
        0) menu2 ;;
        *) menu2d ;;
    esac
}



menu2e(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 哪吒面板（探针）"
    echo -e " ${GREEN}2.${PLAIN} ServerStatus-Hotaru"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回上一页"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) curl -L https://ghraw.imgblz.cn/naiba/nezha/master/script/install.sh -o nezha.sh && chmod +x nezha.sh && bash nezha.sh ;;
        2) serverstatus ;;
        0) menu2 ;;
        *) menu2e ;;
    esac
}

menu3(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} mack-a"
    echo -e " ${GREEN}2.${PLAIN} wulabing v2ray"
    echo -e " ${GREEN}3.${PLAIN} wulabing xray (Nginx前置)推荐"
    echo -e " ${GREEN}4.${PLAIN} wulabing xray (Xray前置)"
    echo -e " ${GREEN}5.${PLAIN} misaka xray"
    echo -e " ${GREEN}6.${PLAIN} teddysun shadowsocks"
    echo -e " ${GREEN}7.${PLAIN} telegram mtproxy"
    echo -e " ${GREEN}8.${PLAIN} WireGuard"
    echo -e " ${GREEN}9.${PLAIN} 订阅转换一键安装"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回主菜单"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) wget -P /root -N --no-check-certificate "https://ghraw.imgblz.cn/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh ;;
        2) wget -N --no-check-certificate -q -O install.sh "https://ghraw.imgblz.cn/wulabing/V2Ray_ws-tls_bash_onekey/master/install.sh" && chmod +x install.sh && bash install.sh ;;
        3) wget -N --no-check-certificate -q -O install.sh "https://ghraw.imgblz.cn/wulabing/Xray_onekey/nginx_forward/install.sh" && chmod +x install.sh && bash install.sh ;;
        4) wget -N --no-check-certificate -q -O install.sh "https://ghraw.imgblz.cn/wulabing/Xray_onekey/main/install.sh" && chmod +x install.sh && bash install.sh ;;
        5) wget -N --no-check-certificate https://ghraw.imgblz.cn/imgblz/Xray-script-master/master/xray.sh && bash xray.sh ;;
        6) wget --no-check-certificate -O shadowsocks-all.sh https://ghraw.imgblz.cn/teddysun/shadowsocks_install/master/shadowsocks-all.sh && chmod +x shadowsocks-all.sh && ./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log ;;
        7) mkdir /home/mtproxy && cd /home/mtproxy && curl -s -o mtproxy.sh https://ghraw.imgblz.cn/sunpma/mtp/master/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh && bash mtproxy.sh start ;;
        8) wget https://git.io/wireguard -O wireguard-install.sh && bash wireguard-install.sh ;;
        8) bash -c "$(curl -fsSL https://ghraw.imgblz.cn/shidahuilang/SS-SSR-TG-iptables-bt/main/sh/clash_install.sh)" ;;
        0) menux ;;
        *) menu3 ;;
    esac
}

menu4(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} VPS测试-bench.sh"
    echo -e " ${GREEN}2.${PLAIN} VPS测试-superbench"
    echo -e " ${GREEN}3.${PLAIN} VPS测试-lemonbench"
    echo -e " ${GREEN}4.${PLAIN} VPS测试-融合全测"
    echo -e " ${GREEN}5.${PLAIN} 流媒体检测"
    echo -e " ${GREEN}6.${PLAIN} 三网测速"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} 返回主菜单"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) wget -qO- bench.sh | bash ;;
        2) wget -qO- --no-check-certificate https://ghraw.imgblz.cn/oooldking/script/master/superbench.sh | bash ;;
        3) curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast ;;
        4) bash <(wget -qO- --no-check-certificate https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh) ;;
        5) bash <(curl -L -s https://ghraw.imgblz.cn/lmc999/RegionRestrictionCheck/main/check.sh) ;;
        6) bash <(curl -Lso- https://git.io/superspeed.sh) ;;
        0) menux ;;
        *) menu4 ;;
    esac
}

menu5(){
    clear
    about
    echo ""
    echo -e " ${GREEN}1.${PLAIN} 一键Debian（bohanyang）"
    echo -e " ${GREEN}2.${PLAIN} 一键dd脚本魔改版（cxthhhhh）"
    echo -e " ${GREEN}0.${PLAIN} 返回主菜单"
    echo ""
    read -rp " 请输入选项:" menuInput
    case $menuInput in
        1) dd_vps ;;
        2) wget --no-check-certificate -qO ~/Network-Reinstall-System-Modify.sh 'https://www.cxthhhhh.com/CXT-Library/Network-Reinstall-System-Modify/Network-Reinstall-System-Modify.sh' && chmod a+x ~/Network-Reinstall-System-Modify.sh && bash ~/Network-Reinstall-System-Modify.sh -UI_Options ;;
        0) menux ;;
        *) menu5 ;;
    esac
}

menu
