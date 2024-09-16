#!/bin/sh

set -e

OPENLDAP_DOCKER_NAME=openldap-server
OPENLDAP_DATA_DIR=$PWD/openldap

if [ "$ADMIN_PASSWD"x = ""x ]; then
    ADMIN_PASSWD=88888888
fi

case "$1" in
""|start)
    if docker ps -a | grep $OPENLDAP_DOCKER_NAME; then
        echo "$OPENLDAP_DOCKER_NAME already running !"
        exit 0
    fi
    mkdir -p $OPENLDAP_DATA_DIR/lib $OPENLDAP_DATA_DIR/slapd.d
    docker run -d --rm --name=$OPENLDAP_DOCKER_NAME -p 389:389 -p 636:636 \
        -e LDAP_ORGANISATION="apcial" \
        -e LDAP_DOMAIN="apical.com.cn" \
        -e LDAP_ADMIN_PASSWORD="$ADMIN_PASSWD" \
        -v $OPENLDAP_DATA_DIR/lib:/var/lib/ldap \
        -v $OPENLDAP_DATA_DIR/slapd.d:/etc/ldap/slapd.d \
        osixia/openldap:1.5.0
    ;;
stop)
    docker stop $OPENLDAP_DOCKER_NAME
    docker rm   $OPENLDAP_DOCKER_NAME 2> /dev/null || true
    ;;
esac

#
# 创建 ldap 用户
#
# 运行 LdapAdmin.exe，配置 ldap 服务器连接：
# New connection -> Connection name: apical.com.cn -> Host: 输入 IP -> Base (click Fetch DNs)
# -> Account: username（输入 cn=admin,dc=apical,dc=com,dc=cn）, password（输入 password） -> OK
# （apical.com.cn 必须跟 LDAP_DOMAIN 保持一致，如果没有域名 Host 用服务器的内网 IP 即可，
#   登录账号用管理员账号，即 cn=admin，密码使用 LDAP_ADMIN_PASSWORD）
#
# 登录到 ldap 服务器后，创建 名为 users 的 Organizational unit：
# on dc=example,dc=com 鼠标右键菜单 -> New -> Organizational unit -> Name: users -> OK
#
# 在 users 下创建用户并设置密码（以 chenk 为例）：
# ou=users 鼠标右键菜单 -> New -> User -> OK
# uid=chenk 鼠标右键菜单 -> Set Password -> OK
#
