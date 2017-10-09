#=============================================================================#
#                          Initialization
#=============================================================================#

include(CompilerSettings)
include(ArduinoSettings)

setup_compiler_settings()
setup_arduino_settings()

if (NOT ARDUINO_FOUND AND ARDUINO_SDK_PATH)
    find_file(ARDUINO_VERSION_PATH
            NAMES lib/version.txt
            PATHS ${ARDUINO_SDK_PATH}
            DOC "Path to Arduino version file.")

    # get version first (some stuff depends on versions)
    include(DetectVersion)
    include(RegisterHardwarePlatform)
    include(FindPrograms)
    include(SetDefaults)

    include(TestSetup)

    setup_arduino_size_script(ARDUINO_SIZE_SCRIPT)
    set(ARDUINO_SIZE_SCRIPT ${ARDUINO_SIZE_SCRIPT} CACHE INTERNAL "Arduino Size Script")

    set(ARDUINO_FOUND True CACHE INTERNAL "Arduino Found")

    include(DefineAdvancedVariables)
endif ()
