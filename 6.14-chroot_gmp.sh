#!/bin/bash

CHAPTER_SECTION=14
INSTALL_NAME=gmp

echo ""
echo "### ---------------------------"
echo "###              GMP        ###"
echo "###        CHAPTER 6.$CHAPTER_SECTION      ###"
echo "### GMP-6.0.0a"
echo "### Must be run as \"chroot\" user"
echo "### ---------------------------"

echo ""
echo "... Loading commun functions and variables"
if [ ! -f ./script-all_commun-functions.sh ]
then
  echo "!! Fatal Error 1: './script-all_commun-functions.sh' not found."
  exit 1
fi
source ./script-all_commun-functions.sh

if [ ! -f ./script-all_commun-variables.sh ]
then
  echo "!! Fatal Error 1: './script-all_commun-variables.sh' not found."
  exit 1
fi
source ./script-all_commun-variables.sh

echo ""
echo "... Validating the environment"
check_user root
check_partitions
check_chroot

echo ""
echo "... Setup building environment"
LOG_FILE=$LFS_BUILD_LOGS_6$CHAPTER_SECTION-$INSTALL_NAME
cd /sources
test_only_one_tarball_exists
extract_tarball ""
cd $(ls -d /sources/$INSTALL_NAME*/)

echo ""
echo "... Installation starts now"
time {

  echo ".... Configuring $SOURCE_FILE_NAME"
  ./configure                          \
    --prefix=/usr                      \
	  --enable-cxx                       \
	  --docdir=/usr/share/doc/gmp-6.0.0a \
	  &> $LOG_FILE-configure.log

	echo ".... Making $SOURCE_FILE_NAME"
  make $PROCESSOR_CORES &> $LOG_FILE-make.log

  echo ".... Making HTML $SOURCE_FILE_NAME"
  make html $PROCESSOR_CORES &> $LOG_FILE-make-html.log

  echo ".... Make Checking $SOURCE_FILE_NAME"
  make check $PROCESSOR_CORES &> $LOG_FILE-make-check.log

  echo ".... Testing $SOURCE_FILE_NAME"
  awk '/tests passed/{total+=$2} ; END{print total}' $LOG_FILE-make-check.log

  echo ""
  echo "Check above that the 188 tests passed"
  echo ""
  echo -e "\a"
  read -p "Enter to confirm" -n 1 -r
  echo ""

	echo ".... Installing $SOURCE_FILE_NAME"
  make install $PROCESSOR_CORES &> $LOG_FILE-make-install.log

  echo ".... Installing HTML $SOURCE_FILE_NAME"
  make install-html $PROCESSOR_CORES &> $LOG_FILE-make-install-html.log

}

echo ""
echo "... Cleaning up $SOURCE_FILE_NAME"
cd /sources
[ ! $SHOULD_NOT_CLEAN ] && rm -rf $(ls -d /sources/$INSTALL_NAME*/)

echo ""
echo "######### END OF CHAPTER 6.$CHAPTER_SECTION ########"
echo "///// HUMAN REQUIRED \\\\\\\\\\\\\\\\\\\\"
echo "### Please run the next step:"
echo "### ./6.15-chroot_mpfr.sh"
echo ""

exit 0