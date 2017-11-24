if (NOT PLATFORM_PATH)
    # Arduino is assumed as the default platform
    set(PLATFORM_PATH ${ARDUINO_SDK_PATH}/hardware/arduino/)
endif ()
string(REGEX REPLACE "/$" "" PLATFORM_PATH ${PLATFORM_PATH})
GET_FILENAME_COMPONENT(VENDOR_ID ${PLATFORM_PATH} NAME)
GET_FILENAME_COMPONENT(BASE_PATH ${PLATFORM_PATH} PATH)

if (NOT PLATFORM_ARCHITECTURE)
    # avr is the default architecture
    set(PLATFORM_ARCHITECTURE "avr")
endif ()

include(RegisterSpecificHardwarePlatform)
