Simple x264 Launcher - use 64-Bit x264 with 32-Bit Avisynth
Copyright (C) 2004-2013 LoRd_MuldeR <MuldeR2@GMX.de>


1. Introduction
---------------

This program is a simple GUI front-end for the x264 H.264/AVC encoder.

For information about the x264 encoder software, please see:
http://en.wikipedia.org/wiki/X264

For information about Graphical User Interfaces (GUI), please see:
http://en.wikipedia.org/wiki/Graphical_user_interface


2. List of Features
-------------------

(a) Support for 32-Bit and 64-Bit x264 (64-Bit is used where supported)
(b) Support for 8-Bit and 10-Bit H.264 encoding (default is 8-Bit)
(c) Support for easy configuration using the x264 Preset/Tuning system
    - Support for custom configuration Templates
    - Support for custom x264 and Avs2YUV parameters
(d) Support for native FFmpegSource2 input (AVI, MKV, MP4, FLV, etc.)
(e) Support for batch encoding, i.e. enqueuing multiple encoding jobs
    - Support for running multiple encoding jobs in parallel
    - Support for shutting down the computer when all jobs are done
(f) Support for Avisynth (.AVS) input
    - Support for 32-Bit and 64-Bit Avisynth (default is 32-Bit)
    - Support for using 64-Bit x264 in conjunction with 32-Bit Avisynth
(g) Support for VapurSynth (.VPY) input
(h) Support for MP4 and MKV output as well as "raw" H.264
(i) Support for running the program in "portable" mode [see section 6]


3. System Requirements
----------------------

(a) Windows XP with Service Pack 2 and later 
(b) 64-Bit Windows is highly recommended, but 32-Bit Windows is okay
(c) The CPU must support at least the MMX and SSE-1 instruction sets
(d) Avisynth input only available with Avisynth 2.5+ installed
(e) VapourSynth input only available with VapourSynth R19+ installed
(f) YV16/YV24 color spaces require Avisynth 2.6 [see section 10]

100% standalone, does *not* require Mircrosoft.NET or other runtimes


4. Anti-Virus Warning
---------------------

Occasionally your Antivirus program may mistakenly detect "malware"
(virus, trojan, worm, etc.) in some of the files here. This is called a
"False Positive" and the files are actually innocent/clean. It�s an
error in your specific Antivirus software.

In case you encounter such problems, go to http://www.virustotal.com/
and check the file again with multiple Antivirus engines! And take care
with results like "suspicious" , "generic" or "packed". Those are *not*
real hits, they are just wild speculation.

Apparently Antivirus programs tend to suspect installers/uninstaller
created with NSIS. Furthermore some Antivirus programs blindly suspect
all UPX�d (packed) executables of being malware. Obviously this is a
stupid generalization, so you can safely ignore those warnings!

Last but not least: Always keep in mind that this is OpenSource
software! If you don�t trust the people providing the pre-compiled
binaries, download the source codes and compile them yourself.

DON�T SUBMIT ANY VIRUS/TROJAN REPORTS, UNLESS YOU HAVE VERIFIED THE
INFECTION WITH MULTIPLE ANTIVIRUS ENGNINES. THANKS!


5. License
----------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

http://www.gnu.org/licenses/gpl-2.0.txt


6. Portable Mode
----------------

This application can be run in "portable" mode. Just rename the EXE
file to 'x264_launcher_portable.exe' in order to trigger portable mode.
In that mode all configuration files will be saved in the same folder
where the EXE file resides. This may be helpful, if you want to run the
application directly from your USB stick on different computers. Note,
however, that in portable mode the install folder must be writable!


7. Updating Your x264 Binaries
------------------------------

This application works best with the x264 binaries that are included in
the distribution package. That's because these binaries have been
tested to work properly with the GUI. Nonetheless in some cases you may
want to replace the included binaries with a newer version of x264 or
with an alternative build of the same version. Generally newer versions
of x264 should work with the GUI too, though there is NO guarantee. In
rare cases the CLI syntax (or console output) of x264 may change in a
way that breaks the compatibility and therefore will require an update
of the GUI itself. Furthermore this application does NOT provide any
support for unofficial x264 patches. Usually x264 builds that contain
unofficial patches will work anyway, but again there is NO guarantee.
Using old/outdated x264 binaries with this application is NOT supported
or intended. Report bugs rather than reverting to an old version!


8. Timeout Warning
------------------

This application provides "deadlock" prevention. This means that if an
encoder process (x264 or Avisynth) stops responding, it will be
terminated. This is done in order to ensure that the main program as
well as the other encoder processes can continue properly. More
specifically, a warning will be raised if the process does not respond
for one minute. If the process still didn't respond after five minutes,
it will be terminated and consequently the encoding job is aborted. In
some rare cases, your Avisynth script may take a very long time to
initialize and thus the process will be aborted before the encoding can
start. For example, this can happen if FFMS2/FFVideoSource takes a very
long time to index the source file. In that case, we recommend to index
the source file beforehand, e.g. by using the 'ffmsindex' tool.


9. Custom Parameters
--------------------

