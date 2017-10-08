#=============================================================================#
# detect_arduino_version
# [PRIVATE/INTERNAL]
#
# detect_arduino_version(OUTPUT_VAR_NAME)
#
#       OUTPUT_VAR_NAME - Variable name where the detected version will be saved
#
# Detects the Arduino SDK Version based on the revisions.txt file. The
# following variables will be generated:
#
#    ${OUTPUT_VAR_NAME}         -> the full version (major.minor.patch)
#    ${OUTPUT_VAR_NAME}_MAJOR   -> the major version
#    ${OUTPUT_VAR_NAME}_MINOR   -> the minor version
#    ${OUTPUT_VAR_NAME}_PATCH   -> the patch version
#
#=============================================================================#
function(detect_arduino_version OUTPUT_VAR_NAME)
    if (ARDUINO_VERSION_PATH)
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

            set(${OUTPUT_VAR_NAME} "${PARSED_VERSION}" PARENT_SCOPE)
            set(${OUTPUT_VAR_NAME}_MAJOR "${SPLIT_VERSION_MAJOR}" PARENT_SCOPE)
            set(${OUTPUT_VAR_NAME}_MINOR "${SPLIT_VERSION_MINOR}" PARENT_SCOPE)
            set(${OUTPUT_VAR_NAME}_PATCH "${SPLIT_VERSION_PATCH}" PARENT_SCOPE)
        endif ()
    endif ()
endfunction()