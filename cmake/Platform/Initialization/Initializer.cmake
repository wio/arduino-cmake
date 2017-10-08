include(${CMAKE_CURRENT_LIST_DIR}/CompilerSettings.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/ArduinoSettings.cmake)

#=============================================================================#
#                          Initialization
#=============================================================================#
setup_compiler_settings()
setup_arduino_settings()

if (NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)

    find_file(ARDUINO_VERSION_PATH
            NAMES lib/version.txt
            PATHS ${ARDUINO_SDK_PATH}
            DOC "Path to Arduino version file.")

    # get version first (some stuff depends on versions)
    include(${CMAKE_CURRENT_LIST_DIR}/DetectVersion.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/RegisterHardwarePlatform.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/FindPrograms.cmake)

    set(ARDUINO_DEFAULT_BOARD uno CACHE STRING "Default Arduino Board ID when not specified.")
    set(ARDUINO_DEFAULT_PORT CACHE STRING "Default Arduino port when not specified.")
    set(ARDUINO_DEFAULT_SERIAL CACHE STRING "Default Arduino Serial command when not specified.")
    set(ARDUINO_DEFAULT_PROGRAMMER CACHE STRING "Default Arduino Programmer ID when not specified.")

    # Ensure that all required paths are found
    required_variables(VARS
            ARDUINO_PLATFORMS
            ARDUINO_CORES_PATH
            ARDUINO_BOOTLOADERS_PATH
            ARDUINO_LIBRARIES_PATH
            ARDUINO_BOARDS_PATH
            ARDUINO_PROGRAMMERS_PATH
            ARDUINO_VERSION_PATH
            ARDUINO_AVRDUDE_FLAGS
            ARDUINO_AVRDUDE_PROGRAM
            ARDUINO_AVRDUDE_CONFIG_PATH
            AVRSIZE_PROGRAM
            ${ADDITIONAL_REQUIRED_VARS}
            MSG "Invalid Arduino SDK path (${ARDUINO_SDK_PATH}).\n")

    setup_arduino_size_script(ARDUINO_SIZE_SCRIPT)
    set(ARDUINO_SIZE_SCRIPT ${ARDUINO_SIZE_SCRIPT} CACHE INTERNAL "Arduino Size Script")

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")
    mark_as_advanced(
            ARDUINO_CORES_PATH
            ARDUINO_VARIANTS_PATH
            ARDUINO_BOOTLOADERS_PATH
            ARDUINO_LIBRARIES_PATH
            ARDUINO_BOARDS_PATH
            ARDUINO_PROGRAMMERS_PATH
            ARDUINO_VERSION_PATH
            ARDUINO_AVRDUDE_FLAGS
            ARDUINO_AVRDUDE_PROGRAM
            ARDUINO_AVRDUDE_CONFIG_PATH
            ARDUINO_OBJCOPY_EEP_FLAGS
            ARDUINO_OBJCOPY_HEX_FLAGS
            AVRSIZE_PROGRAM)
endif ()
