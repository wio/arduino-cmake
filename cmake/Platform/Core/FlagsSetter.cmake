include(CompilerFlagsSetter)
include(LinkerFlagsSetter)

#=============================================================================#
# get_arduino_flags
# [PRIVATE/INTERNAL]
#
# get_arduino_flags(COMPILE_FLAGS LINK_FLAGS BOARD_ID IS_MANUAL)
#
#       COMPILER_FLAGS -Variable holding compiler flags
#       LINKER_FLAGS - Variable holding linker flags
#       BOARD_ID - The board id name
#       IS_MANUAL - (Advanced) Only use AVR Libc/Includes
#
# Configures the the build settings for the specified Arduino Board.
#
#=============================================================================#
function(set_board_flags COMPILER_FLAGS LINKER_FLAGS BOARD_ID IS_MANUAL)

    set(BOARD_CORE ${${BOARD_ID}.build.core})
    if (BOARD_CORE)
        is_sdk_version_valid(IS_VERSION_VALID)
        if (NOT ${IS_VERSION_VALID})
            return()
        endif ()

        set_board_compiler_flags(COMPILE_FLAGS ${BOARD_ID} ${IS_MANUAL})
        set_board_linker_flags(LINK_FLAGS ${BOARD_ID} ${IS_MANUAL})

        # output
        set(${COMPILER_FLAGS} "${COMPILE_FLAGS}" PARENT_SCOPE)
        set(${LINKER_FLAGS} "${LINK_FLAGS}" PARENT_SCOPE)

    else ()
        message(FATAL_ERROR "Invalid Arduino board ID (${BOARD_ID}), aborting.")
    endif ()

endfunction()

function(is_sdk_version_valid IS_VALID)

    if (ARDUINO_SDK_VERSION MATCHES "([0-9]+)[.]([0-9]+)")
        string(REPLACE "." "" ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION}") # Normalize version (remove all periods)
        set(ARDUINO_VERSION_DEFINE "")
        if (CMAKE_MATCH_1 GREATER 0)
            set(ARDUINO_VERSION_DEFINE "${CMAKE_MATCH_1}")
        endif ()
        if (CMAKE_MATCH_2 GREATER 10)
            set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}${CMAKE_MATCH_2}")
        else ()
            set(ARDUINO_VERSION_DEFINE "${ARDUINO_VERSION_DEFINE}0${CMAKE_MATCH_2}")
        endif ()
    else ()
        message(WARNING "Invalid Arduino SDK Version (${ARDUINO_SDK_VERSION})")
        set(${IS_VALID} False PARENT_SCOPE)
    endif ()

    set(${IS_VALID} True PARENT_SCOPE)

endfunction()
