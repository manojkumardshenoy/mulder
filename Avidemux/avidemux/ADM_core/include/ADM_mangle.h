/** *************************************************************************
    \fn ADM_mangle.h
    \brief Handle symbol mangling & register name for inline asm
                      
    copyright            : (C) 2008 by mean
    
 ***************************************************************************/

#ifndef ADM_MANGLE_H
#define ADM_MANGLE_H

#include "ADM_coreConfig.h"

#if ( defined(__PIC__) || defined(__pic__) ) && ! defined(PIC)
#    define PIC
#endif

// Use rip-relative addressing if compiling PIC code on x86-64.
#if defined(__MINGW32__) || defined(__CYGWIN__) || defined(__DJGPP__) || \
    defined(__OS2__) || (defined (__OpenBSD__) && !defined(__ELF__)) || \
	defined(__APPLE__)
#    if defined(ADM_CPU_X86_64) && defined(PIC) && !defined(__MINGW32__)
#        define MANGLE(a) "_" #a"(%%rip)"
#        define FUNNY_MANGLE(x) x asm(MANGLE(x))
#        define FUNNY_MANGLE_ARRAY(x, y) x[y] asm(MANGLE(x))
#    else
#        define MANGLE(a) "_" #a
#        define FUNNY_MANGLE(x) x asm(MANGLE(x))
#        define FUNNY_MANGLE_ARRAY(x, y) x[y] asm(MANGLE(x))
#    endif
#else
#    if defined(ADM_CPU_X86_64) && defined(PIC)
#        define MANGLE(a) #a"(%%rip)"
#        define FUNNY_MANGLE(x) x asm(#x)
#        define FUNNY_MANGLE_ARRAY(x, y)  x[y] asm(#x)
#    elif defined(__APPLE__)
#        define MANGLE(a) "_" #a
#    else
#        define MANGLE(a) #a
#        define FUNNY_MANGLE(x) x asm(MANGLE(x))
#        define FUNNY_MANGLE_ARRAY(x, y) x[y] asm(MANGLE(x))
#    endif
#endif

#define Mangle MANGLE

#define ADM_ALIGN16 ".p2align 4\n"
/* Regiter renaming */
#ifdef ADM_CPU_X86_64
#define REG_a  "rax" 
#define REGa    rax 
#define REGb    rbx 
#define REGc    rcx 
#define REG_b  "rbx"
#define REG_c  "rcx" 
#define REG_d  "rdx" 
#define REG_S  "rsi" 
#define REG_D  "rdi" 
#define REGSP   rsp  
#define REG_SP "rsp" 
#define REG_BP "rbp" 
#else
#define REGa    eax  
#define REGb    ebx 
#define REGc    ecx 
#define REG_a  "eax"  
#define REG_b  "ebx" 
#define REG_c  "ecx" 
#define REG_d  "edx" 
#define REG_S  "esi" 
#define REG_D  "edi" 
#define REG_SP "esp" 
#define REGSP   esp  
#define REG_BP "ebp" 
#endif

#define REG_ax "%%"REG_a
#define REG_bx "%%"REG_b
#define REG_cx "%%"REG_c
#define REG_dx "%%"REG_d

#define REG_si "%%"REG_S
#define REG_di "%%"REG_D

#define REG_sp "%%"REG_SP
#define REG_bp "%%"REG_BP

#ifndef attribute_used
#if defined(__GNUC__) && (__GNUC__ > 3 || __GNUC__ == 3 && __GNUC_MINOR__ > 0)
#    define attribute_used __attribute__((used))
#else
#    define attribute_used
#endif
#endif

#define ASM_CONST attribute_used __attribute__ ((aligned(8)))
#endif
