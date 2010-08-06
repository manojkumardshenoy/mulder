include(admFFmpegUtil)

set(FFMPEG_VERSION 24666)	# http://git.ffmpeg.org/?p=ffmpeg;a=snapshot;h=64c439749fac9240ca3e267b84b1d83f588a9c06;sf=tgz
set(SWSCALE_VERSION 31906)	# http://git.ffmpeg.org/?p=libswscale;a=snapshot;h=233bcae1499042c80d2111bc76086302793029a9;sf=tgz

set(LIBRARY_SOURCE_DIR "${CMAKE_SOURCE_DIR}/avidemux/ADM_libraries")
set(FFMPEG_SOURCE_DIR "${LIBRARY_SOURCE_DIR}/ffmpeg")
set(FFMPEG_BINARY_DIR "${CMAKE_BINARY_DIR}/avidemux/ADM_libraries/ffmpeg")

set(FFMPEG_DECODERS  adpcm_ima_amv  amv  bmp  cinepak  cyuv  dca  dvbsub  dvvideo  ffv1  ffvhuff  flv  fraps  h263  h264  huffyuv  mjpeg
					 mjpegb  mpeg2video  mpeg4  msmpeg4v2  msmpeg4v3  msvideo1  nellymoser  png  qdm2  rawvideo  snow  svq3  theora  tscc
					 vc1  vp3  vp6  vp6a  vp6f  wmav2  wmv1  wmv2  wmv3)
set(FFMPEG_ENCODERS  ac3  dvvideo  ffv1  ffvhuff  flv  h263  huffyuv  mjpeg  mp2  mpeg1video  mpeg2video  mpeg4  snow)
set(FFMPEG_MUXERS  flv  matroska  mpeg1vcd  mpeg2dvd  mpeg2svcd  mpegts  mov  mp4  psp)
set(FFMPEG_PARSERS  ac3  h263  h264  mpeg4video)
set(FFMPEG_PROTOCOLS  file)
set(FFMPEG_FLAGS  --enable-shared --disable-static --disable-everything --enable-hwaccels --enable-postproc --enable-gpl 
				  --enable-runtime-cpudetect --disable-network --disable-ffplay --disable-ffprobe --prefix=${CMAKE_INSTALL_PREFIX})

include(admFFmpegPatch)
include(admFFmpegPrepareTar)

if (NOT FFMPEG_PREPARED)
	include(admFFmpegPrepareSvn)
endif (NOT FFMPEG_PREPARED)

if (NOT VERBOSE)
	set(ffmpegBuildOutput OUTPUT_VARIABLE FFMPEG_CONFIGURE_OUTPUT)
endif (NOT VERBOSE)

message("")

if (FFMPEG_PERFORM_PATCH)
	find_patch()
	file(GLOB patchFiles "${CMAKE_SOURCE_DIR}/cmake/patches/*.patch")

	foreach(patchFile ${patchFiles})
		patch_file("${FFMPEG_SOURCE_DIR}" "${patchFile}")
	endforeach(patchFile)

	if (UNIX)
		patch_file("${FFMPEG_SOURCE_DIR}" "${CMAKE_SOURCE_DIR}/cmake/patches/common.mak.diff")
	endif (UNIX)

	message("")
endif (FFMPEG_PERFORM_PATCH)

# Configure FFmpeg, if required
foreach (decoder ${FFMPEG_DECODERS})
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-decoder=${decoder})
endforeach (decoder)

foreach (encoder ${FFMPEG_ENCODERS})
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-encoder=${encoder})
endforeach (encoder)

foreach (muxer ${FFMPEG_MUXERS})
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-muxer=${muxer})
endforeach (muxer)

foreach (parser ${FFMPEG_PARSERS})
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-parser=${parser})
endforeach (parser)

foreach (protocol ${FFMPEG_PROTOCOLS})
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-protocol=${protocol})
endforeach (protocol)

if (WIN32)
	if (ADM_CPU_X86_32)
		set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-memalign-hack)
	endif (ADM_CPU_X86_32)

	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-w32threads)
else (WIN32)
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-pthreads)
endif (WIN32)

if (NOT ADM_DEBUG)
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --disable-debug)
endif (NOT ADM_DEBUG)

if (CMAKE_C_FLAGS)
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --extra-cflags=${CMAKE_C_FLAGS})
endif (CMAKE_C_FLAGS)

if (CMAKE_SHARED_LINKER_FLAGS)
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --extra-ldflags=${CMAKE_SHARED_LINKER_FLAGS})
endif (CMAKE_SHARED_LINKER_FLAGS)

if (CROSS_ARCH OR CROSS_OS)
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --enable-cross-compile)
endif (CROSS_ARCH OR CROSS_OS)

if (CROSS_ARCH)
	set(CROSS_ARCH "${CROSS_ARCH}" CACHE STRING "")
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --arch=${CROSS_ARCH})
endif (CROSS_ARCH)

if (CROSS_OS)
	set(CROSS_OS "${CROSS_OS}" CACHE STRING "")
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} --target-os=${CROSS_OS})
endif (CROSS_OS)

if (FF_FLAGS)
	set(FF_FLAGS "${FF_FLAGS}" CACHE STRING "")
	set(FFMPEG_FLAGS ${FFMPEG_FLAGS} ${FF_FLAGS})
endif (FF_FLAGS)

if (NOT "${LAST_FFMPEG_FLAGS}" STREQUAL "${FFMPEG_FLAGS}")
	set(FFMPEG_PERFORM_BUILD 1)
endif (NOT "${LAST_FFMPEG_FLAGS}" STREQUAL "${FFMPEG_FLAGS}")

if (NOT EXISTS "${FFMPEG_BINARY_DIR}/Makefile")
	set(FFMPEG_PERFORM_BUILD 1)
