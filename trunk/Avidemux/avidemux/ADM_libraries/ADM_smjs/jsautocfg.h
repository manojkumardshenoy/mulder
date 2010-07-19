#ifndef js_autocfg___
#define js_autocfg___

/* AUTOMATICALLY GENERATED - DO NOT EDIT */
#include "ADM_coreConfig.h"


#ifdef ADM_BIG_ENDIAN
#undef   IS_LITTLE_ENDIAN 
#define  IS_BIG_ENDIAN 1
#else
#define IS_LITTLE_ENDIAN 1
#undef  IS_BIG_ENDIAN
#endif


#define JS_BYTES_PER_BYTE   1L
#define JS_BYTES_PER_SHORT  2L
#define JS_BYTES_PER_INT    4L
#define JS_BYTES_PER_INT64  8L
#define JS_BYTES_PER_FLOAT  4L
#define JS_BYTES_PER_DOUBLE 8L
#define JS_BYTES_PER_DWORD  8L

#ifdef ADM_CPU_64BIT
#ifdef __WIN32
#define JS_BYTES_PER_LONG   4L
#define JS_BITS_PER_LONG    32L
#define JS_BITS_PER_LONG_LOG2   5L
#define JS_ALIGN_OF_LONG    4L
#else
#define JS_BYTES_PER_LONG   8L
#define JS_BITS_PER_LONG    64L
#define JS_BITS_PER_LONG_LOG2   6L
#define JS_ALIGN_OF_LONG    8L
#endif	// __WIN32

#define JS_BYTES_PER_WORD   8L
#define JS_BITS_PER_WORD    64L
#define JS_BITS_PER_WORD_LOG2   6L

#define JS_ALIGN_OF_INT64   8L
#define JS_ALIGN_OF_DOUBLE  8L
#define JS_ALIGN_OF_POINTER 8L
#define JS_ALIGN_OF_WORD    8L


#else // 32bits
#define JS_BYTES_PER_LONG   4L
#define JS_BYTES_PER_WORD   4L
#define JS_BITS_PER_LONG    32L
#define JS_BITS_PER_WORD    32L
#define JS_BITS_PER_LONG_LOG2   5L
#define JS_BITS_PER_WORD_LOG2   5L

#define JS_ALIGN_OF_LONG    4L
#define JS_ALIGN_OF_INT64   4L
#define JS_ALIGN_OF_DOUBLE  4L
#define JS_ALIGN_OF_POINTER 4L
#define JS_ALIGN_OF_WORD    4L

#endif

#define JS_BITS_PER_BYTE    8L
#define JS_BITS_PER_SHORT   16L
#define JS_BITS_PER_INT     32L
#define JS_BITS_PER_INT64   64L
#define JS_BITS_PER_FLOAT   32L
#define JS_BITS_PER_DOUBLE  64L

#define JS_BITS_PER_BYTE_LOG2   3L
#define JS_BITS_PER_SHORT_LOG2  4L
#define JS_BITS_PER_INT_LOG2    5L
#define JS_BITS_PER_INT64_LOG2  6L
#define JS_BITS_PER_FLOAT_LOG2  5L
#define JS_BITS_PER_DOUBLE_LOG2 6L

#define JS_ALIGN_OF_SHORT   2L
#define JS_ALIGN_OF_INT     4L
#define JS_ALIGN_OF_FLOAT   4L

#if defined(ADM_CPU_64BIT) && defined(__WIN32)
#define JS_BYTES_PER_WORD_LOG2   3L
#define JS_BYTES_PER_DWORD_LOG2  3L
#define JS_WORDS_PER_DWORD_LOG2  0L
#else
#define JS_BYTES_PER_WORD_LOG2   2L
#define JS_BYTES_PER_DWORD_LOG2  3L
#define JS_WORDS_PER_DWORD_LOG2  1L
#endif

#define JS_STACK_GROWTH_DIRECTION (-1)

#endif /* js_cpucfg___ */