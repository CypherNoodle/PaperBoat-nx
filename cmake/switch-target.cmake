# Use with -DCMAKE_TOOLCHAIN_FILE=$DEVKITPRO/cmake/Switch.cmake.
if(NOT COMMAND nx_create_nro)
    message(FATAL_ERROR "Install devkitPro switch-cmake and configure with its Switch.cmake toolchain")
endif()

target_compile_options(${PROJECT_NAME} PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-Wno-incompatible-pointer-types>
    $<$<COMPILE_LANGUAGE:CXX>:-fpermissive>
)

# The game includes archive headers from libultraship.
target_link_libraries(${PROJECT_NAME} PRIVATE libzip::zip)
if(SWITCH_NXVK_ZINK)
    set(NXVK_SOURCE_DIR "" CACHE PATH "Pinned NXVK source tree for its newlib compatibility helpers")
    if(NOT EXISTS "${NXVK_SOURCE_DIR}/switch/smoke/nvk_compat.c")
        message(FATAL_ERROR "NXVK_SOURCE_DIR must point to the pinned NXVK source checkout")
    endif()
    target_sources(${PROJECT_NAME} PRIVATE "${NXVK_SOURCE_DIR}/switch/smoke/nvk_compat.c")
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME paperboat)
nx_generate_nacp(OUTPUT paperboat.nacp NAME "PaperBoat" AUTHOR "PaperBoat contributors"
    VERSION "${PROJECT_VERSION}")
nx_create_nro(${PROJECT_NAME} OUTPUT paperboat.nro NACP paperboat.nacp
    ICON "${CMAKE_SOURCE_DIR}/switch-icon.png")

# Keep the shader/font archive beside the executable on the SD card.
add_custom_target(switch-package
    COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/switch/paperboat"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_BINARY_DIR}/paperboat.nro" "${PAPERBOAT_PORT_O2R}"
        "${CMAKE_BINARY_DIR}/switch/paperboat/"
    DEPENDS ${PROJECT_NAME}_nro GeneratePortO2R
    VERBATIM
)
