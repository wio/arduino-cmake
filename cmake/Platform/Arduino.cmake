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


#=============================================================================#
#                           Other Functions
#=============================================================================#


#=============================================================================#
#                         Internal Functions
#=============================================================================#

#=============================================================================#
#                              Macros
#=============================================================================#

#=============================================================================#
# parse_generator_arguments
# [PRIVATE/INTERNAL]
#
# parse_generator_arguments(TARGET_NAME PREFIX OPTIONS ARGS MULTI_ARGS [ARG1 ARG2 .. ARGN])
#
#         PREFIX     - Parsed options prefix
#         OPTIONS    - List of options
#         ARGS       - List of one value keyword arguments
#         MULTI_ARGS - List of multi value keyword arguments
#         [ARG1 ARG2 .. ARGN] - command arguments [optional]
#
# Parses generator options from either variables or command arguments
#
#=============================================================================#
macro(PARSE_GENERATOR_ARGUMENTS TARGET_NAME PREFIX OPTIONS ARGS MULTI_ARGS)
    cmake_parse_arguments(${PREFIX} "${OPTIONS}" "${ARGS}" "${MULTI_ARGS}" ${ARGN})
    error_for_unparsed(${PREFIX})
    load_generator_settings(${TARGET_NAME} ${PREFIX} ${OPTIONS} ${ARGS} ${MULTI_ARGS})
endmacro()

#=============================================================================#
# get_mcu
# [PRIVATE/INTERNAL]
#
# get_mcu(FULL_MCU_NAME, OUTPUT_VAR)
#
#         FULL_MCU_NAME - Board's full mcu name, including a trailing 'p' if present
#         OUTPUT_VAR - String value in which a regex match will be stored
#
# Matches the board's mcu without leading or trailing characters that would rather mess
# further processing that requires the board's mcu.
#
#=============================================================================#
macro(GET_MCU FULL_MCU_NAME OUTPUT_VAR)
    string(REGEX MATCH "^.+[^p]" ${OUTPUT_VAR} "FULL_MCU_NAME" PARENT_SCOPE)
endmacro()

#=============================================================================#
# increment_example_category_index
# [PRIVATE/INTERNAL]
#
# increment_example_category_index(OUTPUT_VAR)
#
#         OUTPUT_VAR - A number representing an example's category prefix
#
# Increments the given number by one, taking into consideration the number notation
# which is defined (Some SDK's or OSs use a leading '0' in single-digit numbers.
#
#=============================================================================#
macro(INCREMENT_EXAMPLE_CATEGORY_INDEX OUTPUT_VAR)
    math(EXPR INC_INDEX "${${OUTPUT_VAR}}+1")
    if (EXAMPLE_CATEGORY_INDEX_LENGTH GREATER 1 AND INC_INDEX LESS 10)
        set(${OUTPUT_VAR} "0${INC_INDEX}")
    else ()
        set(${OUTPUT_VAR} ${INC_INDEX})
    endif ()
endmacro()


#=============================================================================#
#                           Load Functions
#=============================================================================#

#=============================================================================#
# load_generator_settings
# [PRIVATE/INTERNAL]
#
# load_generator_settings(TARGET_NAME PREFIX [SUFFIX_1 SUFFIX_2 .. SUFFIX_N])
#
#         TARGET_NAME - The base name of the user settings
#         PREFIX      - The prefix name used for generator settings
#         SUFFIX_XX   - List of suffixes to load
#
#  Loads a list of user settings into the generators scope. User settings have
#  the following syntax:
#
#      ${BASE_NAME}${SUFFIX}
#
#  The BASE_NAME is the target name and the suffix is a specific generator settings.
#
#  For every user setting found a generator setting is created of the follwoing fromat:
#
#      ${PREFIX}${SUFFIX}
#
#  The purpose of loading the settings into the generator is to not modify user settings
#  and to have a generic naming of the settings within the generator.
#
#=============================================================================#
function(LOAD_GENERATOR_SETTINGS TARGET_NAME PREFIX)
    foreach (GEN_SUFFIX ${ARGN})
        if (${TARGET_NAME}_${GEN_SUFFIX} AND NOT ${PREFIX}_${GEN_SUFFIX})
            set(${PREFIX}_${GEN_SUFFIX} ${${TARGET_NAME}_${GEN_SUFFIX}} PARENT_SCOPE)
        endif ()
    endforeach ()
