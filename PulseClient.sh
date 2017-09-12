#!/bin/bash
HOMEDIR=$HOME
INSTALLDIR=/usr/local/pulse
PULSEDIR=$HOME/.pulse_secure/pulse
SVCNAME=pulsesvc
LOG=$PULSEDIR/PulseClient.log
args=""
ive_ip=""
NOARGS=$#
SCRARGS=$@


WEBKITGTK_1_SUPPORTED_VERSION=6
WEBKITGTK_3_SUPPORTED_VERSION=7

PACKAGE_TYPE_RPM=1
PACKAGE_TYPE_DEB=2
SCRNAME=`basename $0`

SUPPORTED_OSTYPES_LIST=( ARCH CENTOS_6 CENTOS_7 UBUNTU_14 UBUNTU_15 UBUNTU_16 FEDORA RHEL_7 UNSUPPORTED)
#Arch
ARCH_DEPENDENCIES=( glibc \
                    nss \
                    glib-networking \
                    libproxy \
                    libxmu \
                    lib32-zlib \
                    lib32-libstdc++5)

#RPM Based
CENTOS_6_DEPENDENCIES=( glibc \
                        nss-softokn-freebl \
                        zlib \
                        glib-networking \
                        webkitgtk \
                        xulrunner\
                        libproxy \
                        libXmu  \
                        libproxy-gnome \
                        libproxy-mozjs)
