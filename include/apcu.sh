#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_APCU() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    case "${PHP_main_ver}" in
      5.3|5.4|5.5|5.6) apcu_selected_ver=${apcu_php53_56_ver} ;;
      7.*|8.*) apcu_selected_ver=${apcu_php70_up_ver} ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support apcu! ${CEND}"
        popd > /dev/null
        return 0
        ;;
    esac
    tar xzf apcu-${apcu_selected_ver}.tgz
    pushd apcu-${apcu_selected_ver} > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    if [ -f "${phpExtensionDir}/apcu.so" ]; then
      cat > ${php_install_dir}/etc/php.d/02-apcu.ini << EOF
[apcu]
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1
EOF
      /bin/cp apc.php ${wwwroot_dir}/default
      popd > /dev/null
      echo "${CSUCCESS}PHP apcu module installed successfully! ${CEND}"
      rm -rf apcu-${apcu_selected_ver} package.xml
    else
      echo "${CFAILURE}PHP apcu module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_APCU() {
  if [ -e "${php_install_dir}/etc/php.d/02-apcu.ini" ]; then
    rm -rf ${php_install_dir}/etc/php.d/02-apcu.ini ${wwwroot_dir}/default/apc.php
    echo; echo "${CMSG}PHP apcu module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP apcu module does not exist! ${CEND}"
  fi
}