endfunction()


#=============================================================================#
#                          Setup Functions
#=============================================================================#


#=============================================================================#
#                          Find Functions
#=============================================================================#

#=============================================================================#
# find_arduino_libraries
# [PRIVATE/INTERNAL]
#
# find_arduino_libraries(VAR_NAME SRCS ARDLIBS)
#
#      VAR_NAME - Variable name which will hold the results
#      SRCS     - Sources that will be analized
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
#
#  Also adds Arduino libraries specifically names in ALIBS.  We add ".h" to the
#  names and then process them just like the Arduino libraries found in the sources.
#
#  A Arduino library is a folder that has the same name as the include header.
#  For example, if we have a include "#include <LibraryName.h>" then the following
#  directory structure is considered a Arduino library:
#
#     LibraryName/
#          |- LibraryName.h
#          `- LibraryName.c
#
#  If such a directory is found then all sources within that directory are considred
#  to be part of that Arduino library.
#
#=============================================================================#
function(find_arduino_libraries VAR_NAME SRCS ARDLIBS)
    set(ARDUINO_LIBS)

    if (ARDLIBS) # Libraries are known in advance, just find their absoltue paths

        foreach (LIB ${ARDLIBS})
            get_property(LIBRARY_SEARCH_PATH
                    DIRECTORY     # Property Scope
                    PROPERTY LINK_DIRECTORIES)

            foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH}
                    ${ARDUINO_LIBRARIES_PATH}
                    ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/libraries)

                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}/${LIB}.h)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${LIB})
                    break()
                endif ()
                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}.h)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH})
                    break()
                endif ()

                # Some libraries like Wire and SPI require building from source
                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}/src/${LIB}.h)
                    message(STATUS "avr library found: ${LIB}")
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${LIB}/src)
                    break()
                endif ()
                if (EXISTS ${LIB_SEARCH_PATH}/src/${LIB}.h)
                    list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/src)
                    break()
                endif ()

            endforeach ()
        endforeach ()

    else ()

        foreach (SRC ${SRCS})

            # Skipping generated files. They are, probably, not exist yet.
            # TODO: Maybe it's possible to skip only really nonexisting files,
            # but then it wiil be less deterministic.
            get_source_file_property(_srcfile_generated ${SRC} GENERATED)
            # Workaround for sketches, which are marked as generated
            get_source_file_property(_sketch_generated ${SRC} GENERATED_SKETCH)

            if (NOT ${_srcfile_generated} OR ${_sketch_generated})
                if (NOT (EXISTS ${SRC} OR
                        EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SRC} OR
                        EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${SRC}))
                    message(FATAL_ERROR "Invalid source file: ${SRC}")
                endif ()
                file(STRINGS ${SRC} SRC_CONTENTS)

                foreach (LIBNAME ${ARDLIBS})
                    list(APPEND SRC_CONTENTS "#include <${LIBNAME}.h>")
                endforeach ()

                foreach (SRC_LINE ${SRC_CONTENTS})
                    if ("${SRC_LINE}" MATCHES
                            "^[ \t]*#[ \t]*include[ \t]*[<\"]([^>\"]*)[>\"]")

                        get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                        get_property(LIBRARY_SEARCH_PATH
                                DIRECTORY     # Property Scope
                                PROPERTY LINK_DIRECTORIES)
                        foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries ${ARDUINO_EXTRA_LIBRARIES_PATH})
                            if (EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                                break()
                            endif ()
                            if (EXISTS ${LIB_SEARCH_PATH}/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH})
                                break()
                            endif ()

                            # Some libraries like Wire and SPI require building from source
                            if (EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src)
                                break()
                            endif ()
                            if (EXISTS ${LIB_SEARCH_PATH}/src/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS ${LIB_SEARCH_PATH}/src)
                                break()
                            endif ()
                        endforeach ()

                    endif ()
                endforeach ()

            endif ()
        endforeach ()

    endif ()

    if (ARDUINO_LIBS)
        list(REMOVE_DUPLICATES ARDUINO_LIBS)
    endif ()
    set(${VAR_NAME} ${ARDUINO_LIBS} PARENT_SCOPE)
