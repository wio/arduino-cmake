#=============================================================================#
# create_arduino_bootloader_burn_target
# [PRIVATE/INTERNAL]
#
# create_arduino_bootloader_burn_target(TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
#
#      TARGET_NAME - name of target to burn
#      BOARD_ID    - board id
#      PROGRAMMER  - programmer id
#      PORT        - serial port
#      AVRDUDE_FLAGS - avrdude flags (override)
#
# Create a target for burning a bootloader via a programmer.
#
# The target for burning the bootloader is ${TARGET_NAME}-burn-bootloader
#
#=============================================================================#
function(create_arduino_bootloader_burn_target TARGET_NAME BOARD_ID PROGRAMMER PORT AVRDUDE_FLAGS)
    set(BOOTLOADER_TARGET ${TARGET_NAME}-burn-bootloader)

    set(AVRDUDE_ARGS)

    build_arduino_programmer_arguments(${BOARD_ID} ${PROGRAMMER} ${TARGET_NAME} ${PORT} "${AVRDUDE_FLAGS}" AVRDUDE_ARGS)

    if (NOT AVRDUDE_ARGS)
        message("Could not generate default avrdude programmer args, aborting!")
        return()
    endif ()

    # look at bootloader.file
    set(BOOTLOADER_FOUND True)
    if (NOT ${BOARD_ID}.bootloader.file)
        set(BOOTLOADER_FOUND False)
        # Bootloader is probably defined in the 'menu' settings of the Arduino 1.6 SDK
        if (${BOARD_ID}.build.mcu)
            GET_MCU(${${BOARD_ID}.build.mcu} BOARD_MCU)
            if (NOT ${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.file)
                message("Missing ${BOARD_ID}.bootloader.file, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
                return()
            endif ()
            set(BOOTLOADER_FOUND True)
            set(${BOARD_ID}.bootloader.file ${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.file)
        endif ()
    endif ()

    if (NOT ${BOOTLOADER_FOUND})
        return()
    endif ()

    # build bootloader.path from bootloader.file...
    string(REGEX MATCH "(.+/)*" ${BOARD_ID}.bootloader.path ${${BOARD_ID}.bootloader.file})
    string(REGEX REPLACE "/" "" ${BOARD_ID}.bootloader.path ${${BOARD_ID}.bootloader.path})
    # and fix bootloader.file
    string(REGEX MATCH "/.(.+)$" ${BOARD_ID}.bootloader.file ${${BOARD_ID}.bootloader.file})
    string(REGEX REPLACE "/" "" ${BOARD_ID}.bootloader.file ${${BOARD_ID}.bootloader.file})

    foreach (ITEM unlock_bits high_fuses low_fuses path file)
        if (NOT ${BOARD_ID}.bootloader.${ITEM})
            # Try the 'menu' settings of the Arduino 1.6 SDK
            if (NOT ${BOARD_ID}.menu.cpu.{BOARD_MCU}.bootloader.${ITEM})
                message("Missing ${BOARD_ID}.bootloader.${ITEM}, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
                return()
            endif ()
        endif ()
    endforeach ()

    if (NOT EXISTS "${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}.bootloader.file}")
        message("${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}/${${BOARD_ID}.bootloader.file}")
        message("Missing bootloader image, not creating bootloader burn target ${BOOTLOADER_TARGET}.")
        return()
    endif ()

    # Erase the chip
    list(APPEND AVRDUDE_ARGS "-e")

    # Set unlock bits and fuses (because chip is going to be erased)

    if (${BOARD_ID}.bootloader.unlock_bits)
        list(APPEND AVRDUDE_ARGS "-Ulock:w:${${BOARD_ID}.bootloader.unlock_bits}:m")
    else ()
        # Arduino 1.6 SDK
        list(APPEND AVRDUDE_ARGS
                "-Ulock:w:${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.unlock_bits}:m")
    endif ()

    if (${BOARD_ID}.bootloader.extended_fuses)
        list(APPEND AVRDUDE_ARGS "-Uefuse:w:${${BOARD_ID}.bootloader.extended_fuses}:m")
    elseif (${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.extended_fuses})
        list(APPEND AVRDUDE_ARGS
                "-Uefuse:w:${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.extended_fuses}:m")
    endif ()
    if (${BOARD_ID}.bootloader.high_fuses)
        list(APPEND AVRDUDE_ARGS
                "-Uhfuse:w:${${BOARD_ID}.bootloader.high_fuses}:m"
                "-Ulfuse:w:${${BOARD_ID}.bootloader.low_fuses}:m")
    else ()
        list(APPEND AVRDUDE_ARGS
                "-Uhfuse:w:${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.high_fuses}:m"
                "-Ulfuse:w:${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.low_fuses}:m")
    endif ()

    # Set bootloader image
    list(APPEND AVRDUDE_ARGS "-Uflash:w:${${BOARD_ID}.bootloader.file}:i")

    # Set lockbits
    if (${BOARD_ID}.bootloader.lock_bits)
        list(APPEND AVRDUDE_ARGS "-Ulock:w:${${BOARD_ID}.bootloader.lock_bits}:m")
    else ()
        list(APPEND AVRDUDE_ARGS
                "-Ulock:w:${${BOARD_ID}.menu.cpu.${BOARD_MCU}.bootloader.lock_bits}:m")
    endif ()


    # Create burn bootloader target
    add_custom_target(${BOOTLOADER_TARGET}
            ${ARDUINO_AVRDUDE_PROGRAM}
            ${AVRDUDE_ARGS}
            WORKING_DIRECTORY ${ARDUINO_BOOTLOADERS_PATH}/${${BOARD_ID}.bootloader.path}
            DEPENDS ${TARGET_NAME})
endfunction()