endif (NOT EXISTS "${FFMPEG_BINARY_DIR}/Makefile")

if (FFMPEG_PERFORM_BUILD)
	message(STATUS "Configuring FFmpeg")
	set(LAST_FFMPEG_FLAGS "${FFMPEG_FLAGS}" CACHE STRING "" FORCE)

	file(MAKE_DIRECTORY "${FFMPEG_BINARY_DIR}")
	file(REMOVE "${FFMPEG_BINARY_DIR}/ffmpeg${CMAKE_EXECUTABLE_SUFFIX}")
	file(REMOVE "${FFMPEG_BINARY_DIR}/ffmpeg_g${CMAKE_EXECUTABLE_SUFFIX}")

	execute_process(COMMAND sh ${FFMPEG_SOURCE_DIR}/configure ${FFMPEG_FLAGS}
					WORKING_DIRECTORY "${FFMPEG_BINARY_DIR}"
					${ffmpegBuildOutput})

	if (ADM_CPU_X86)
		file(READ ${FFMPEG_BINARY_DIR}/config.h FF_CONFIG_H)
		string(REGEX MATCH "#define[ ]+HAVE_YASM[ ]+1" FF_YASM "${FF_CONFIG_H}")

		if (NOT FF_YASM)
			message(FATAL_ERROR "Yasm was not found.")
		endif (NOT FF_YASM)

		if (WIN32)
			string(REGEX MATCH "#define[ ]+CONFIG_DXVA2[ ]+1" FF_DXVA2 "${FF_CONFIG_H}")
			
			if (NOT FF_DXVA2)
				message(FATAL_ERROR "DXVA2 not detected.  Ensure the dxva2api.h system header exists (available from Microsoft or http://downloads.videolan.org/pub/videolan/testing/contrib/dxva2api.h).")
			endif (NOT FF_DXVA2)
		endif (WIN32)
	endif (ADM_CPU_X86)

	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory "libavutil"
					WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/config")

	execute_process(COMMAND ${CMAKE_COMMAND} -E copy "./libavutil/avconfig.h" "${CMAKE_BINARY_DIR}/config/libavutil"
					WORKING_DIRECTORY "${FFMPEG_BINARY_DIR}")

	if (APPLE)
		find_patch()
		patch_file("${FFMPEG_BINARY_DIR}" "${CMAKE_SOURCE_DIR}/cmake/patches/config_macosx.mak.diff")
	elseif (UNIX)
		find_patch()
		patch_file("${FFMPEG_BINARY_DIR}" "${CMAKE_SOURCE_DIR}/cmake/patches/config.mak.diff")
	endif (APPLE)

	message("")
endif (FFMPEG_PERFORM_BUILD)

# Build FFmpeg
add_custom_command(OUTPUT "${FFMPEG_BINARY_DIR}/ffmpeg${CMAKE_EXECUTABLE_SUFFIX}"
				   COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TOOL=${CMAKE_BUILD_TOOL} -P "${CMAKE_SOURCE_DIR}/cmake/admFFmpegMake.cmake"
				   WORKING_DIRECTORY "${FFMPEG_BINARY_DIR}")

add_custom_target(ffmpeg ALL
				  DEPENDS "${FFMPEG_BINARY_DIR}/ffmpeg${CMAKE_EXECUTABLE_SUFFIX}")

# Add and install libraries
getFfmpegLibNames("${FFMPEG_SOURCE_DIR}")

if (WIN32)
	set(FFMPEG_INSTALL_DIR ${BIN_DIR})
else (WIN32)
	set(FFMPEG_INSTALL_DIR lib${LIB_SUFFIX})
endif (WIN32)

add_library(ADM_libswscale UNKNOWN IMPORTED)
set_property(TARGET ADM_libswscale PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libswscale/${LIBSWSCALE_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libswscale/${LIBSWSCALE_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

add_library(ADM_libpostproc UNKNOWN IMPORTED)
set_property(TARGET ADM_libpostproc PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libpostproc/${LIBPOSTPROC_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libpostproc/${LIBPOSTPROC_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

add_library(ADM_libavutil UNKNOWN IMPORTED)
set_property(TARGET ADM_libavutil PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libavutil/${LIBAVUTIL_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libavutil/${LIBAVUTIL_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

add_library(ADM_libavcodec UNKNOWN IMPORTED)
set_property(TARGET ADM_libavcodec PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libavcodec/${LIBAVCODEC_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libavcodec/${LIBAVCODEC_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

add_library(ADM_libavformat UNKNOWN IMPORTED)
set_property(TARGET ADM_libavformat PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libavformat/${LIBAVFORMAT_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libavformat/${LIBAVFORMAT_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

add_library(ADM_libavcore UNKNOWN IMPORTED)
set_property(TARGET ADM_libavcore PROPERTY IMPORTED_LOCATION "${FFMPEG_BINARY_DIR}/libavcore/${LIBAVCORE_LIB}")
install(FILES "${FFMPEG_BINARY_DIR}/libavcore/${LIBAVCORE_LIB}" DESTINATION "${FFMPEG_INSTALL_DIR}")

include_directories("${FFMPEG_SOURCE_DIR}")
include_directories("${FFMPEG_SOURCE_DIR}/libavutil")
include_directories("${FFMPEG_SOURCE_DIR}/libpostproc")

# Clean FFmpeg
add_custom_target(cleanffmpeg
				  COMMAND ${CMAKE_COMMAND} -P "${CMAKE_SOURCE_DIR}/cmake/admFFmpegClean.cmake"
				  WORKING_DIRECTORY "${FFMPEG_BINARY_DIR}"
				  COMMENT "Cleaning FFmpeg")
