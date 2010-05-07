######################################################
# x264 Build Script
######################################################

GIT_URL="git://git.videolan.org/x264.git"
COMPILERS="460 451" #450 444 443"
CPUS="i686 core2 amdfam10 pentium3 noasm"

######################################################
# Do NOT modify any lines below this one!
######################################################

git --help > /dev/null

if [ $? -ne 0 ]; then
  echo "Git not working! Is Git installed?"
  exit
fi

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
  echo ""
  echo "Checkout: $1"
  echo ""
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
      patch -p1 < ../$1.diff
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
  echo -e "\n=============================================================================="
  echo "GCC Version: $1"
  echo -e "==============================================================================\n"
  
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

  PATCHES="core94to93 amdfam10_fix print_params psy_trellis fast_firstpass"
  
  if [ "$2" != "noasm" ]; then
    ECFLAGS="-march=$2"
  else
    ECFLAGS="-march=i686"
  fi

  if [ $1 -ge 440 ]; then
    ECFLAGS="$ECFLAGS -fno-tree-vectorize" #"-floop-interchange -floop-strip-mine -floop-block"
  fi
    
  if [ "$4" != "" ]; then
    PATCHES="$PATCHES $4"
  fi

  echo -e "\n=============================================================================="
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
  echo -e "==============================================================================\n"

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
  
  echo -e "\n------------------------------------------------------------------------------\n"

  for i in $PATCHES
  do
    apply_patch "$i"
    if [ $? -ne 0 ]; then
      cd ..
      return
    fi
  done
  
  echo -e "\n------------------------------------------------------------------------------\n"
 
  echo -e "Configure:\n"
  
  if [ "$2" != "noasm" ]; then
    ./configure --enable-shared --extra-cflags="$ECFLAGS"
  else
    ./configure --enable-shared --disable-asm --extra-cflags="$ECFLAGS"
  fi

  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  VER=$(grep X264_VERSION < config.h | cut -f 4 -d ' ')
  API=$(grep '#define X264_BUILD' < x264.h | cut -f 3 -d ' ')
  
  echo -e "\n--> x264 version: $VER (API: #$API)"
  
  echo -e "\n------------------------------------------------------------------------------\n"

  make clean
  cp ../readme.1st ./readme.txt
  
  git log > ./history.txt
  git2rev history.txt

  if [ "$3" != "" ]; then
    git diff > ./x264-patches-$3-$VER.diff
    7z a "patches.tar" "x264-patches-$3-$VER.diff"
  else
    git diff > ./x264-patches-$VER.diff
    7z a "patches.tar" "x264-patches-$VER.diff"
  fi
  
  echo -e "\n------------------------------------------------------------------------------\n"
  
  if [ "$2" != "noasm" ]; then
    make fprofiled VIDS="../sample.avs"
  else
    make
  fi
  
  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  echo -e "\n------------------------------------------------------------------------------\n"

  if [ $2 != "noasm" ]; then
    make checkasm
  fi

  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  if [ -f "./checkasm.exe" ]; then
    ./checkasm.exe 2> ./checkasm.log
  else
    echo "NOASM" > ./checkasm.log
  fi
  
  echo -e "\n------------------------------------------------------------------------------\n"

  if [ -f "./libx264-$API.dll" -a -f "./history.txt" -a -f "./readme.txt" -a -f "./patches.tar" -a -f "./checkasm.log" ]; then
    7z a "libx264-$API-$VER-$NAME-fprofiled.7z" "libx264-$API.dll" "readme.txt" "history.txt" "patches.tar" "checkasm.log"
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
    make_x264 "$k" "$l" "AutoVAQ" "auto_vaq"
    #make_x264 "$k" "$l" "NAL_HRD" "nal_hrd_vbr"
    #make_x264 "$k" "$l" "PIR" "periodic_intra_refresh"
  done
done

make_x264 "444" "i686" "" ""
make_x264 "345" "i686" "" ""

######################################################

echo -e "\n=============================================================================="
echo "DONE"
echo -e "==============================================================================\n"

######################################################
