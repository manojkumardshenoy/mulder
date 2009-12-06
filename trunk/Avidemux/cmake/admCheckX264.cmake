MACRO(checkX264)
	IF (NOT X264_CHECKED)
		OPTION(X264 "" ON)

		MESSAGE(STATUS "Checking for x264")
		MESSAGE(STATUS "*****************")

		IF (X264)
			FIND_HEADER_AND_LIB(_X264 x264.h)

			IF (_X264_FOUND)
				FILE(READ ${_X264_INCLUDE_DIR}/x264.h X264_H)
				STRING(REGEX MATCH "#define[ ]+X264_BUILD[ ]+([0-9]+)" X264_H "${X264_H}")
				STRING(REGEX REPLACE ".*[ ]([0-9]+).*" "\\1" x264_version "${X264_H}")
				MESSAGE(STATUS "  core version: ${x264_version}")
				
				IF (x264_version LESS 67)
					MESSAGE("WARNING: x264 core version is too old.  At least version 67 is required.")
					SET(X264_FOUND 0)
				ELSEIF (x264_version GREATER 73)
					FIND_HEADER_AND_LIB(X264 x264.h x264 x264_encoder_open_${x264_version})
				ELSE (x264_version LESS 67)
					FIND_HEADER_AND_LIB(X264 x264.h x264 x264_encoder_open)
				ENDIF (x264_version LESS 67)
			ELSE (_X264_FOUND)
				SET(X264_FOUND 0)
			ENDIF (_X264_FOUND)

			PRINT_LIBRARY_INFO("x264" X264_FOUND "${X264_INCLUDE_DIR}" "${X264_LIBRARY_DIR}")
		ELSE (X264)
			MESSAGE("${MSG_DISABLE_OPTION}")
		ENDIF (X264)

		SET(ENV{ADM_HAVE_X264} ${X264_FOUND})
		SET(X264_CHECKED 1)

		MESSAGE("")
	ENDIF (NOT X264_CHECKED)
ENDMACRO(checkX264)
