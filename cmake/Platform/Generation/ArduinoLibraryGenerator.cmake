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
