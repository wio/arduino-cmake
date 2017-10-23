#=============================================================================#
# build_arduino_bootloader_arguments
# [PRIVATE/INTERNAL]
#
# build_arduino_bootloader_arguments(BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
#
#      BOARD_ID    - board id
#      TARGET_NAME - target name
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#      OUTPUT_VAR  - name of output variable for result
#
# Sets up default avrdude settings for uploading firmware via the bootloader.
#=============================================================================#
function(build_arduino_bootloader_arguments BOARD_ID TARGET_NAME PORT AVRDUDE_FLAGS OUTPUT_VAR)
    set(AVRDUDE_ARGS ${${OUTPUT_VAR}})

    if (NOT AVRDUDE_FLAGS)
        set(AVRDUDE_FLAGS ${ARDUINO_AVRDUDE_FLAGS})
    endif ()

    list(APPEND AVRDUDE_ARGS
            "-C${ARDUINO_AVRDUDE_CONFIG_PATH}"  # avrdude config
            "-p${${BOARD_ID}.build.mcu}"        # MCU Type
            )

    # Programmer
    if (NOT ${BOARD_ID}.upload.protocol OR ${BOARD_ID}.upload.protocol STREQUAL "stk500")
        list(APPEND AVRDUDE_ARGS "-cstk500v1")
    else ()
        list(APPEND AVRDUDE_ARGS "-c${${BOARD_ID}.upload.protocol}")
    endif ()

    set(UPLOAD_SPEED "19200") # Set a default speed
    if (${BOARD_ID}.upload.speed)
        set(UPLOAD_SPEED ${${BOARD_ID}.upload.speed})
    else ()
        # Speed wasn't manually set, and is not defined in the simple board settings
        # The only option left is to search in the 'menu' settings of the Arduino 1.6 SDK
        list(FIND ${BOARD_ID}.SETTINGS menu MENU_SETTINGS)
        # Determine upload speed based on the defined cpu architecture (mcu)
        if (${BOARD_ID}.build.mcu)
            GET_MCU(${${BOARD_ID}.build.mcu} BOARD_MCU)
            list(FIND ${BOARD_ID}.menu.CPUS ${BOARD_MCU} BOARD_MCU_INDEX)
            if (BOARD_MCU_INDEX GREATER -1) # Matching mcu is found
                set(UPLOAD_SPEED ${${BOARD_ID}.menu.cpu.${BOARD_MCU}.upload.speed})
            endif ()
        endif ()
    endif ()

    list(APPEND AVRDUDE_ARGS
            "-b${UPLOAD_SPEED}"     # Baud rate
            "-P${PORT}"             # Serial port
            "-D"                    # Dont erase
            )

    list(APPEND AVRDUDE_ARGS ${AVRDUDE_FLAGS})

    set(${OUTPUT_VAR} ${AVRDUDE_ARGS} PARENT_SCOPE)

endfunction()