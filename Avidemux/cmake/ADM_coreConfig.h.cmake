#ifndef ADM_CORE_H
#define ADM_CORE_H

#define ADM_INSTALL_DIR "${ADM_INSTALL_DIR}"

// GCC - CPU
#cmakedefine ADM_BIG_ENDIAN
#cmakedefine ADM_CPU_64BIT
#cmakedefine ADM_CPU_ALTIVEC
#cmakedefine ADM_CPU_DCBZL
#cmakedefine ADM_CPU_PPC
#cmakedefine ADM_CPU_MMX2
#cmakedefine ADM_CPU_SSSE3
#cmakedefine ADM_CPU_X86
#cmakedefine ADM_CPU_X86_32
#cmakedefine ADM_CPU_X86_64

// GCC - Operating System
#cmakedefine ADM_BSD_FAMILY

// 'gettimeofday' function is present
#cmakedefine HAVE_GETTIMEOFDAY

// Presence of header files
#cmakedefine HAVE_BYTESWAP_H
#cmakedefine HAVE_INTTYPES_H
#cmakedefine HAVE_MALLOC_H
#cmakedefine HAVE_STDINT_H
#cmakedefine HAVE_SYS_TYPES_H

#ifdef __MINGW32__
#define rindex strrchr
#define index strchr
#define ftello ftello64
#define fseeko fseeko64
#endif

#endif