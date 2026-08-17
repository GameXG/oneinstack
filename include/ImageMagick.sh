#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ImageMagick() {
  if [ -d "${imagick_install_dir}" ]; then
    echo "${CWARNING}ImageMagick already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null || return 1
    imagemagick_archive=ImageMagick-${imagemagick_ver}.tar.gz
    imagemagick_source_dir=ImageMagick-${imagemagick_ver}

    if [ ! -s "${imagemagick_archive}" ] || ! tar tzf "${imagemagick_archive}" > /dev/null 2>&1; then
      echo "${CWARNING}${imagemagick_archive} is incomplete; downloading it again.${CEND}"
      rm -f "${imagemagick_archive}"
      src_url=${mirror_link}/oneinstack/src/${imagemagick_archive}
      Download_src no_kill
    fi
    if [ ! -s "${imagemagick_archive}" ] || ! tar tzf "${imagemagick_archive}" > /dev/null 2>&1; then
      rm -f "${imagemagick_archive}"
      echo "${CFAILURE}${imagemagick_archive} download or integrity check failed.${CEND}"
      popd > /dev/null
      return 1
    fi

    rm -rf "${imagemagick_source_dir}"
    if ! tar xzf "${imagemagick_archive}"; then
      echo "${CFAILURE}ImageMagick ${imagemagick_ver} source extraction failed.${CEND}"
      popd > /dev/null
      return 1
    fi
    #if [ "${PM}" == 'yum' ]; then
    #  yum -y install libwebp-devel
    #elif [ "${PM}" == 'apt-get' ]; then
    #  yum -y install libwebp-dev
    #fi
    if ! pushd "${imagemagick_source_dir}" > /dev/null; then
      echo "${CFAILURE}ImageMagick ${imagemagick_ver} source directory is missing.${CEND}"
      popd > /dev/null
      return 1
    fi
    if ! ./configure --prefix=${imagick_install_dir} --enable-shared --enable-static || ! make -j ${THREAD} || ! make install; then
      echo "${CFAILURE}ImageMagick ${imagemagick_ver} build failed.${CEND}"
      popd > /dev/null
      popd > /dev/null
      return 1
    fi
    popd > /dev/null
    rm -rf "${imagemagick_source_dir}"
    popd > /dev/null
  fi
}

Uninstall_ImageMagick() {
  if [ -d "${imagick_install_dir}" ]; then
    rm -rf ${imagick_install_dir}
    echo; echo "${CMSG}ImageMagick uninstall completed${CEND}"
  fi
}

Install_pecl_imagick() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [[ "${PHP_main_ver}" =~ ^5\.[3-5]$ ]]; then
      tar xzf imagick-${imagick_oldver}.tgz
      pushd imagick-${imagick_oldver} > /dev/null
    else
      tar xzf imagick-${imagick_ver}.tgz
      pushd imagick-${imagick_ver} > /dev/null
    fi
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=${imagick_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/03-imagick.ini
      echo "${CSUCCESS}PHP imagick module installed successfully! ${CEND}"
      rm -rf imagick-${imagick_ver} imagick-${imagick_oldver}
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
      popd > /dev/null
      return 1
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_imagick() {
  if [ -e "${php_install_dir}/etc/php.d/03-imagick.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/03-imagick.ini
    echo; echo "${CMSG}PHP imagick module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP imagick module does not exist! ${CEND}"
  fi
}
