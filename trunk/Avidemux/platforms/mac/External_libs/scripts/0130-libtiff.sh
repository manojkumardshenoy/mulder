# ------------------
#     libtiff
# ------------------
# $Id: libtiff.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukai
# Modified for avidemux by Harry van der Wolf 20080614

# download location http://www.remotesensing.org/libtiff/

# prepare

# export REPOSITORYDIR="/PATH2HUGIN/mac/ExternalPrograms/repository" \
# ARCHS="ppc i386" \
# ppcTARGET="powerpc-apple-darwin7" \
# i386TARGET="i386-apple-darwin8" \
#  ppcMACSDKDIR="/Developer/SDKs/MacOSX10.4u.sdk" \
#  i386MACSDKDIR="/Developer/SDKs/MacOSX10.3.9.sdk" \
#  ppcONLYARG="-mcpu=G3 -mtune=G4" \
#  i386ONLYARG="-mfpmath=sse -msse2 -mtune=pentium-m -ftree-vectorize" \
#  OTHERARGs="";


# init

let NUMARCH="0"

for i in $ARCHS
do
  NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile

for ARCH in $ARCHS
do

 mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
 mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
 mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";

 ARCHARGs=""
 MACSDKDIR=""
 OTHERMAKEARGs=""

 if [ $ARCH = "i386" -o $ARCH = "i686" ]
 then
  TARGET=$i386TARGET
  MACSDKDIR=$i386MACSDKDIR
  ARCHARGs="$i386ONLYARG"
 elif [ $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ]
 then
  TARGET=$ppcTARGET
  MACSDKDIR=$ppcMACSDKDIR
  ARCHARGs="$ppcONLYARG"
 elif [ $ARCH = "ppc64" -o $ARCH = "ppc970" ]
 then
  TARGET=$ppc64TARGET
  MACSDKDIR=$ppc64MACSDKDIR
  ARCHARGs="$ppc64ONLYARG"
 elif [ $ARCH = "x86_64" ]
 then
  TARGET=$x64TARGET
  MACSDKDIR=$x64MACSDKDIR
  ARCHARGs="$x64ONLYARG"
 fi

 env CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -dead_strip" \
  CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -dead_strip" \
  CPPFLAGS="-I$REPOSITORYDIR/include" \
  LDFLAGS="-L$REPOSITORYDIR/lib -dead_strip" \
  NEXT_ROOT="$MACSDKDIR" \
  ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
  --host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
  --enable-static --enable-shared --with-apple-opengl-framework --without-x;

 make clean;
 cd ./port; make $OTHERMAKEARGs;
 cd ../libtiff; make $OTHERMAKEARGs install;
 cd ../;

 rm $REPOSITORYDIR/include/tiffconf.h;
 cp "./libtiff/tiffconf.h" "$REPOSITORYDIR/arch/$ARCH/include/tiffconf.h";

done


# merge libtiff

for liba in lib/libtiff.a lib/libtiffxx.a lib/libtiff.3.dylib lib/libtiffxx.3.dylib
do

 if [ $NUMARCH -eq 1 ]
 then
  mv "$REPOSITORYDIR/arch/$ARCHS/$liba" "$REPOSITORYDIR/$liba";
  if [[ $liba == *.a ]]
  then 
   ranlib "$REPOSITORYDIR/$liba";
  fi
  continue
 fi

 LIPOARGs=""
 
 for ARCH in $ARCHS
 do
  LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$liba"
 done

 lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
 if [[ $liba == *.a ]]
 then 
  ranlib "$REPOSITORYDIR/$liba";
 fi

done


if [ -f "$REPOSITORYDIR/lib/libtiff.3.dylib" ]
then
 install_name_tool -id "$REPOSITORYDIR/lib/libtiff.3.dylib" "$REPOSITORYDIR/lib/libtiff.3.dylib";
 ln -sfn libtiff.3.dylib $REPOSITORYDIR/lib/libtiff.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libtiffxx.3.dylib" ]
then
 install_name_tool -id "$REPOSITORYDIR/lib/libtiffxx.3.dylib" "$REPOSITORYDIR/lib/libtiffxx.3.dylib";
 for ARCH in $ARCHS
 do
  install_name_tool -change "$REPOSITORYDIR/arch/$ARCH/lib/libtiff.3.dylib" "$REPOSITORYDIR/lib/libtiff.3.dylib" "$REPOSITORYDIR/lib/libtiffxx.3.dylib";
 done
 ln -sfn libtiffxx.3.dylib $REPOSITORYDIR/lib/libtiffxx.dylib;
fi



# merge config.h

for conf_h in include/tiffconf.h
do
 
 echo "" > "$REPOSITORYDIR/$conf_h";

 if [ $NUMARCH -eq 1 ]
 then
  mv $REPOSITORYDIR/arch/$ARCHS/$conf_h $REPOSITORYDIR/$conf_h;
  continue;
 fi

 for ARCH in $ARCHS
 do
  if [ $ARCH = "i386" -o $ARCH = "i686" ]
  then
   echo "#if defined(__i386__)"              >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   cat  "$REPOSITORYDIR/arch/$ARCH/$conf_h"  >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   echo "#endif"                             >> "$REPOSITORYDIR/$conf_h";
  elif [ $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ]
  then
   echo "#if defined(__ppc__)"               >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   cat  "$REPOSITORYDIR/arch/$ARCH/$conf_h"  >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   echo "#endif"                             >> "$REPOSITORYDIR/$conf_h";
  elif [ $ARCH = "ppc64" -o $ARCH = "ppc970" ]
  then
   echo "#if defined(__ppc64__)"             >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   cat  "$REPOSITORYDIR/arch/$ARCH/$conf_h"  >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   echo "#endif"                             >> "$REPOSITORYDIR/$conf_h";
  elif [ $ARCH = "x86_64" ]
  then
   echo "#if defined(__x86_64__)"             >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   cat  "$REPOSITORYDIR/arch/$ARCH/$conf_h"  >> "$REPOSITORYDIR/$conf_h";
   echo ""                                   >> "$REPOSITORYDIR/$conf_h";
   echo "#endif"                             >> "$REPOSITORYDIR/$conf_h";
  fi
 done

done