This application provides a "Custom Parameters" edit box. All command-
line parameters you enter there will be passed to x264 unmodified. This
way you can send arbitrary parameters to x264 - even such ones that are
only available in patched builds of x264. See the x264 Wiki or the Help
Screen for a list of available parameters. However be aware that the
GUI will not check your parameters at all! Thus using an unknown or
unsupported parameter will cause your encode to fail. Using an existing
parameter in the wrong way will cause your encode to fail too. Last but
not least, some parameters are forbidden by the GUI. If some parameter
is forbidden, that's because the GUI will set that parameter for you
(if required) or because that parameter is NOT compatible with the GUI.

Hint: Occasionally your custom parameters string may become very long,
especially when working with zones. In that case you can right-click on
the "Custom Parameters" edit box and choose "Open the Text-Editor".
This will open a multi-line text editor for easier parameter handling.


10. Color Spaces / Chroma Subsampling
-------------------------------------

Avs2YUV converts the output of your Avisynth script to the YV12 format,
i.e. YUV data with 4:2:0 chroma subsampling and 8-Bit precision.
Usually this is exactly what you want/need. If, however, your Avisynth
script outputs image data with a higher chroma resolution, e.g. YUY2
(4:2:2), then the conversion to YV12 (4:2:0) will discard some of the
information. In that case, and if you want/need to keep the full chroma
resolution of your Avisynth script's output, you will have to pass the
"-csp" switch to Avs2YUV as a custom parameter! Use "-csp I422" for
YUV 4:2:2 (YV16) and use "-csp I444" for YUV 4:4:4 (YV24). Please note
that Avs2YUV can NOT pass through the "packed" YUY2 format. Thus it has
to be converted to the "planar" YV16 format. As both, YUY2 and YV16,
are YUV 4:2:2 formats, converting from YUY2 to YV16 is a lossless
operation. Note, however, that Avisynth 2.5 did NOT support YV16/YV24,
so you need to use Avisynth 2.6; otherwise Avs2YUV will fail to do the
conversion! Also be aware that the x264 encoder itself will convert any
YV16 or YV24 input back to the YV12 format, if you don't pass the
suitable "--output-csp i422/i444" switch to x264 as a custom parameter!
In short, to encode YUY2 from Avisynth, you have to pass "-csp I422" to
Avs2YUV and "--output-csp i422" to x264 to avoid 4:2:0 downsampling.


11. Audio Processing/Encoding
-----------------------------

This application is a front-end to the x264 encoder. And, as x264 does
NOT support audio processing/encoding yet, there is NO explicit support
for audio encoding in this application. Thus, if you want to create a
video file *with* audio, you will have to add the audio stream to the
encoded video file afterwards. This process is called 'multiplexing' or
just 'muxing'. In case you are dealing with Matroska (MKV) files, then
"MKVMerge GUI" from the "MKVToolNix" package is the right tool for this
task. If, instead, you are dealing with MP4 files, then you may use
"MP4Box" or the "YAMB" front-end for muxing the audio stream.

Having said all that, there now is an unofficial "Audio" branch of x264
available. If you are using one of the modified x264 builds with "audio
support" patch (e.g. those provided by JEEB), then you can process the
audio with x264 and skip the additional muxing step. Basically the
audio patch adds a new "--acodec" switch, which you can pass to x264 as
a custom parameter. For example, you can pass "--acodec aac" for
encoding the audio to the AAC format (recommended for MP4 files). Or
you can pass "--acodec vorbis" for encoding the audio to the Ogg/Vorbis
format (recommended for MKV files). Please be aware that audio encoding
will work only, if your input file contains an audio stream! When using
the built-in LAVF/FFMS input of x264, the audio can be encoded straight
from the input file. This does NOT work with Avisynth input! Instead,
if you want to encode audio from an Avisynth script, you must pass the
"--audiofile <path_to_avs_file>" switch to x264 as a custom parameter.
For convenience, the string "--audiofile $(INPUT)" may be used.


12. OpenCL Support
-----------------------

Newer builds of x264 now support OpenCL Lookahead, i.e. GPU accelerated
encoding. This can be enabled with the "--opencl" custom parameter. But
OpenCL Lookahead will only work if you have an OpenCL-capable graphics
card *and* if you have an up-to-date video driver installed!

Note that x264 will now *only* try to load the OpenCL.DLL if you really
use the "--opencl" option. Therefore, the "dummy" OpenCL.DLL included
in older versions of the Simple x264 Launcher is *NOT* needed anymore!!


13. Command-line Syntax
-----------------------

The following command-line switches are available:

--add <file> [<file>] ..... Create new job(s) from files(s)
--console ................. Show the "debug" console
--no-console .............. Don't show the "debug" console
--no-style ................ Don't use the Qt "Plastique" style
--skip-avisynth-check ..... Skip Avisynth check, disable .AVS input
--skip-vapoursynth-check .. Skip VapourSynth check, disables .VPY input
--force-cpu-no-64bit ...... Forcefully disable 64-Bit support
--no-deadlock-detection ... Don't abort processes on timeout/deadlock

PLEASE NOTE: These are parameters you can pass to Simple x264 Launcher,
they can *not* be passed to x264 itself as "custom" parameters!


14. Help & Support
------------------

For help and support, please join the discussion at:
http://forum.doom9.org/showthread.php?t=144140

Please do NOT send me e-mail with support requests. Thanks!


e.o.f.
