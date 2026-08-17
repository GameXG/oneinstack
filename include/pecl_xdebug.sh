#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_xdebug() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    case "${PHP_main_ver}" in
      7.0) xdebug_selected_ver=${xdebug_php70_ver}; xdebug_config_ver=2 ;;
      7.1) xdebug_selected_ver=${xdebug_php71_ver}; xdebug_config_ver=2 ;;
      7.2|7.3|7.4) xdebug_selected_ver=${xdebug_php72_74_ver}; xdebug_config_ver=3 ;;
      8.*) xdebug_selected_ver=${xdebug_php80_up_ver}; xdebug_config_ver=3 ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support xdebug! ${CEND}"
        popd > /dev/null
        return 0
        ;;
    esac
    src_url=https://pecl.php.net/get/xdebug-${xdebug_selected_ver}.tgz && Download_src
    tar xzf xdebug-${xdebug_selected_ver}.tgz
    pushd xdebug-${xdebug_selected_ver} > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/xdebug.so" ]; then
      src_url=${mirror_link}/oneinstack/src/webgrind-master.zip && Download_src
      unzip -q webgrind-master.zip
      /bin/mv webgrind-master ${wwwroot_dir}/default/webgrind
      [ ! -e /tmp/xdebug ] && { mkdir /tmp/xdebug; chown ${run_user}:${run_group} /tmp/xdebug; }
      [ ! -e /tmp/webgrind ] && { mkdir /tmp/webgrind; chown ${run_user}:${run_group} /tmp/webgrind; }
      chown -R ${run_user}:${run_group} ${wwwroot_dir}/default/webgrind
      sed -i 's@static $storageDir.*@static $storageDir = "/tmp/webgrind";@' ${wwwroot_dir}/default/webgrind/config.php
      sed -i 's@static $profilerDir.*@static $profilerDir = "/tmp/xdebug";@' ${wwwroot_dir}/default/webgrind/config.php
      if [ "${xdebug_config_ver}" == '2' ]; then
        cat > ${php_install_dir}/etc/php.d/08-xdebug.ini << EOF
[xdebug]
zend_extension=xdebug.so
xdebug.trace_output_dir=/tmp/xdebug
xdebug.profiler_output_dir=/tmp/xdebug
xdebug.profiler_enable=On
xdebug.profiler_enable_trigger=1
EOF
      else
        cat > ${php_install_dir}/etc/php.d/08-xdebug.ini << EOF
[xdebug]
zend_extension=xdebug.so
xdebug.mode=profile
xdebug.output_dir=/tmp/xdebug
xdebug.start_with_request=trigger
EOF
      fi
      echo "${CSUCCESS}PHP xdebug module installed successfully! ${CEND}"
      echo; echo "Webgrind URL: ${CMSG}http://{Public IP}/webgrind ${CEND}"
      rm -rf xdebug-${xdebug_selected_ver}
    else
      echo "${CFAILURE}PHP xdebug module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_xdebug() {
  if [ -e "${php_install_dir}/etc/php.d/08-xdebug.ini" ]; then
    rm -rf ${php_install_dir}/etc/php.d/08-xdebug.ini /tmp/{xdebug,webgrind} ${wwwroot_dir}/default/webgrind
    echo; echo "${CMSG}PHP xdebug module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP xdebug module does not exist! ${CEND}"
  fi
}
