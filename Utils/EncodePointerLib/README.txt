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


Background
----------

The Visual C++ 2010 linker sets the 'OperatingSystemVersion' field in the PE header of the executable to 5.1 by default.

This will prevent the executable from loading on any operating system prior to Windows NT 5.1 - better known as Windows XP.

So, in order to make the binary load on Windows 2000, we have to force the 'OperatingSystemVersion' to 5.0 (or lower).

Unfortunately that isn't enough. Bummer!

The C Run-Time Libraries (CRT) of Visual C++ 2010 reference two system functions that were not available on Windows 2000.

Therefore, on Windows 2000, you will see an error message about the missing entry point "DecodePointer" in KERNEL32.DLL.

Note that the entry point "EncodePointer" is missing too. These functions were added to KERNEL32.DLL with Windows XP (SP-2).

We can get rid of the dependencies on "EncodePointer" and "DecodePointer" by linking 'EncodePointer.lib' into the binay.

After linking the library you can check that the two problematic functions are no longere imported from KERNEL32.DLL :-)

Please be aware that this "workaround" can only succeed with the static(!) C Run-Time Library, but not with the DLL version!


How EncodePointer.lib works
---------------------------

When the executable that contains the "main" functions calls some function from a DLL, it actually calls a "stub" functions.

The "stub" function is linked into the executable by the import library. That's the .lib file that corresponds to the DLL.

We have to use a "stub" function, because at compile-time the address of the actualy function (in the DLL) can not be known.

Instead the "stub" will look up the address of the actual function in the 'import address table' and then jump to that address.

The import address table will be updated by the operating system's loader. This happens at load-time, not at compile-time!

So how can we eliminate DLL imports, such as "DecodePointer" without modifying the CRT ???

For each function that is imported from some DLL there is a corresponding "slot" in the executable's import address table.

If the function is named "Foobar" (decorated name!), then the address of the slot is refered to by the symbol "__imp_Foobar".

Keep in mind that "__imp_Foobar" is NOT the address of the function, but the address where the function's address is stored!

Consequently by defining the symbol "__imp__DecodePointer@4" we can redirect the DLL call to some "built-in" function.

Note that the decorated name of "DecodePointer" is "_DecodePointer@4", so the symbol of the slot is NOT "__imp_DecodePointer."

Apparently Visual C++ is smart enough to wipe out the DLL import after "_DecodePointer@4" has been defined explicitely!

In "EncodePointer.asm" both, __imp__DecodePointer@4 and __imp__EncodePointer@4, are redirected to a simple substitute function.


eof.
