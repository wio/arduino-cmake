#=============================================================================#
# Original Author: Tomasz Bogdal (QueezyTheGreat)
# Current Author: Timor Gruber (MrPointer)
# Original Home: https://github.com/queezythegreat/arduino-cmake
# Current Home: https://github.com/arduino-cmake/arduino-cmake
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#=============================================================================#

cmake_minimum_required(VERSION 2.8.5)
include(CMakeParseArguments)

if (IS_SCRIPT_PROCESSED)
    return()
endif ()

#=============================================================================#
#                          User Functions
#=============================================================================#

#=============================================================================#
#                         Generation Functions
#=============================================================================#

#=============================================================================#
# GENERATE_ARDUINO_LIBRARY
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_LIBRARY INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"                  # Options
            "BOARD"                               # One Value Keywords
            "SRCS;HDRS;LIBS"                      # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    if (NOT INPUT_MANUAL)
        make_core_library(CORE_LIB ${INPUT_BOARD})
    endif ()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES)
    foreach (LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    if (NOT ${INPUT_NO_AUTOLIBS})
        make_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "" "${LIB_DEP_INCLUDES}" "")
    endif ()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    add_library(${INPUT_NAME} ${ALL_SRCS})

    set_board_flags(ARDUINO_COMPILE_FLAGS ARDUINO_LINK_FLAGS ${INPUT_BOARD} ${INPUT_MANUAL})

    set_target_properties(${INPUT_NAME} PROPERTIES
            COMPILE_FLAGS "${ARDUINO_COMPILE_FLAGS} ${COMPILE_FLAGS} ${LIB_DEP_INCLUDES}"
            LINK_FLAGS "${ARDUINO_LINK_FLAGS} ${LINK_FLAGS}")

    target_link_libraries(${INPUT_NAME} ${ALL_LIBS} "-lc -lm")
endfunction()

#=============================================================================#
# GENERATE_AVR_LIBRARY
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_AVR_LIBRARY INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"                  # Options
            "BOARD"                               # One Value Keywords
            "SRCS;HDRS;LIBS"                      # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()

    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    if (INPUT_HDRS)
        set(INPUT_HDRS "SRCS ${INPUT_HDRS}")
    endif ()
    if (INPUT_LIBS)
        set(INPUT_LIBS "LIBS ${INPUT_LIBS}")
    endif ()

    if (INPUT_HDRS)
        list(INSERT INPUT_HDRS 0 "HDRS")
    endif ()
    if (INPUT_LIBS)
        list(INSERT INPUT_LIBS 0 "LIBS")
    endif ()


    generate_arduino_library(${INPUT_NAME}
            NO_AUTOLIBS
            MANUAL
            BOARD ${INPUT_BOARD}
            SRCS ${INPUT_SRCS}
            ${INPUT_HDRS}
            ${INPUT_LIBS})

endfunction()

#=============================================================================#
# GENERATE_ARDUINO_FIRMWARE
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_FIRMWARE INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"                  # Options
            "BOARD;PORT;SKETCH;PROGRAMMER"        # One Value Keywords
            "SERIAL;SRCS;HDRS;LIBS;ARDLIBS;AFLAGS"  # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    if (NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})
    set(LIB_DEP_INCLUDES)

    if (NOT INPUT_MANUAL)
        make_core_library(CORE_LIB ${INPUT_BOARD})
    endif ()

    if (NOT "${INPUT_SKETCH}" STREQUAL "")
        get_filename_component(INPUT_SKETCH "${INPUT_SKETCH}" ABSOLUTE)
        make_arduino_sketch(${INPUT_NAME} ${INPUT_SKETCH} ALL_SRCS)
        if (IS_DIRECTORY "${INPUT_SKETCH}")
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${INPUT_SKETCH}\"")
        else ()
            get_filename_component(INPUT_SKETCH_PATH "${INPUT_SKETCH}" PATH)
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${INPUT_SKETCH_PATH}\"")
        endif ()
    endif ()

    VALIDATE_VARIABLES_NOT_EMPTY(VARS ALL_SRCS MSG "must define SRCS or SKETCH for target ${INPUT_NAME}")

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "${INPUT_ARDLIBS}")
    foreach (LIB_DEP ${TARGET_LIBS})
        arduino_debug_msg("Arduino Library: ${LIB_DEP}")
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    if (NOT INPUT_NO_AUTOLIBS)
        make_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "${TARGET_LIBS}" "${LIB_DEP_INCLUDES}" "")
        foreach (LIB_INCLUDES ${ALL_LIBS_INCLUDES})
            arduino_debug_msg("Arduino Library Includes: ${LIB_INCLUDES}")
            set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} ${LIB_INCLUDES}")
        endforeach ()
    endif ()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    create_arduino_firmware_target(${INPUT_NAME} ${INPUT_BOARD} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" "${INPUT_MANUAL}")

    if (INPUT_PORT)
        create_arduino_upload_target(${INPUT_BOARD} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        create_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()

endfunction()

#=============================================================================#
# GENERATE_AVR_FIRMWARE
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_AVR_FIRMWARE INPUT_NAME)
    # TODO: This is not optimal!!!!
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"            # Options
            "BOARD;PORT;PROGRAMMER"  # One Value Keywords
            "SERIAL;SRCS;HDRS;LIBS;AFLAGS"  # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()

    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_BOARD INPUT_SRCS MSG "must define for target ${INPUT_NAME}")

    if (INPUT_HDRS)
        list(INSERT INPUT_HDRS 0 "HDRS")
    endif ()
    if (INPUT_LIBS)
        list(INSERT INPUT_LIBS 0 "LIBS")
    endif ()
    if (INPUT_AFLAGS)
        list(INSERT INPUT_AFLAGS 0 "AFLAGS")
    endif ()

    generate_arduino_firmware(${INPUT_NAME}
            NO_AUTOLIBS
            MANUAL
            BOARD ${INPUT_BOARD}
            PORT ${INPUT_PORT}
            PROGRAMMER ${INPUT_PROGRAMMER}
            SERIAL ${INPUT_SERIAL}
            SRCS ${INPUT_SRCS}
            ${INPUT_HDRS}
            ${INPUT_LIBS}
            ${INPUT_AFLAGS})

