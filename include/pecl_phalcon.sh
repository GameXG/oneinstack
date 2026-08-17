#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_phalcon() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    case "${PHP_main_ver}" in
      5.5|5.6|7.0|7.1)
        phalcon_package=cphalcon
        phalcon_selected_ver=${cphalcon_php55_71_ver}
        ;;
      7.2|7.3)
        phalcon_package=phalcon
        phalcon_selected_ver=${phalcon_php72_73_ver}
        ;;
      7.4|8.0)
        phalcon_package=phalcon
        phalcon_selected_ver=${phalcon_php74_80_ver}
        ;;
      8.*)
        phalcon_package=phalcon
        phalcon_selected_ver=${phalcon_php81_up_ver}
        ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support phalcon! ${CEND}"
        popd > /dev/null
        return 0
        ;;
    esac
    if [ "${phalcon_package}" == 'phalcon' ]; then
      src_url=https://pecl.php.net/get/phalcon-${phalcon_selected_ver}.tgz && Download_src
      tar xzf phalcon-${phalcon_selected_ver}.tgz
      pushd phalcon-${phalcon_selected_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      echo "${CMSG}It may take a few minutes... ${CEND}"
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
    else
      src_url=${mirror_link}/oneinstack/src/cphalcon-${phalcon_selected_ver}.tar.gz && Download_src
      tar xzf cphalcon-${phalcon_selected_ver}.tar.gz
      pushd cphalcon-${phalcon_selected_ver}/build > /dev/null
      echo "${CMSG}It may take a few minutes... ${CEND}"
      ./install --phpize ${php_install_dir}/bin/phpize --php-config ${php_install_dir}/bin/php-config --arch 64bits
      popd > /dev/null
    fi
    if [ -f "${phpExtensionDir}/phalcon.so" ]; then
      echo 'extension=phalcon.so' > ${php_install_dir}/etc/php.d/04-phalcon.ini
      echo "${CSUCCESS}PHP phalcon module installed successfully! ${CEND}"
      rm -rf ${phalcon_package}-${phalcon_selected_ver}
    else
      echo "${CFAILURE}PHP phalcon module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_phalcon() {
  if [ -e "${php_install_dir}/etc/php.d/04-phalcon.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-phalcon.ini
    echo; echo "${CMSG}PHP phalcon module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP phalcon module does not exist! ${CEND}"
  fi
}
