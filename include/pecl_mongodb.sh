#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_mongodb() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    case "${PHP_main_ver}" in
      5.3|5.4|5.5|5.6)
        mongodb_package=mongo
        mongodb_selected_ver=${pecl_mongo_php53_56_ver}
        ;;
      7.0) mongodb_package=mongodb; mongodb_selected_ver=${pecl_mongodb_php70_ver} ;;
      7.1) mongodb_package=mongodb; mongodb_selected_ver=${pecl_mongodb_php71_ver} ;;
      7.2|7.3) mongodb_package=mongodb; mongodb_selected_ver=${pecl_mongodb_php72_73_ver} ;;
      7.4|8.0) mongodb_package=mongodb; mongodb_selected_ver=${pecl_mongodb_php74_80_ver} ;;
      8.*) mongodb_package=mongodb; mongodb_selected_ver=${pecl_mongodb_php81_up_ver} ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support mongodb! ${CEND}"
        popd > /dev/null
        return 0
        ;;
    esac
    src_url=https://pecl.php.net/get/${mongodb_package}-${mongodb_selected_ver}.tgz && Download_src
    tar xzf ${mongodb_package}-${mongodb_selected_ver}.tgz
    pushd ${mongodb_package}-${mongodb_selected_ver} > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/${mongodb_package}.so" ]; then
      echo "extension=${mongodb_package}.so" > ${php_install_dir}/etc/php.d/07-${mongodb_package}.ini
      rm -rf ${mongodb_package}-${mongodb_selected_ver}
      echo "${CSUCCESS}PHP ${mongodb_package} module installed successfully! ${CEND}"
    else
      echo "${CFAILURE}PHP ${mongodb_package} module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_mongodb() {
  if [ -e "${php_install_dir}/etc/php.d/07-mongo.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/07-mongo.ini
    echo; echo "${CMSG}PHP mongo module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP mongo module does not exist! ${CEND}"
  fi
  if [ -e "${php_install_dir}/etc/php.d/07-mongodb.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/07-mongodb.ini
    echo; echo "${CMSG}PHP mongodb module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP mongodb module does not exist! ${CEND}"
  fi
}