CENTOS_6_DEPENDENCIES_WITH_VERSION=( glibc.i686 \
                                     nss.i686  \
                                    zlib.i686 \
                                    glib-networking.i686 \
                                    webkitgtk.i686 \
                                    xulrunner.i686 \
                                    libproxy.i686 \ 
                                    libXmu.i686  \
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

install_arch() {
    i=$1
    sudo -v > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then 
        echo "sudo password : "
        sudo pacman -S $i 
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " sudo pacman -S $i"
        fi
    else 
        echo "super user password : "
        su -c " pacman -S $i"
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " pacman -S $i"
        fi
    fi

}

install_deb() {
    i=$1
    sudo -v > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then 
        echo "sudo password : "
        sudo apt-get install $i 
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " apt-get install $i"
        fi
    else 
        echo "super user password : "
        su -c "apt-get install $i"
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " apt-get install $i"
        fi
    fi

}

install_rpm_dnf() {
    i=$1
    sudo -v > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then 
        echo "sudo password "
        sudo dnf -y install $i
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " dnf install $i"
        fi
    else 
        echo "super user password "
        su -c "dnf -y install $i"
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " dnf install $i"
        fi
    fi 
}

install_rpm() {
    i=$1
    sudo -v > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then 
        echo "sudo password "
        sudo yum -y install $i
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " yum install $i"
        fi
    else 
        echo "super user password "
        su -c "yum -y install $i"
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " yum install $i"
        fi
    fi 
}

install_from_repo() {
    url=$1
    sudo -v > /dev/null 2>/dev/null
    if [ $? -eq 0 ]; then 
        echo "sudo password "
        sudo rpm -Uvh $url
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo "rpm -Uvh $url"
        fi
    else 
        echo "super user password "
        su -c " rpm -Uvh $url"
        if [ $? -ne 0 ]; then
            echo "Failed to install dependencies.Please execute following command manually."
            echo " rpm -Uvh $url"
        fi
    fi 
}
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
    elif [ -f /etc/arch-release ]; then
        OS_TYPE=${SUPPORTED_OSTYPES_LIST[$ARCH]}
        OS_MAJOR_VERSION=0
        INSTALLDIR=/opt/pulse
    else 
        OS_MAJOR_VERSION=6 #Every other flavour uses webkitgtk-1.0
        OSNAME=$(lsb_release -d | grep -o "Ubuntu")
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

ubuntu14_install_webkit(){
    sudo apt-get update
    sudo apt-get download libenchant1c2a:i386

    DEBFILE=libenchant1c2a_1.6.0-10ubuntu1_i386.deb
    TMPDIR=`mktemp -d /tmp/deb.XXXXXXXXXX` || exit 1
    OUTPUT=`basename "$DEBFILE" .deb`.modfied.deb

    if [[ -e "$OUTPUT" ]]; then
        echo "$OUTPUT exists."
        rm -r "$TMPDIR"
        return
    fi

    dpkg-deb -x "$DEBFILE" "$TMPDIR"
    dpkg-deb --control "$DEBFILE" "$TMPDIR"/DEBIAN

    if [[ ! -e "$TMPDIR"/DEBIAN/control ]]; then
        echo DEBIAN/control not found.
        rm -r "$TMPDIR"
        return
    fi

    CONTROL="$TMPDIR"/DEBIAN/control

    MOD=`stat -c "%y" "$CONTROL"`
    sed -i '/^Depends: /d' "$CONTROL"
    if [[ "$MOD" == `stat -c "%y" "$CONTROL"` ]]; then
        echo Not modfied.
    else
        echo Building new deb...
        dpkg -b "$TMPDIR" "$OUTPUT"
    fi

    rm -r "$TMPDIR"

    sudo dpkg -i $OUTPUT

    sudo apt-get install libwebkitgtk-1.0-0:i386

    sudo rm -f libenchant1c2a_1.6.0-10ubuntu1_i386* 
}

check_and_install_missing_dependencies() {
    echo "Checking for missing dependency packages ..."
    if [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]} ]; then
        return 
    fi
    isArchBased=0
    isRpmBased=0
    isDebBased=0
    dependencyListName=${OS_TYPE}_DEPENDENCIES
    dependencyListNameWithVersion=${OS_TYPE}_DEPENDENCIES_WITH_VERSION
    if [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_7]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$FEDORA]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$RHEL_7]}) ]]; then
        isRpmBased=1
    elif [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_14]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_15]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_16]}) ]]; then
        isDebBased=1
    elif [[ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$ARCH]} ]]; then
        isArchBased=1
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
                echo "$depPkgName is missing in the machine"
                PKGREQ="$PKGREQ ${depListArrWithVersion[i]}"
            fi 
        done
        if [ "X" != "X$PKGREQ" ]; then
            # Install respective packages based on the current installation
            for i in `echo $PKGREQ`
            do
                if [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]} ]; then 
                    if [ $i = 'libproxy-mozjs.i686' ]; then
                        url='http://centos.mirror.net.in/centos/6/os/i386/Packages/libproxy-mozjs-0.3.0-10.el6.i686.rpm'
                        install_from_repo $url 
                    elif [ $i = 'glib-networking.i686' ]; then
                        url='http://centos.mirror.net.in/centos/6/os/i386/Packages/glib-networking-2.28.6.1-2.2.el6.i686.rpm'
                        install_from_repo $url 
                    elif [ $i = 'libproxy-gnome.i686' ]; then
                        url='http://centos.mirror.net.in/centos/6/os/i386/Packages/libproxy-gnome-0.3.0-10.el6.i686.rpm'
                        install_from_repo $url
                    else
                        install_rpm $i 
                    fi
                elif [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$FEDORA]} ]; then 
                    if [ $i = 'libproxy-mozjs.i686' ]; then
                        url='http://dl.fedoraproject.org/pub/fedora/linux/releases/23/Everything/i386/os/Packages/l/libproxy-mozjs-0.4.11-12.fc23.i686.rpm'
                        install_from_repo $url
                    elif [ $i = 'mozjs17.i686' ]; then
                        url='ftp://ftp.ntua.gr/pub/linux/fedora/linux/releases/23/Everything/i386/os/Packages/m/mozjs17-17.0.0-12.fc23.i686.rpm'
                        install_from_repo $url
                    elif [ $i = 'libproxy-gnome.i686' ]; then
                        url='ftp://fr2.rpmfind.net/linux/fedora/linux/releases/23/Everything/i386/os/Packages/l/libproxy-gnome-0.4.11-12.fc23.i686.rpm'
                        install_from_repo $url
                    else
                        install_rpm_dnf $i 
                    fi
                else
                    install_rpm $i 
                fi
            done
        fi
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
            for i in `echo $PKGREQ`
            do
                if [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_14]}) && \
                      ($i = 'libwebkitgtk-1.0-0:i386') ]]; then
                    ubuntu14_install_webkit
                else 
                    install_deb $i
                fi
            done
        fi 
        echo ""
    elif [ $isArchBased = 1 ]; then
        eval "depListArr=(\${${dependencyListName}[@]})"
        # eval "depListArrWithVersion=(\${${dependencyListNameWithVersion}[@]})"
        tam=${#depListArr[@]}
        PKGREQ=""
        for ((i=0; i < $tam; i++)); do
            depPkgName=${depListArr[i]}
            curPkgVar=`pacman -Q | grep -i $depPkgName`
            if [ "X$curPkgVar" = "X" ]; then
                echo "$depPkgName is missing in the machine" > $LOG
                PKGREQ="$PKGREQ ${depListArr[i]}"
            fi 
        done
        if [ "X" != "X$PKGREQ" ]; then
            # Install respective packages based on the current installation
            echo ""
            echo "Please execute below commands to install missing dependent packages "
            for i in `echo $PKGREQ`
            do
                echo "pacman -S $i"
            done
        fi
        echo $readMeEchoMsg
    fi
}
######################################################################################################
# Function to verify if dependencies are installed
# Args   : None
# Return : None
#function check_dep () 
#{

