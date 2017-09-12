#!/bin/bash
INSTALLDIR=/usr/local/pulse
LOG=$INSTALLDIR/postinstall.log
# Redirect the stdout/stderr into postinstall log
echo "Starting Post Install Script " > $LOG
# no-same-owner is required to get root permission
WEBKITGTK_1_SUPPORTED_VERSION=6
WEBKITGTK_3_SUPPORTED_VERSION=7

PACKAGE_TYPE_RPM=1
PACKAGE_TYPE_DEB=2
SCRNAME=`basename $0`
readMeEchoMsg="Please refer /usr/local/pulse/README for instructions to launch the Pulse Client"


SUPPORTED_OSTYPES_LIST=( CENTOS_6 CENTOS_7 UBUNTU_14 UBUNTU_15 UBUNTU_16 FEDORA RHEL_7 UNSUPPORTED)
#RPM Based
CENTOS_6_DEPENDENCIES=( glibc \
                        nss-softokn-freebl \
                        zlib \
                        glib-networking \
                        webkitgtk \
                        xulrunner\
                        libproxy \
                        libXmu \
                        libproxy-gnome \
                        libproxy-mozjs)
CENTOS_6_DEPENDENCIES_WITH_VERSION=( glibc.i686 \
                                     nss.i686  \
                                    zlib.i686 \
                                    glib-networking.i686 \
                                    webkitgtk.i686 \
                                    xulrunner.i686 \
                                    libproxy.i686 \ 
                                    libXmu.i686 \
                                    libproxy-gnome.i686 \
                                    libproxy-mozjs.i686)

FEDORA_DEPENDENCIES=( glibc \
                        nss-softokn-freebl \
                        zlib \
                        glib-networking \
                        webkitgtk \
                        xulrunner \
                        libproxy \
                        mozjs17 \
                        libproxy-mozjs \
                        libproxy-gnome)
FEDORA_DEPENDENCIES_WITH_VERSION=( glibc.i686 \
                                     nss.i686  \
                                    zlib.i686 \
                                    glib-networking.i686 \
                                    webkitgtk.i686 \
                                    xulrunner.i686 \
                                    libproxy.i686 \
                                    mozjs17.i686 \
                                    libproxy-mozjs.i686 \ 
                                    libproxy-gnome.i686)

CENTOS_7_DEPENDENCIES=( glibc \
                    nss-softokn-freebl \
                    zlib \
                    glib-networking \
                    webkitgtk3 \
                    libproxy-gnome \
                    libproxy-mozjs \
                    libproxy )
CENTOS_7_DEPENDENCIES_WITH_VERSION=( glibc.i686 \
                                nss.i686 \
                                zlib.i686 \
                                glib-networking.i686 \
                                webkitgtk3.i686 \
                                libproxy-gnome.i686 \
                                libproxy-mozjs.i686 \
                                libproxy.i686 )

RHEL_7_DEPENDENCIES=( glibc \
                    nss-softokn-freebl \
                    zlib \
                    glib-networking \
                    webkitgtk3 \
                    libproxy )
RHEL_7_DEPENDENCIES_WITH_VERSION=( glibc.i686 \
                                nss.i686 \
                                zlib.i686 \
                                glib-networking.i686 \
                                webkitgtk3-2.4.9-5.el7.i686 \
                                libproxy.i686 )

#Debian Based
UBUNTU_14_DEPENDENCIES=( lib32z1 \
                    libc6-i386 \
                    webkitgtk \
                    libproxy1 \
                    libproxy1-plugin-gsettings \
                    libproxy1-plugin-webkit \
                    libdconf1 \
                    dconf-gsettings-backend)
UBUNTU_14_DEPENDENCIES_WITH_VERSION=( lib32z1 \
                                libc6-i386 \
                                libwebkitgtk-1.0-0:i386 \
                                libproxy1:i386 \
                                libproxy1-plugin-gsettings:i386 \
                                libproxy1-plugin-webkit:i386 \
                                libdconf1:i386 \
                                dconf-gsettings-backend:i386)

UBUNTU_15_DEPENDENCIES=( lib32z1 \
                    libc6-i386 \
                    webkitgtk \
                    libproxy1 \
                    libproxy1-plugin-gsettings \
                    libproxy1-plugin-webkit \
                    libdconf1 \
                    dconf-gsettings-backend)
UBUNTU_15_DEPENDENCIES_WITH_VERSION=( lib32z1 \
                                libc6-i386 \
                                libwebkitgtk-1.0-0:i386 \
                                libproxy1:i386 \
                                libproxy1-plugin-gsettings:i386 \
                                libproxy1-plugin-webkit:i386 \
                                libdconf1:i386 \
                                dconf-gsettings-backend:i386)
UBUNTU_16_DEPENDENCIES=( lib32z1 \
                    libc6-i386 \
                    webkitgtk \
                    libproxy1 \
                    libproxy1-plugin-gsettings \
                    libproxy1-plugin-webkit \
                    libdconf1 \
                    dconf-gsettings-backend)
