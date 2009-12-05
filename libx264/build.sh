######################################################
# x264 Build Script
######################################################

GIT_URL="git://git.videolan.org/x264.git"
COMPILERS="442"
CPUS="core2 amdfam10 pentium3 noasm"

######################################################

cls

rm --recursive --force ./x264-src

if [ -d "./x264-src" ]; then
  exit 1
fi

git clone $GIT_URL x264-src

if [ ! -f "./x264-src/x264.c" ]; then
  exit 1
fi

if [ "$1" != "" ]; then
  cd x264-src
  git checkout $1
  cd ..
fi

######################################################

apply_patch() {
  sleep 2

  echo "[ $i.diff ]"
  SUCCESS=no

  for j in 1 2 3 4 5
  do
    if [ "$SUCCESS" != "yes" ]; then
      cp "../$1.diff" "./$1.diff"
      patch -p1 < ./$1.diff
      if [ $? -eq 0 ]; then
        SUCCESS=yes
      else
        sleep 3
      fi
    fi
  done
  
  echo ""

  if [ "$SUCCESS" != "yes" ]; then
    return 1
  else
    return 0
  fi
}

######################################################

make_pthread() {
  echo ""
  echo "=============================================================================="
  echo "GCC Version: $1"
  echo "=============================================================================="
  echo ""
  
  umount /mingw
  mount d:/mingw.$1 /mingw

  rm -f "./pthreadGC2.dll"

  if [ -f "./pthreadGC2.dll" ]; then
    echo "Error: Could not delete the old pthreadGC2.dll"
    exit 1
  fi

  cd pthreads

  if [ ! -f "pthread.h" ]; then
    echo "Error: Is this pthreads dir ???"
    exit 1
  fi

  rm -f *.a
  rm -f *.dll

  make clean
  make GC-inlined
  
  strip pthreadGC2.dll
  cp pthreadGC2.dll ../pthreadGC2.dll

  cd ..

  if [ ! -f "./pthreadGC2.dll" ]; then
    echo "Error: Could not find pthreadGC2.dll"
    exit 1
  fi
}

######################################################

make_x264() {
  NAME=gcc$1-$2
  
  if [ "$3" != "" ]; then
    NAME=$3-$NAME
  fi

  PATCHES="print_params psy_trellis fast_firstpass"
  
  if [ $2 != "noasm" ]; then
    ECFLAGS="-march=$2"
  else
    ECFLAGS="-march=i686"
  fi

  #if [ $1 -ge 440 ]; then
  #  ECFLAGS="$ECFLAGS -floop-interchange -floop-strip-mine -floop-block"
  #fi
    
  if [ "$4" != "" ]; then
    PATCHES="$PATCHES $4"
  fi

  echo ""
  echo "=============================================================================="
  echo "GCC Version: $1"
  echo "CPU Type: $2"
  if [ "$3" != "" ]; then
    echo "Build Prefix: $3"
  else
    echo "Build Prefix: None"
  fi
  if [ "$4" != "" ]; then
    echo "Additional Patches: $4"
  else
    echo "Additional Patches: None"
  fi
  echo "=============================================================================="
  echo ""

  umount /mingw
  mount d:/mingw.$1 /mingw

  rm --recursive --force ./x264-$NAME

  if [ -d "./$NAME" ]; then
    return
  fi

  git clone ./x264-src x264-$NAME

  if [ -f "./x264-$NAME/x264.c" -a -f "./x264-$NAME/configure" -a -f "./x264-$NAME/Makefile" ]; then
    cd ./x264-$NAME
  else
    return
  fi
  
  echo ""
  echo "------------------------------------------------------------------------------"
  echo ""

  for i in $PATCHES
  do
    apply_patch "$i"
    if [ $? -ne 0 ]; then
      cd ..
      return
    fi
  done
  
  echo ""
  echo "------------------------------------------------------------------------------"
  echo ""

  if [ $2 != "noasm" ]; then
    ./configure --enable-shared --extra-cflags="$ECFLAGS"
  else
    ./configure --enable-shared --disable-asm --extra-cflags="$ECFLAGS"
  fi

  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  echo ""
  echo "------------------------------------------------------------------------------"
  echo ""

  make clean
  
  cp ../pthreadGC2.dll ./pthreadGC2.dll
  cp ../readme.1st ./readme.txt
  
  git log > history.txt
  git2rev history.txt

  7z a "patches.tar" *.diff
  
  echo ""
  echo "------------------------------------------------------------------------------"
  echo ""

  VER=$(grep X264_VERSION < config.h | cut -f 4 -d ' ')
  API=$(grep '#define X264_BUILD' < x264.h | cut -f 3 -d ' ')

  if [ $2 != "noasm" ]; then
    make fprofiled VIDS="../sample.avs"
  else
    make
  fi

  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  if [ -f "./libx264-$API.dll" -a -f "./pthreadGC2.dll" -a -f "./history.txt" -a -f "./readme.txt" -a -f "./patches.tar" ]; then
    7z a "libx264-$API-$VER-$NAME-fprofiled.7z" "libx264-$API.dll" "pthreadGC2.dll" "readme.txt" "history.txt" "patches.tar"
  fi
  
  cd ..
}

######################################################

for k in $COMPILERS
do
  make_pthread "$k"
  for l in $CPUS
  do
    make_x264 "$k" "$l" "" ""
    #make_x264 "$k" "$l" "noweightp" "no_weightp"
    #make_x264 "$k" "$l" "slices" "four_slices"
    #make_x264 "$k" "$l" "autovaq" "auto_vaq"
    #make_x264 "$k" "$l" "nombtree" "no_mbtree"
  done
done

######################################################

echo ""
echo "=============================================================================="
echo "DONE"
echo "=============================================================================="
echo ""

######################################################
