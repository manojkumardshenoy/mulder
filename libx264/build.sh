######################################################
# x264 Build Script
######################################################

GIT_URL="git://git.videolan.org/x264.git"
DEFAULT_PATCHES="x264_amdfam10_fix x264_print_params x264_dll_version"
COMPILERS_STABLE="452 445"
COMPILERS_OTHERS="460 451 345"
CPU_TYPES="i686 core2 amdfam10 pentium3 noasm"
ROOT_DRIVE="e"

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
  sleep 1

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

test_configuration() {
  rm -f ./conftest.c
  rm -f ./conftest.exe
  echo -e "int main(int argc, char **argv) { return 42; }\n" > ./conftest.c
  gcc $1 -o ./conftest.exe ./conftest.c > /dev/null 2> /dev/null
  SUCCESS=$?
  rm -f ./conftest.c
  rm -f ./conftest.exe
  return $SUCCESS
}

######################################################

make_pthread() {
  echo -e "\n=============================================================================="
  echo "GCC Version: $1"
  echo -e "==============================================================================\n"
  
  umount /mingw
  mount $ROOT_DRIVE:/mingw.$1 /mingw
  gcc --version
  
  echo -e "\n------------------------------------------------------------------------------\n"

  cd pthreads

  if [ -f "pthread.h" -a -f "GNUmakefile" ]; then
    make clean
    make realclean
  else
    echo "Error: Is this pthreads dir ???"
    exit 1
  fi
 
  gcc -v 2> compiler.ver

  if [ -f "libpthreadGC2.a" ]; then
    echo "Error: Could not delete existing libpthreadGC2.a !!!"
    cd ..
    exit 1
  fi
  
  make GC-static
  
  if [ ! -f "libpthreadGC2.a" ]; then
    echo "Error: Could not find the new libpthreadGC2.a !!!"
    cd ..
    exit 1
  fi

  cd ..
}

######################################################

make_x264() {
  NAME=gcc$1-$2
  
  if [ "$3" != "" ]; then
    NAME=$3-$NAME
  fi

  PATCHES="$DEFAULT_PATCHES"
  
  ELFLAGS="-L../pthreads"
  ECFLAGS="-I../pthreads"
  
  if [ -f "./libpack/lib/libavcodec.a" -a -f "./libpack/include/libavcodec/avcodec.h" -a $1 -ge 445 -a $1 -lt 460 ]; then #TODO: Fix for other GCC versions
    ELFLAGS="$ELFLAGS -L../libpack/lib"
    ECFLAGS="$ECFLAGS -I../libpack/include"
  fi
  
  if [ "$2" != "noasm" ]; then
    ECFLAGS="$ECFLAGS -march=$2"
  else
    ECFLAGS="$ECFLAGS -march=i686"
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
  mount $ROOT_DRIVE:/mingw.$1 /mingw
  gcc --version

  if [ $? -ne 0 ]; then
    echo "Error: GCC is not working !!!"
    return
  fi

  test_configuration "-flto"
  if [ $? -eq 0 ]; then
    echo "LTO enabled :-)"
    ECFLAGS="$ECFLAGS -flto"
    ELFLAGS="$ELFLAGS -flto" # -fwhole-program
    PATCHES="x264_make_lto $PATCHES"
  else
    echo "LTO disabled :-("
  fi

  echo -e "\n------------------------------------------------------------------------------\n"

  rm --recursive --force ./x264-$NAME

  if [ -d "./x264-$NAME" ]; then
    return
  fi

  git clone ./x264-src x264-$NAME

  if [ -f "./x264-$NAME/x264.c" -a -f "./x264-$NAME/configure" -a -f "./x264-$NAME/Makefile" ]; then
    cd ./x264-$NAME
  else
    return
  fi
  
  gcc -v 2> compiler.ver

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
    ./configure --enable-shared --extra-cflags="$ECFLAGS" --extra-ldflags="$ELFLAGS"
  else
    ./configure --enable-shared --disable-asm --extra-cflags="$ECFLAGS" --extra-ldflags="$ELFLAGS"
  fi

  if [ $? -ne 0 ]; then
    cd ..
    return
  fi

  if [ "$2" != "noasm" -a "$(grep '#define HAVE_MMX ' < config.h | cut -f 3 -d ' ')" != "1" ]; then
    echo -e "\nError: MMX/ASM is *not* enabled. Aborting!\n"
    cd ..
    return
  fi
  
  if [ "$(grep '#define HAVE_POSIXTHREAD' < config.h | cut -f 3 -d ' ')" != "1" ]; then
    echo -e "\nError: PThread is not enabled!\nAre the PThread library and the required .h files there?"
    cd ..
    return
  fi

  if [ "$(grep '#define PTW32_STATIC_LIB' < config.h | cut -f 3 -d ' ')" != "1" ]; then
    echo -e "\nError: PThread library is not static!"
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

  if [ -f "./libx264-$API.dll" -a -f "./x264.exe" -a -f "./history.txt" -a -f "./readme.txt" -a -f "./patches.tar" -a -f "./checkasm.log" -a -f "./compiler.ver" ]; then
    7z a "libx264-$API-$VER-$NAME-fprofiled.7z" "libx264-$API.dll" "x264.exe" "readme.txt" "history.txt" "patches.tar" "checkasm.log" "compiler.ver"
  fi
  
  cd ..
}

######################################################

for k in $COMPILERS_STABLE
do
  make_pthread "$k"
  for l in $CPU_TYPES
  do
    make_x264 "$k" "$l" "" ""
  done
done

for k in $COMPILERS_OTHERS
do
  make_pthread "$k"
  make_x264 "$k" "i686" "" ""
done

######################################################

shutdown -s -t 300

echo -e "\n=============================================================================="
echo "DONE"
echo -e "==============================================================================\n"

cmd /c pause
shutdown -a

######################################################
