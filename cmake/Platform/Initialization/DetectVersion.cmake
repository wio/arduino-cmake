#=============================================================================#
# Detects the Arduino SDK Version based on the revisions.txt file.
# The following variables will be generated:
#
#    ${OUTPUT_VAR_NAME}         -> the full version (major.minor.patch)
#    ${OUTPUT_VAR_NAME}_MAJOR   -> the major version
#    ${OUTPUT_VAR_NAME}_MINOR   -> the minor version
#    ${OUTPUT_VAR_NAME}_PATCH   -> the patch version
#
#=============================================================================#
if (NOT ARDUINO_VERSION_PATH)
    return()
endif ()

file(READ ${ARDUINO_VERSION_PATH} RAW_VERSION)
if ("${RAW_VERSION}" MATCHES " *[0]+([0-9]+)")
    set(PARSED_VERSION 0.${CMAKE_MATCH_1}.0)
elseif ("${RAW_VERSION}" MATCHES "[ ]*([0-9]+[.][0-9]+[.][0-9]+)")
    set(PARSED_VERSION ${CMAKE_MATCH_1})
elseif ("${RAW_VERSION}" MATCHES "[ ]*([0-9]+[.][0-9]+)")
    set(PARSED_VERSION ${CMAKE_MATCH_1}.0)
endif ()

if (NOT PARSED_VERSION STREQUAL "")
    string(REPLACE "." ";" SPLIT_VERSION ${PARSED_VERSION})
    list(GET SPLIT_VERSION 0 SPLIT_VERSION_MAJOR)
    list(GET SPLIT_VERSION 1 SPLIT_VERSION_MINOR)
    list(GET SPLIT_VERSION 2 SPLIT_VERSION_PATCH)

    set(ARDUINO_SDK_VERSION "${PARSED_VERSION}" CACHE STRING "Arduino SDK Version")
    set(ARDUINO_SDK_VERSION_MAJOR ${ARDUINO_SDK_VERSION_MAJOR} CACHE STRING "Arduino SDK Major Version")
    set(ARDUINO_SDK_VERSION_MINOR ${ARDUINO_SDK_VERSION_MINOR} CACHE STRING "Arduino SDK Minor Version")
    set(ARDUINO_SDK_VERSION_PATCH ${ARDUINO_SDK_VERSION_PATCH} CACHE STRING "Arduino SDK Patch Version")
endif ()

if (ARDUINO_SDK_VERSION VERSION_LESS 0.19)
    message(FATAL_ERROR "Unsupported Arduino SDK (requires version 0.19 or higher)")
endif ()

message(STATUS "Arduino SDK version ${ARDUINO_SDK_VERSION}: ${ARDUINO_SDK_PATH}")
