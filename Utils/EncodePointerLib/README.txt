Encode Pointer Library, by LoRd_MuldeR <mulder2@gmx.de>
=======================================================

This library was created to allow executables compiled with Visual C++ 2010 to run under Windows 2000.

If you are not using the Visual C++ 2010 compiler or if you don't care about Windows 2000, then this library is not for you ;-)

Also note that this is experimental. There is absolutely no guarantee that your program will work properly this way!


Instructions
------------

There are three simple steps required to make Visual C++ 2010 binaries run under Windows 2000:

(1) In your project properties, change "C/C++" -> "Code Generation" -> "Runtime Library" to "Multi-threaded (/MT)"

(2) In your project properties, change "Linker" -> "System" -> "Minimum Required Version" to "5.0"

(3) In your project properties, add "EncodePointer.lib" to "Linker" -> "Input" -> "Additional Dependencies"
    
    If you explicitely link against "kernel32.lib", please make sure that "EncodePointer.lib" is first in the list!


Background
----------

The Visual C++ 2010 linker sets the 'OperatingSystemVersion' field in the PE header of the executable to 5.1 by default.

This will prevent the executable from loading on any operating system prior to Windows NT 5.1 - better known as Windows XP.

On Windows 2000, for example, you will get an error message which says that this is not a valid Win32 application :-(

So, in order to make the binary load on Windows 2000, we have to force the 'OperatingSystemVersion' to '5.0' or even lower.

Unfortunately that isn't enough. Bummer !!!

The C Run-Time Libraries (CRT) of Visual C++ 2010 reference two system functions that were NOT available on Windows 2000.

Therefore, even when the 'Minimum Required Version' is forced to '5.0', the binary still refuses to run.

Instead of the previous error, you will now get an error message about the missing entry point "DecodePointer" in KERNEL32.DLL.

Note that the entry point "EncodePointer" is missing too. These  functions were added to KERNEL32.DLL with Windows XP (SP-2).

We can get rid of the dependencies on "EncodePointer" and "DecodePointer" by linking 'EncodePointer.lib' into the binay though.

After linking that library, you will notice that the two problematic functions are no longere imported from KERNEL32.DLL :-)

I suggest that you verify this with the help of Dependency Walker - http://www.dependencywalker.com/.

Once the problematic imports from KERNEL32.DLL have been eliminated, your binary should run on Windows 2000 just fine.


How EncodePointer.lib works
---------------------------

When the executable that contains the "main" function calls some function from a DLL, it actually calls a "stub" function.

The "stub" function is linked into the executable by the import library. That's the .lib file that corresponds to the DLL.

We have to use a "stub" function, because at compile-time the address of the actual function (in the DLL) can not be known yet.

Instead the "stub" will look up the address of the actual function in the 'import address table' and then jump to that address.

The import address table will be updated by the operating system's loader. This happens at load-time, NOT at compile-time!

So how can we eliminate DLL imports, such as "DecodePointer" without modifying the CRT ???

For each function that is imported from some DLL there is a corresponding "slot" in the executable's import address table.

If the function is named "Foobar" (decorated name!), then the address of the slot is refered to by the symbol "__imp_Foobar".

Keep in mind that "__imp_Foobar" is NOT the address of the function, but the address where the function's address is stored!

Consequently by defining the symbol "__imp__DecodePointer@4" we can redirect the DLL call to some "built-in" function.

Note that the decorated name of "DecodePointer" is "_DecodePointer@4", so the symbol of the slot is NOT "__imp_DecodePointer."

Apparently the linker is smart enough to wipe out the DLL import for "Foo" after "__imp__Foo" has been defined explicitely!

The EncodePointer.lib consists of a single ASM file, which defines the required symbols to resolve our problem:

In "EncodePointer.asm" both, __imp__DecodePointer@4 and __imp__EncodePointer@4, are redirected to a simple substitute function.

Thus, if you link your binary against EncodePointer.lib, EncodePointer/DecodePointer won't be called from KERNL32.DLL anymore.


Why it only works with the "static" CRT
---------------------------------------

EncodePointer.lib has to be linked into the binary which imports "DecodePointer" or "EncodePointer" from KERNEL32.DLL.

When using the "shared" CRT library (DLL version), then it's NOT your binary but MSVCRT100.DLL which imports these functions!

And, as MSVCRT100.DLL is generally provided as a pre-compiled redistributable, there is nothing we can do about that.

Special attention has to be taken when linking third-party DLL's into your executable file - they might import MSVCRT100.DLL!

As linking DLL files with the "static" CRT library is discouraged, it is recommended to link ALL libraries statically.


Platform Support
----------------

Please be aware that there is absolutely no guarantee that the CRT of Visual C++ 2010 will work properly on Windows 2000.

Anyway, I have tested EncodePointer.lib with a complex Qt-based GUI application and I have not encountered any problems so far.

Also using EncodePointer.lib does NOT break the compatibility with Windows XP or Windows 7, as far as I can tell...


Security Notice
---------------

The original implementation of EncodePointer() will obfuscate a pointer with a secret that is specific to the calling process.

DecodePointer() will restore the original pointer value from a pointer that has previously been encoded by EncodePointer().

Since it is impossible to predict an encoded pointer, encoded pointers provide another layer of protection for pointer values.

Currently the substitute functions implemented in 'EncodePointer.lib' do NOT provide that layer of protection!

Instead the substitute functions for EncodePointer() and DecodePointer() simply XOR the pointer with a hard-coded constant.


eof.
