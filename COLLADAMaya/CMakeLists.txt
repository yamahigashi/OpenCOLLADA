# CMakeLists.txt for COLLADAMaya plugin

cmake_minimum_required(VERSION 3.5)
project(COLLADAMaya)

# Options
option(BUILD_MAYA_PLUGIN "Build the COLLADAMaya plugin" ON)
option(BUILD_MAYA_CONSOLE "Build the COLLADAMaya console application" OFF)
option(ENABLE_CGFX_SUPPORT "Enable CgFx shader support (requires GLEW)" OFF)
option(ENABLE_DAE2MA_IMPORT "Enable COLLADA import support using dae2ma" ON)

# Set Maya version
if(NOT MAYA_VERSION)
    set(MAYA_VERSION "2024" CACHE STRING "Maya version to build for")
endif()

# Add cmake module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Find Maya
find_package(Maya REQUIRED)

if(NOT MAYA_FOUND)
    message(FATAL_ERROR "Maya ${MAYA_VERSION} not found. Please set MAYA_INSTALL_BASE_PATH or MAYA_LOCATION environment variable.")
endif()

# Source files
set(COLLADAMAYA_SOURCES
    src/COLLADAMayaAnimationClipExporter.cpp
    src/COLLADAMayaAnimationCurves.cpp
    src/COLLADAMayaAnimationElement.cpp
    src/COLLADAMayaAnimationExporter.cpp
    src/COLLADAMayaAnimationHelper.cpp
    src/COLLADAMayaAnimationKeys.cpp
    src/COLLADAMayaAnimationSampleCache.cpp
    src/COLLADAMayaAnimationTools.cpp
    src/COLLADAMayaAttributeParser.cpp
    src/COLLADAMayaCameraExporter.cpp
    src/COLLADAMayaControllerExporter.cpp
    src/COLLADAMayaDagHelper.cpp
    src/COLLADAMayaDocumentExporter.cpp
    src/COLLADAMayaEffectExporter.cpp
    src/COLLADAMayaEffectTextureExporter.cpp
    src/COLLADAMayaExportOptions.cpp
    src/COLLADAMayaFileTranslator.cpp
    src/COLLADAMayaGeometryExporter.cpp
    src/COLLADAMayaGeometryPolygonExporter.cpp
    src/COLLADAMayaHwShaderExporter.cpp
    src/COLLADAMayaImageExporter.cpp
    src/COLLADAMayaImportOptions.cpp
    src/COLLADAMayaLightExporter.cpp
    src/COLLADAMayaLightProbeExporter.cpp
    src/COLLADAMayaLODExporter.cpp
    src/COLLADAMayaMaterialExporter.cpp
    src/COLLADAMayaPhysicsExporter.cpp
    src/COLLADAMayaPhysicsSceneExporter.cpp
    src/COLLADAMayaPhysXExporter.cpp
    src/COLLADAMayaPhysXXML.cpp
    src/COLLADAMayaPrecompiledHeaders.cpp
    src/COLLADAMayaReferenceManager.cpp
    src/COLLADAMayaRotateHelper.cpp
    src/COLLADAMayaSceneElement.cpp
    src/COLLADAMayaSceneGraph.cpp
    src/COLLADAMayaSetHelper.cpp
    src/COLLADAMayaShaderFXShaderExporter.cpp
    src/COLLADAMayaShaderHelper.cpp
    src/COLLADAMayaSourceInput.cpp
    src/COLLADAMayaVisualSceneExporter.cpp
)

# Check for GLEW if CgFx support is requested
if(ENABLE_CGFX_SUPPORT)
    find_path(GLEW_INCLUDE_DIR GL/glew.h
        PATHS
            ${CMAKE_SOURCE_DIR}/Externals/glew/include
            ${MAYA_LOCATION}/include
            ${MAYA_LOCATION}/devkit/include
            $ENV{GLEW_ROOT}/include
            /usr/include
            /usr/local/include
    )
    
    if(GLEW_INCLUDE_DIR)
        list(APPEND COLLADAMAYA_SOURCES src/COLLADAMayaCgfxShaderIncludes.cpp)
        list(APPEND COLLADAMAYA_INCLUDE_DIRS ${GLEW_INCLUDE_DIR})
        add_definitions(-DCOLLADA_MAYA_CGFX_ENABLED)
        message(STATUS "CgFx support enabled with GLEW at: ${GLEW_INCLUDE_DIR}")
    else()
        message(WARNING "GLEW not found. CgFx shader support will be disabled.")
        message(WARNING "To enable CgFx support, install GLEW or set GLEW_ROOT environment variable.")
        set(ENABLE_CGFX_SUPPORT OFF CACHE BOOL "Enable CgFx shader support (requires GLEW)" FORCE)
    endif()
