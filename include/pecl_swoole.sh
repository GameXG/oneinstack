#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_swoole() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    case "${PHP_main_ver}" in
      5.3|5.4|5.5|5.6) swoole_selected_ver=${swoole_php53_56_ver} ;;
      7.0|7.1) swoole_selected_ver=${swoole_php70_71_ver} ;;
      7.2|7.3|7.4) swoole_selected_ver=${swoole_php72_74_ver} ;;
      8.0|8.1) swoole_selected_ver=${swoole_php80_81_ver} ;;
      8.*) swoole_selected_ver=${swoole_php82_up_ver} ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support swoole! ${CEND}"
        popd > /dev/null
        return 0
        ;;
    esac
    src_url=https://pecl.php.net/get/swoole-${swoole_selected_ver}.tgz && Download_src
    tar xzf swoole-${swoole_selected_ver}.tgz
    pushd swoole-${swoole_selected_ver} > /dev/null
    ${php_install_dir}/bin/phpize
    if [[ "${PHP_main_ver}" == 5.* || "${PHP_main_ver}" =~ ^7\.[0-1]$ ]]; then
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir}
    else
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir} --enable-http2 --enable-swoole-json --enable-swoole-curl
    fi
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/swoole.so" ]; then
      echo 'extension=swoole.so' > ${php_install_dir}/etc/php.d/06-swoole.ini
      echo "${CSUCCESS}PHP swoole module installed successfully! ${CEND}"
      rm -rf swoole-${swoole_selected_ver}
    else
      echo "${CFAILURE}PHP swoole module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_swoole() {
  if [ -e "${php_install_dir}/etc/php.d/06-swoole.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/06-swoole.ini
    echo; echo "${CMSG}PHP swoole module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP swoole module does not exist! ${CEND}"
  fi
}
