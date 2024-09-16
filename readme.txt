http ports:
8000 - pgadmin
8001 - wikijs
8002 - gerrit
8003 - Jenkins
8005 - ldappasswd
8006 - SonarQube

1. gerrit 创建 jenkins 用户，并将该账号添加到 Non-Interactive Users 组
2. 对 jenkins 用户开放 Label Code-Review -1 +1 和 Label Verified -1 +1 权限
3. jenkins 上安装 gerrit trigger 插件，系统管理 -> 未分类 -> Gerrit Trigger 中增加 Gerrit Servers
4. jenkins 用户要创建 ssh key. 私钥加到 jenkins，公钥加到 gerrit.
5. jenkins 新建构建项目，构建触发器增加 Gerrit event，注意 project 和 branch 要匹配

注意事项：
1. jenkins 中编译脚本要以：#!/bin/bash 打头（解决 source 找不到的问题）


chenk@apical.com.cn
2024-09-16
