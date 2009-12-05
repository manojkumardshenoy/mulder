LameXP - Audio Encoder Front-End
Copyright (C) 2004-2009 LoRd_MuldeR <MuldeR2@GMX.de>


1. Overview
--------------------------------------------------------------------------

LameXP is a graphical user-interface for a number of CLI audio encoders,
including LAME MP3, Vorbis (OggEnc2), FLAC and Nero's AAC encoder.

It was developed to support a huge number of input formats. File formats
are detected reliably using MediaInfo. Compressed audio formats are
decoded to uncompressed Wave files using suitable CLI audio decoders.

Furthermore LameXP allows batch processing of multiple audio files. Multi-
threading is implemented by processing several audio files concurrently.

All the third-party tools incorporated in LameXP are listed in the "About"
dialog. The Nero AAC encoder cannot be redistribited due to licensing
issues; it is availabel as a free download from the public Nero web-site.

Note: LameXP does NOT use/need any "external" audio decoders. It neither
requires nor supports any ACM Codecs or DirectShow/DMO filters!


2. Compile Instructions
--------------------------------------------------------------------------

LameXP is developed and tested under Borland Delphi 7 Professional. There
is absouletly NO guarantee that LameXP will compile under other versions
of the Delphi IDE. The Lazarus IDE is NOT offically supported either.

All code in LameXP was written to run under Microsoft Windows XP and Wine.
Some unique features of Windows 7 have been implemented and will be used
optionally. The Windows 9x series is not officially supported.

In order to compile LameXP the JEDI Visual Component Library is required:
http://jvcl.delphi-jedi.org/

Pre-compiled encoder binaries are kindly provided by Rarewares.org:
http://www.rarewares.org/

For discussion, help and support please visit Doom9's forum:
http://forum.doom9.org/showthread.php?t=119749



3. License
--------------------------------------------------------------------------

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