endfunction()

#=============================================================================#
# GENERATE_ARDUINO_EXAMPLE
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_EXAMPLE INPUT_NAME)
    parse_generator_arguments(${INPUT_NAME} INPUT
            ""                                       # Options
            "CATEGORY;EXAMPLE;BOARD;PORT;PROGRAMMER"  # One Value Keywords
            "SERIAL;AFLAGS"                          # Multi Value Keywords
            ${ARGN})


    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_EXAMPLE INPUT_BOARD
            MSG "must define for target ${INPUT_NAME}")

    message(STATUS "Generating ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS)

    make_core_library(CORE_LIB ${INPUT_BOARD})

    make_arduino_example("${INPUT_NAME}" "${INPUT_EXAMPLE}" ALL_SRCS "${INPUT_CATEGORY}")

    if (NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif ()

    find_arduino_libraries(TARGET_LIBS "${ALL_SRCS}" "")
    set(LIB_DEP_INCLUDES)
    foreach (LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    make_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "" "${LIB_DEP_INCLUDES}" "")

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    create_arduino_firmware_target(${INPUT_NAME} ${INPUT_BOARD} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_DEP_INCLUDES}" "" FALSE)

    if (INPUT_PORT)
        create_arduino_upload_target(${INPUT_BOARD} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        create_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()
endfunction()

#=============================================================================#
# GENERATE_ARDUINO_LIBRARY_EXAMPLE
# [PUBLIC/USER]
# see documentation at top
#=============================================================================#
function(GENERATE_ARDUINO_LIBRARY_EXAMPLE INPUT_NAME)
    parse_generator_arguments(${INPUT_NAME} INPUT
            ""                                       # Options
            "LIBRARY;EXAMPLE;BOARD;PORT;PROGRAMMER"  # One Value Keywords
            "SERIAL;AFLAGS"                          # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_LIBRARY INPUT_EXAMPLE INPUT_BOARD
            MSG "must define for target ${INPUT_NAME}")

    message(STATUS "Generating ${INPUT_NAME}")

    set(ALL_LIBS)
    set(ALL_SRCS)

    make_core_library(CORE_LIB ${INPUT_BOARD})

    find_arduino_libraries(TARGET_LIBS "" "${INPUT_LIBRARY}")
    set(LIB_DEP_INCLUDES)
    foreach (LIB_DEP ${TARGET_LIBS})
        set(LIB_DEP_INCLUDES "${LIB_DEP_INCLUDES} -I\"${LIB_DEP}\"")
    endforeach ()

    make_arduino_library_example("${INPUT_NAME}" "${INPUT_LIBRARY}"
            "${INPUT_EXAMPLE}" ALL_SRCS)

    if (NOT ALL_SRCS)
        message(FATAL_ERROR "Missing sources for example, aborting!")
    endif ()

    make_arduino_libraries(ALL_LIBS ${INPUT_BOARD} "${ALL_SRCS}" "${TARGET_LIBS}"
            "${LIB_DEP_INCLUDES}" "")

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    create_arduino_firmware_target(${INPUT_NAME} ${INPUT_BOARD} "${ALL_SRCS}" "${ALL_LIBS}"
            "${LIB_DEP_INCLUDES}" "" FALSE)

    if (INPUT_PORT)
        create_arduino_upload_target(${INPUT_BOARD} ${INPUT_NAME} ${INPUT_PORT}
                "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        create_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()
endfunction()

# For known libraries can list recurse here
set(Wire_RECURSE True)
set(Ethernet_RECURSE True)
set(SD_RECURSE True)


#=============================================================================#
#                        Initialization Script
#=============================================================================#
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Initialization)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Extras)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core/BoardFlags)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core/Libraries)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core/Targets)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core/Sketch)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/Core/Examples)

include(VariableValidator)
include(Initializer)

include(Macros)
include(FlagsSetter)
include(SourceFinder)
include(LibraryFinder)
include(DebugOptions)
include(Printer)
include(GeneratorSettingsLoader)

include(ArduinoSketchToCppConverter)
include(ArduinoSketchFactory)

include(CoreLibraryFactory)
include(ArduinoLibraryFactory)

include(ArduinoExampleFactory)
include(ArduinoLibraryExampleFactory)

include(ArduinoBootloaderArgumentsBuilder)
include(ArduinoBootloaderBurnTargetCreator)
include(ArduinoBootloaderUploadTargetCreator)
include(ArduinoFirmwareTargetCreator)
include(ArduinoProgrammerArgumentsBuilder)
include(ArduinoProgrammerBurnTargetCreator)
include(ArduinoSerialTargetCreator)
include(ArduinoUploadTargetCreator)

set(IS_SCRIPT_PROCESSED True)