UBUNTU_16_DEPENDENCIES_WITH_VERSION=( lib32z1 \
                                libc6-i386 \
                                libwebkitgtk-1.0-0:i386 \
                                libproxy1:i386 \
                                libproxy1-plugin-gsettings:i386 \
                                libproxy1-plugin-webkit:i386 \
                                libdconf1:i386 \
                                dconf-gsettings-backend:i386)

tam=${#SUPPORTED_OSTYPES_LIST[@]}
for ((i=0; i < $tam; i++)); do
    name=${SUPPORTED_OSTYPES_LIST[i]}
    declare -r ${name}=$i
done


#determine the OS TYPE
determine_os_type() {
    if [ -f /etc/centos-release ]; then
        OS_MAJOR_VERSION=$(cat /etc/centos-release | grep -o '.[0-9]'| head -1|sed -e 's/ //')
        if [ $OS_MAJOR_VERSION = $WEBKITGTK_1_SUPPORTED_VERSION ]; then
            OS_TYPE=${SUPPORTED_OSTYPES_LIST[$CENTOS_6]} 
        elif [ $OS_MAJOR_VERSION = $WEBKITGTK_3_SUPPORTED_VERSION ]; then 
            OS_TYPE=${SUPPORTED_OSTYPES_LIST[$CENTOS_7]} 
        else
            OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]}
        fi
    elif [ -f /etc/fedora-release ]; then 
        OS_MAJOR_VERSION=6 #Fedora uses webkitgtk-1.0
        OS_TYPE=${SUPPORTED_OSTYPES_LIST[$FEDORA]}
    elif [ -f /etc/redhat-release ]; then
        OS_MAJOR_VERSION=$(cat /etc/redhat-release | grep -o '.[0-9]'| head -1|sed -e 's/ //')
        if [ $OS_MAJOR_VERSION = $WEBKITGTK_3_SUPPORTED_VERSION ]; then
            OS_TYPE=${SUPPORTED_OSTYPES_LIST[$RHEL_7]} 
        else
            OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]}
        fi
    else 
        OS_MAJOR_VERSION=6 #Every other flavour uses webkitgtk-1.0
        OSNAME=$(lsb_release -d |grep -o "Ubuntu")
        if [ "X$OSNAME" != "X" ]; then
            UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')
            if [ $UBUNTU_VER = 14 ]; then
                OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UBUNTU_14]}
            elif [ $UBUNTU_VER = 15 ]; then
                OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UBUNTU_15]}
            elif [ $UBUNTU_VER = 16 ]; then
                OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UBUNTU_16]}
            else 
                OS_TYPE=${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]}	
            fi
        fi
    fi
}

install_binaries() {
    if [ $OS_MAJOR_VERSION = $WEBKITGTK_3_SUPPORTED_VERSION ] ; then
        mv $INSTALLDIR/pulseUi_centos_7 $INSTALLDIR/pulseUi
        mv $INSTALLDIR/libpulseui.so_centos_7 $INSTALLDIR/libpulseui.so
    else
        mv $INSTALLDIR/pulseUi_centos_6 $INSTALLDIR/pulseUi
        mv $INSTALLDIR/libpulseui.so_centos_6 $INSTALLDIR/libpulseui.so
    fi
}


handle_common_installation() {
    tar --no-same-owner -xzf /usr/local/pulse/pulse.tgz -C /usr/local/pulse >/dev/null
    chmod +rws /usr/local/pulse/pulsesvc
    mv /usr/local/pulse/pulseUi.desktop /usr/share/applications
	# only for rpm based platforms. check for script name to check if current package is rpm
	if [ "X$SCRNAME" = "XConfigurePulse.sh" ]; then
		if [ $OS_TYPE != ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]} ]; then
			rm /usr/local/pulse/libsoup-2.4.so.1
		fi 
	fi
}

