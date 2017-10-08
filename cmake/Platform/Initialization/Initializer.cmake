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
    include(${CMAKE_CURRENT_LIST_DIR}/SetDefaults.cmake)

    include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

    setup_arduino_size_script(ARDUINO_SIZE_SCRIPT)
    set(ARDUINO_SIZE_SCRIPT ${ARDUINO_SIZE_SCRIPT} CACHE INTERNAL "Arduino Size Script")

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")

    include(${CMAKE_CURRENT_LIST_DIR}/DefineAdvancedVariables.cmake)
endif ()
