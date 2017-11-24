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
        _get_normalized_sdk_version(NORMALIZED_SDK_VERSION)

        set_board_compiler_flags(COMPILE_FLAGS ${NORMALIZED_SDK_VERSION} ${BOARD_ID} ${IS_MANUAL})
        set_board_linker_flags(LINK_FLAGS ${BOARD_ID} ${IS_MANUAL})

        # output
        set(${COMPILER_FLAGS} "${COMPILE_FLAGS}" PARENT_SCOPE)
        set(${LINKER_FLAGS} "${LINK_FLAGS}" PARENT_SCOPE)

    else ()
        message(FATAL_ERROR "Invalid Arduino board ID (${BOARD_ID}), aborting.")
    endif ()

endfunction()

function(_get_normalized_sdk_version OUTPUT_VAR)

    set(CONCATENATED_VERSION "${ARDUINO_SDK_VERSION_MAJOR}")
    if (${ARDUINO_SDK_VERSION_MINOR} LESS 10)
        string(CONCAT CONCATENATED_VERSION "${CONCATENATED_VERSION}" "0")
    endif ()
    string(CONCAT CONCATENATED_VERSION "${CONCATENATED_VERSION}"
            "${ARDUINO_SDK_VERSION_MINOR}")
    string(CONCAT CONCATENATED_VERSION "${CONCATENATED_VERSION}"
            "${ARDUINO_SDK_VERSION_PATCH}")

    set(${OUTPUT_VAR} ${CONCATENATED_VERSION} PARENT_SCOPE)

endfunction()