endif()

# Include directories
set(COLLADAMAYA_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${MAYA_INCLUDE_DIR}
    ${CMAKE_SOURCE_DIR}/COLLADABaseUtils/include
    ${CMAKE_SOURCE_DIR}/COLLADAFramework/include
    ${CMAKE_SOURCE_DIR}/COLLADASaxFrameworkLoader/include
    ${CMAKE_SOURCE_DIR}/COLLADASaxFrameworkLoader/include/generated15
    ${CMAKE_SOURCE_DIR}/COLLADAStreamWriter/include
    ${CMAKE_SOURCE_DIR}/GeneratedSaxParser/include
    ${CMAKE_SOURCE_DIR}/Externals/LibXML/include
    ${CMAKE_SOURCE_DIR}/Externals/MathMLSolver/include
    ${CMAKE_SOURCE_DIR}/Externals/Cg/include
    ${CMAKE_SOURCE_DIR}/Externals/MayaDataModel/include
    ${CMAKE_SOURCE_DIR}/common/libBuffer/include
    ${CMAKE_SOURCE_DIR}/common/libftoa/include
)

# Add dae2ma include path if import is enabled
if(ENABLE_DAE2MA_IMPORT)
    list(APPEND COLLADAMAYA_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/dae2ma/include)
endif()


# Add cgFx includes if found
if(MAYA_CGFX_INCLUDE_DIR)
    list(APPEND COLLADAMAYA_INCLUDE_DIRS ${MAYA_CGFX_INCLUDE_DIR})
    message(STATUS "Found Maya cgFx includes: ${MAYA_CGFX_INCLUDE_DIR}")
else()
    message(WARNING "Maya cgFx includes not found. CgFx shader support may be limited.")
endif()

# Build Maya Plugin
if(BUILD_MAYA_PLUGIN)
    add_library(COLLADAMaya MODULE ${COLLADAMAYA_SOURCES})
    
    target_include_directories(COLLADAMaya PRIVATE ${COLLADAMAYA_INCLUDE_DIRS})
    
    # Link libraries
    set(COLLADAMAYA_LINK_LIBS
        ${MAYA_LIBRARIES}
        OpenCOLLADAStreamWriter_static
        OpenCOLLADASaxFrameworkLoader_static
        OpenCOLLADAFramework_static
        OpenCOLLADABaseUtils_static
        GeneratedSaxParser_static
        xml_static
        MathMLSolver_static
        buffer_static
        ftoa_static
    )
    
    # Add dae2ma library if import is enabled
    if(ENABLE_DAE2MA_IMPORT)
        list(APPEND COLLADAMAYA_LINK_LIBS dae2ma_static)
    endif()
    
    target_link_libraries(COLLADAMaya ${COLLADAMAYA_LINK_LIBS})
    
    # Add Windows socket library for xml network functions
    if(WIN32)
        target_link_libraries(COLLADAMaya ws2_32)
    endif()
    
    # Apply Maya plugin settings
    MAYA_PLUGIN(COLLADAMaya)
    
    # Add compile definitions AFTER MAYA_PLUGIN (which overwrites COMPILE_DEFINITIONS)
    if(ENABLE_DAE2MA_IMPORT)
        target_compile_definitions(COLLADAMaya PRIVATE ENABLE_DAE2MA_IMPORT)
    endif()
    
    # Set additional properties for Windows
    if(WIN32)
        # Add Windows-specific compile definitions
        target_compile_definitions(COLLADAMaya PRIVATE 
            WIN32 NDEBUG _WINDOWS _USRDLL NT_PLUGIN REQUIRE_IOSTREAM LIBXML_STATIC
        )
        
        set_target_properties(COLLADAMaya PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_CURRENT_BINARY_DIR}/bin/win/${CMAKE_VS_PLATFORM_NAME}/ReleasePlugin${MAYA_VERSION}"
            RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_CURRENT_BINARY_DIR}/bin/win/${CMAKE_VS_PLATFORM_NAME}/DebugPlugin${MAYA_VERSION}"
        )
        
        # # Add post-build command to copy to Maya installation
        # add_custom_command(TARGET COLLADAMaya POST_BUILD
        #     COMMAND ${CMAKE_COMMAND} -E copy_if_different
        #         $<TARGET_FILE:COLLADAMaya>
        #         "${MAYA_VERSION}/plug-ins/"
        #     COMMENT "Copying COLLADAMaya.mll to ${MAYA_VERSION} plug-ins directory"
        # )
        # 
        # # Copy MEL scripts
        # add_custom_command(TARGET COLLADAMaya POST_BUILD
        #     COMMAND ${CMAKE_COMMAND} -E copy_if_different
        #         "${CMAKE_CURRENT_SOURCE_DIR}/scripts/openColladaExporterOpts.mel"
        #         "${MAYA_VERSION}/scripts/others/"
        #     COMMAND ${CMAKE_COMMAND} -E copy_if_different
        #         "${CMAKE_CURRENT_SOURCE_DIR}/scripts/openColladaImporterOpts.mel"
        #         "${MAYA_VERSION}/scripts/others/"
        #     COMMENT "Copying MEL scripts to Maya ${MAYA_VERSION}"
        # )
    endif()
    
    # Installation rules
    install(TARGETS COLLADAMaya
        LIBRARY DESTINATION "${MAYA_LOCATION}/bin/plug-ins"
        RUNTIME DESTINATION "${MAYA_LOCATION}/bin/plug-ins"
    )
    
    install(FILES 
        scripts/openColladaExporterOpts.mel
        scripts/openColladaImporterOpts.mel
        DESTINATION "${MAYA_LOCATION}/scripts/others"
    )
