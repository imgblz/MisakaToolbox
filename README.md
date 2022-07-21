# 御坂妹妹们的Linux VPS工具箱 复活版

## 使用方法
1. 用SSH客户端连接上VPS，输入以下命令（若不是root用户请先`sudo -i`提权）
```shell
wget -N --no-check-certificate https://raw.githubusercontent.com/imgblz/MisakaToolbox/main/MisakaToolbox.sh && bash MisakaToolbox.sh
```

第一次运行以后，可用快捷方式 `bash MisakaToolbox.sh`启动

## 计划

20220721计划重构脚本

## 更新日志

Ver v3.9(20220721) 改下逻辑，删了点没用的

<details>
    <summary>历史更新记录（点击展开）</summary>
    
Ver 3.8（20220718-2） 优化脚本大小
    
Ver 3.7（20220718） 添加CCAA脚本
    
Ver 3.6（20220717） 添加wireguard和mdserver两个好用的项目,引入自动更新
    
Ver 3.5（20220715） 优化脚本，防止回到主菜单需要漫长的等待检查，防止输错序号导致强制退出脚本
    
Ver 3.4（20220714） 加了一堆东东
    
Ver 3.3（20220713） 增加swap脚本
  
Ver 3.2（20220707） 迁移仓库，删除部分脚本（变成杰哥的样纸），并由这个色皮头子继续misakatools的更新
  
</details>

## 感谢列表

感谢他们的贡献，让脚本得到进一步完善
<details>
    <summary>点击展开</summary>

感谢Misaka no的开发

BBR(KVM)：https://github.com/ylx2016/Linux-NetSpeed

BBR(OpenVZ)：https://github.com/mzz2017/lkl-haproxy/

WARP脚本：https://github.com/fscarmen/warp

宝塔国际版（aapanel）：https://www.aapanel.com/

X-ui: https://github.com/vaxilu/x-ui

Aria2: https://github.com/P3TERX/aria2.sh

CyberPanel：https://cyberpanel.net/

Mack-a：https://github.com/mack-a/v2ray-agent

233boy：https://github.com/233boy/v2ray/wiki/V2Ray%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85%E8%84%9A%E6%9C%AC

hijk：https://github.com/hijkpw/scripts

ShadowSocks: https://github.com/teddysun/shadowsocks_install/tree/master

bench.sh https://bench.sh

superbench https://github.com/oooldking/script

lemonbench https://blog.ilemonrain.com/linux/LemonBench.html

流媒体检测：https://github.com/lmc999/RegionRestrictionCheck

三网测速：https://github.com/ernisn/superspeed/

哪吒面板：https://github.com/naiba/nezha

可乐 ServerStartus-Horatu：https://github.com/cokemine/ServerStatus-Hotaru

DD系统：https://www.cxthhhhh.com/network-reinstall-system-modify

青龙面板：https://github.com/whyour/qinglong

更换系统语言：https://github.com/johnrosen1/vpstoolbox
</details>  


GNU General Public License v3.0  
