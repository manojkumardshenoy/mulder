yasm -O2 -f win32 -DPREFIX -DHAVE_ALIGNED_STACK=1 -DHIGH_BIT_DEPTH=0 -DBIT_DEPTH=8 -DARCH_X86_64=0 -o cpu-a.obj cpu-a.asm