endif()

# Build Console Application
if(BUILD_MAYA_CONSOLE)
    set(COLLADAMAYA_CONSOLE_SOURCES
        ${COLLADAMAYA_SOURCES}
        src/COLLADAMayaConsoleMain.cpp
    )
    
    add_executable(COLLADAMayaConsole ${COLLADAMAYA_CONSOLE_SOURCES})
    
    target_include_directories(COLLADAMayaConsole PRIVATE ${COLLADAMAYA_INCLUDE_DIRS})
    
    # Add compile definitions for dae2ma import if enabled
    if(ENABLE_DAE2MA_IMPORT)
        target_compile_definitions(COLLADAMayaConsole PRIVATE ENABLE_DAE2MA_IMPORT)
    endif()
    
    set(COLLADAMAYA_CONSOLE_LINK_LIBS
        ${MAYA_LIBRARIES}
        OpenCOLLADAStreamWriter_static
        OpenCOLLADASaxFrameworkLoader_static
        OpenCOLLADAFramework_static
        OpenCOLLADABaseUtils_static
        GeneratedSaxParser_static
        xml_static
        MathMLSolver_static
        buffer_static
        ftoa_static
    )
    
    # Add dae2ma library if import is enabled
    if(ENABLE_DAE2MA_IMPORT)
        list(APPEND COLLADAMAYA_CONSOLE_LINK_LIBS dae2ma_static)
    endif()
    
    target_link_libraries(COLLADAMayaConsole ${COLLADAMAYA_CONSOLE_LINK_LIBS})
    
    if(WIN32)
        set_target_properties(COLLADAMayaConsole PROPERTIES
            COMPILE_DEFINITIONS "WIN32;NDEBUG;_CONSOLE"
            RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_CURRENT_BINARY_DIR}/bin/win/${CMAKE_VS_PLATFORM_NAME}/ReleaseConsole${MAYA_VERSION}"
            RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_CURRENT_BINARY_DIR}/bin/win/${CMAKE_VS_PLATFORM_NAME}/DebugConsole${MAYA_VERSION}"
        )
    endif()
    
    install(TARGETS COLLADAMayaConsole
        RUNTIME DESTINATION bin
    )
endif()

# Display configuration summary
message(STATUS "====================================")
message(STATUS "COLLADAMaya Configuration:")
message(STATUS "  Maya Version: ${MAYA_VERSION}")
message(STATUS "  Maya Location: ${MAYA_LOCATION}")
message(STATUS "  Build Plugin: ${BUILD_MAYA_PLUGIN}")
message(STATUS "  Build Console: ${BUILD_MAYA_CONSOLE}")
message(STATUS "====================================")
