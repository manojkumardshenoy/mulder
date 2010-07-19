IF (WIN32)
	SET(AUDDEV_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/plugins/audioDevices/")
ELSE (WIN32)
	SET(AUDDEV_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}/ADM_plugins/audioDevices/")
ENDIF (WIN32)

MACRO(INIT_AUDIO_DEVICE _lib)
	INCLUDE_DIRECTORIES("${AVIDEMUX_SOURCE_DIR}/avidemux/ADM_core/include")
	INCLUDE_DIRECTORIES("${AVIDEMUX_SOURCE_DIR}/avidemux/ADM_coreAudio/include")
	INCLUDE_DIRECTORIES("${AVIDEMUX_SOURCE_DIR}/avidemux/ADM_audiodevice/")
ENDMACRO(INIT_AUDIO_DEVICE)

MACRO(INSTALL_AUDIODEVICE _lib)
	INSTALL(TARGETS ${_lib} DESTINATION "${AUDDEV_INSTALL_DIR}")
ENDMACRO(INSTALL_AUDIODEVICE)