endfunction()

#=============================================================================#
# find_sources
# [PRIVATE/INTERNAL]
#
# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ sources located at the specified path.
#
#=============================================================================#
function(find_sources VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.cpp
            ${LIB_PATH}/*.c
            ${LIB_PATH}/*.s
            ${LIB_PATH}/*.S
            ${LIB_PATH}/*.cc
            ${LIB_PATH}/*.cxx
            ${LIB_PATH}/*.h
            ${LIB_PATH}/*.hh
            ${LIB_PATH}/*.hxx)

    if (RECURSE)
        file(GLOB_RECURSE LIB_FILES ${FILE_SEARCH_LIST})
    else ()
        file(GLOB LIB_FILES ${FILE_SEARCH_LIST})
    endif ()

    if (LIB_FILES)
        set(${VAR_NAME} ${LIB_FILES} PARENT_SCOPE)
    endif ()
endfunction()

#=============================================================================#
# find_prototypes
# [PRIVATE/INTERNAL]
#
# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        SEARCH_SOURCES - List of source files to search prototypes in
#        OUTPUT_VAR - Output variable that will contain the list of found prototypes
#
# Find all function prototypes in the given source files
#
#=============================================================================#
function(find_prototypes SEARCH_SOURCES OUTPUT_VAR)

    if (ARGC GREATER 2)
        list(GET ARGN 0 PROTOTYPE_PATTERN)
    else ()
        set(ALPHA "a-zA-Z")
        set(NUM "0-9")
        set(ALPHANUM "${ALPHA}${NUM}")
        set(WORD "_${ALPHANUM}")
        set(LINE_START "(^|[\n])")
        set(QUALIFIERS "[ \t]*([${ALPHA}]+[ ])*")
        set(TYPE "[${WORD}]+([ ]*[\n][\t]*|[ ])+")
        set(FNAME "[${WORD}]+[ ]?[\n]?[\t]*[ ]*")
        set(FARGS "[(]([\t]*[ ]*[*&]?[ ]?[${WORD}](\\[([${NUM}]+)?\\])*[,]?[ ]*[\n]?)*([,]?[ ]*[\n]?)?[)]")
        set(BODY_START "([ ]*[\n][\t]*|[ ]|[\n])*{")
        set(PROTOTYPE_PATTERN "${LINE_START}${QUALIFIERS}${TYPE}${FNAME}${FARGS}${BODY_START}")
    endif ()

    find_sources(SEARCH_SOURCES ${SEARCH_SOURCES} False)
    foreach (SOURCE ${SEARCH_SOURCES})
        ARDUINO_DEBUG_MSG("Prototype search source: ${SOURCE}")
        file(READ ${SOURCE} SOURCE)
        remove_comments(SOURCE SOURCE)
        string(REGEX MATCHALL ${PROTOTYPE_PATTERN} SOURCE_PROTOTYPES ${SOURCE})
        ARDUINO_DEBUG_MSG("Prototypes: ${SOURCE_PROTOTYPES}")
        foreach (PROTOTYPE ${SOURCE_PROTOTYPES})
            string(REPLACE "\n" " " SKETCH_PROTOTYPE "${SKETCH_PROTOTYPE}")
            string(REPLACE "{" "" SKETCH_PROTOTYPE "${SKETCH_PROTOTYPE}")
            # " else if(var == other) {" shoudn't be listed as prototype
            if (NOT SKETCH_PROTOTYPE MATCHES "(if[ ]?[\n]?[\t]*[ ]*[)])")
                list(APPEND PROTOTYPES "${SKETCH_PROTOTYPE}")
            else ()
                arduino_debug_msg("\trejected prototype: ${PROTOTYPE};")
            endif ()
        endforeach ()
    endforeach ()

    list(REMOVE_DUPLICATES PROTOTYPES)
    set(${OUTPUT_VAR} ${PROTOTYPES} PARENT_SCOPE)

endfunction()


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
include(FlagsSetter)
include(DebugOptions)
include(Printer)

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