handle_uninstallation() {
    if [ "X$SCRNAME" = "XConfigurePulse.sh" ]; then 
        PKG=$PACKAGE_TYPE_RPM
    else
        PKG=$PACKAGE_TYPE_DEB
        UNINSTALL=`echo $SCRNAME | grep -i prerm`
        if [ "X$UNINSTALL" != "X" ]; then 
            killall pulseUi 2&>/dev/null
            killall pulsesvc 2&>/dev/null
            rm -rf /usr/local/pulse/* 
            rmdir /usr/local/pulse
            rm -f /usr/share/applications/pulseUi.desktop
            read -p "Do you want to clean up the connection store? [Yy/Nn] " -n 1 -r
            echo    # (optional) move to a new line
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                rm -f $HOME/.pulse_secure/pulse/.pulse_Connections.txt
            fi
            exit 
        fi 
        chown $USER: /usr/local/pulse/PulseClient.sh
        chown $USER: /usr/local/pulse/version.txt
        chown $USER: /usr/local/pulse/pulse.tgz
    fi
}

check_missing_dependencies() {
    if [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]} ]; then
        return 
    fi
    isRpmBased=0
    isDebBased=0
    dependencyListName=${OS_TYPE}_DEPENDENCIES
    dependencyListNameWithVersion=${OS_TYPE}_DEPENDENCIES_WITH_VERSION
    if [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_7]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$FEDORA]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$RHEL_7]})]]; then
        isRpmBased=1
    elif [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_14]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_15]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_16]})]]; then
        isDebBased=1
    fi
 
    if [ $isRpmBased = 1 ]; then
        eval "depListArr=(\${${dependencyListName}[@]})"
        eval "depListArrWithVersion=(\${${dependencyListNameWithVersion}[@]})"
        tam=${#depListArr[@]}
        PKGREQ=""
        for ((i=0; i < $tam; i++)); do
            depPkgName=${depListArr[i]}
            curPkgVar=`rpm -qa | grep -i $depPkgName | grep -i "i686\|i386"`
            if [ "X$curPkgVar" = "X" ]; then
                echo "$depPkgName is missing in the machine" > $LOG
                PKGREQ="$PKGREQ ${depListArrWithVersion[i]}"
            fi 
        done
        if [ "X" != "X$PKGREQ" ]; then
            # Install respective packages based on the current installation
            echo ""
            echo "Please execute below commands to install missing dependent packages "
            for i in `echo $PKGREQ`
            do
                if [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]} ]; then 
                    if [ $i = 'libproxy-mozjs.i686' ]; then
                        echo "rpm -Uvh http://mirror.centos.org/centos/6/os/i386/Packages/libproxy-mozjs-0.3.0-10.el6.i686.rpm"
                    elif [ $i = 'glib-networking' ]; then
                        echo "rpm -Uvh http://centos.mirror.net.in/centos/6/os/i386/Packages/glib-networking-2.28.6.1-2.2.el6.i686.rpm"
                    elif [ $i = 'libproxy-gnome.i686' ]; then
                        echo "rpm -Uvh http://mirror.centos.org/centos/6/os/i386/Packages/libproxy-gnome-0.3.0-10.el6.i686.rpm"
                    else
                        echo "yum install $i"
                    fi
                elif [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$FEDORA]} ]; then 
                    if [ $i = 'libproxy-mozjs.i686' ]; then
                        echo "rpm -Uvh http://dl.fedoraproject.org/pub/fedora/linux/releases/23/Everything/i386/os/Packages/l/libproxy-mozjs-0.4.11-12.fc23.i686.rpm"
                    elif [ $i = 'mozjs17.i686' ]; then
                        echo "rpm -Uvh ftp://ftp.ntua.gr/pub/linux/fedora/linux/releases/23/Everything/i386/os/Packages/m/mozjs17-17.0.0-12.fc23.i686.rpm"
                    elif [ $i = 'libproxy-gnome.i686' ]; then
                        echo "rpm -Uvh ftp://fr2.rpmfind.net/linux/fedora/linux/releases/23/Everything/i386/os/Packages/l/libproxy-gnome-0.4.11-12.fc23.i686.rpm"
                    else
                        echo "dnf install $i"
                    fi
                else 
                    echo "yum install $i"
                fi
            done

            echo ""
            echo "OR" 
            echo "You can install the missing dependency packages by running the below script "
            echo "  /usr/local/pulse/PulseClient.sh install_dependency_packages"
            echo ""
        fi
        echo $readMeEchoMsg
    elif [ $isDebBased = 1 ]; then
        eval "depListArr=(\${${dependencyListName}[@]})"
        eval "depListArrWithVersion=(\${${dependencyListNameWithVersion}[@]})"
        tam=${#depListArr[@]}
        PKGREQ=""
        for ((i=0; i < $tam; i++)); do
            depPkgName=${depListArr[i]}
            if [ $depPkgName = lib32z1 ]; then
                curPkgVar=`dpkg-query -f '${binary:Package}\n' -W | grep -i $depPkgName`
            else 
                curPkgVar=`dpkg-query -f '${binary:Package}\n' -W | grep -i $depPkgName | grep -i "i386\|i686"`
            fi
            if [ "X$curPkgVar" = "X" ]; then 
                PKGREQ="$PKGREQ ${depListArrWithVersion[i]}"
            fi
        done
        if [ "X$PKGREQ" != "X" ]; then
            echo "Please execute below commands to install missing dependent packages manually"
            for i in `echo $PKGREQ`
            do 
                echo "apt-get install $i"
            done

            echo ""
            echo "OR" 
            echo "You can install the missing dependency packages by running the below script "
            echo "  /usr/local/pulse/PulseClient.sh install_dependency_packages"
            echo ""
        fi 
        echo $readMeEchoMsg
        echo ""
    fi
}

#Main
determine_os_type
handle_common_installation
install_binaries
handle_uninstallation
check_missing_dependencies