function command_line_client_checks()
{
    echo "Checking for missing dependency packages for command line client ..."
    if [ $OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UNSUPPORTED]} ]; then
        return 
    fi
    ARCH_DIST=0
    RPM_DIST=0
    DPKG_DIST=0

    if [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_6]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$CENTOS_7]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$FEDORA]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$RHEL_7]}) ]]; then
        RPM_DIST=1
    elif [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_14]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_15]}) || \
        ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$UBUNTU_16]}) ]]; then
        DPKG_DIST=1
    elif [[ ($OS_TYPE = ${SUPPORTED_OSTYPES_LIST[$ARCH]}) ]]; then
        ARCH_DIST=1
    fi

    if [ $RPM_DIST -eq 1 ]; then 
        PKGREQ=""
        glibc=`rpm -qa | grep -i glibc | grep -i "i686\|i386"`
        if [ "X$glibc" = "X" ]; then
            echo "glibc is missing in the machine" > $LOG
            PKGREQ="glibc.i686"
        fi  
        nss=`rpm -qa | grep -i nss-softokn-freebl | grep -i "i386\|i686"`
        if [ "X$nss" = "X" ]; then 
            echo "nss is missing in the machine" > $LOG
            PKGREQ="$PKGREQ nss.i686"
        fi  
        zlib=`rpm -qa | grep -i zlib | grep -i "i386\|i686"`
        if [ "X$zlib" = "X" ]; then 
            echo "zlib is missing in the machine" > $LOG
            PKGREQ="$PKGREQ zlib.i686"
        fi
        if [ "X" != "X$PKGREQ" ]; then
            sudo -v > /dev/null 2>/dev/null
            if [ $? -eq 0 ]; then 
                echo "sudo password "
                sudo yum -y install $PKGREQ
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " yum install $PKGREQ"
                fi
            else 
                echo "super user password "
                su -c "yum -y install $PKGREQ"
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " yum install $PKGREQ"
                fi
            fi 
        fi
    elif [ $DPKG_DIST -eq 1 ]; then 
        PKGREQ=""
        libc=`dpkg-query -f '${binary:Package}\n' -W | grep -i libc6-i386`
        if [ "X$libc" = "X" ]; then 
            PKGREQ="libc6-i386"
        fi  
        zlib=`dpkg-query -f '${binary:Package}\n' -W | grep -i lib32z1`
        if [ "X$zlib" = "X" ]; then 
            PKGREQ="$PKGREQ lib32z1"
        fi
        if [ "X" != "X$PKGREQ" ]; then
            sudo -v > /dev/null 2>/dev/null
            if [ $? -eq 0 ]; then 
                echo "sudo password : "
                sudo apt-get install $PKGREQ 
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " apt-get install $PKGREQ"
                fi
            else 
                echo "super user password : "
                su -c "apt-get install $PKGREQ"
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " apt-get install $PKGREQ"
                fi
            fi
        fi
    elif [ $ARCH_DIST -eq 1 ]; then 
        PKGREQ=""
        glibc=`pacman -Q | grep -i glibc`
        if [ "X$glibc" = "X" ]; then
            echo "glibc is missing in the machine" > $LOG
            PKGREQ="glibc"
        fi  
        nss=`pacman -Q | grep -i nss`
        if [ "X$nss" = "X" ]; then 
            echo "nss is missing in the machine" > $LOG
            PKGREQ="$PKGREQ nss"
        fi  
        zlib=`pacman -Q | grep -i lib32-zlib`
        if [ "X$zlib" = "X" ]; then 
            echo "lib32-zlib is missing in the machine" > $LOG
            PKGREQ="$PKGREQ lib32-zlib"
        fi
        stdc=`pacman -Q | grep -i lib32-libstdc++5`
        if [ "X$stdc" = "X" ]; then 
            echo "lib32-libstdc++ is missing in the machine" > $LOG
            PKGREQ="$PKGREQ lib32-libstdc++5"
        fi
        if [ "X" != "X$PKGREQ" ]; then
            sudo -v > /dev/null 2>/dev/null
            if [ $? -eq 0 ]; then 
                echo "sudo password "
                sudo pacman -S $PKGREQ
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " pacman -S $PKGREQ"
                fi
            else 
                echo "super user password "
                su -c "pacman -S $PKGREQ"
                if [ $? -ne 0 ]; then
                    echo "Failed to install dependencies.Please execute following command manually."
                    echo " pacman -S $PKGREQ"
                fi
            fi 
        fi
    fi 
    
    if [ ! -e $INSTALLDIR ]; then 
        echo "Pulse is not installed. Please check if Pulse is installed properly"
        exit 1
    fi 
# create $HOME/.pulse_secure/pulse/ directory 
    if [ ! -d $PULSEDIR ]; then 
        mkdir -p $PULSEDIR
        if [ $? -ne 0 ]; then 
            echo "Setup is not able to create $PULSEDIR. Please check the permission"
            exit 2
        fi 
    fi

    if [ $NOARGS -eq 0 ]; then 
        $INSTALLDIR/$SVCNAME -C -H
	    exit 0
    fi
    # LD_LIBRARY_PATH is updated to use /usr/local/pulse/libsoup-2.4.so in CentOS6.4
    # This library will be present only in the case of CentOS6.4 but setting 
    # LD_LIBRARY_PATH for other platforms will not be harmful. 
    export LD_LIBRARY_PATH=$INSTALLDIR:$LD_LIBRARY_PATH

    echo "executing command : $INSTALLDIR/$SVCNAME $args" 
    # -C option added to indicate service is launched from command line - hidden option
    #args="-C $args"
    # pass the args to pulsesvc binary 
    $INSTALLDIR/$SVCNAME -C $SCRARGS
}

if [ "X$1" = "Xinstall_dependency_packages" ] ; then
    determine_os_type
    check_and_install_missing_dependencies
else
    determine_os_type
    command_line_client_checks
fi
