# CMakeLists.txt for dae2ma (COLLADA to Maya importer)

cmake_minimum_required(VERSION 3.5)
project(dae2ma)

# Options
option(BUILD_DAE2MA_CONSOLE "Build dae2ma console application" ON)

# Include directories
set(DAE2MA_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/COLLADAFramework/include
    ${CMAKE_SOURCE_DIR}/COLLADASaxFrameworkLoader/include
    ${CMAKE_SOURCE_DIR}/COLLADASaxFrameworkLoader/include/generated15
    ${CMAKE_SOURCE_DIR}/COLLADABaseUtils/include
    ${CMAKE_SOURCE_DIR}/GeneratedSaxParser/include
    ${CMAKE_SOURCE_DIR}/Externals/MayaDataModel/include
    ${libxml_include_dirs}
)

# Source files for dae2ma library
set(DAE2MA_LIB_SOURCES
    src/DAE2MAAnimationImporter.cpp
    src/DAE2MABaseAnimation.cpp
    src/DAE2MABaseImporter.cpp
    src/DAE2MACameraImporter.cpp
    src/DAE2MAControllerImporter.cpp
    src/DAE2MADocumentImporter.cpp
    src/DAE2MAEffectAnimation.cpp
    src/DAE2MAEffectImporter.cpp
    src/DAE2MAExtraDataCallbackHandler.cpp
    src/DAE2MAGeometryBinding.cpp
    src/DAE2MAGeometryImporter.cpp
    src/DAE2MAImageImporter.cpp
    src/DAE2MAImportOptions.cpp
    src/DAE2MALightImporter.cpp
    src/DAE2MAMaterialImporter.cpp
    src/DAE2MAMorphAnimation.cpp
    src/DAE2MANode.cpp
    src/DAE2MANodeImporter.cpp
    src/DAE2MASaxErrorHandler.cpp
    src/DAE2MAShadingBinding.cpp
    src/DAE2MATransformAnimation.cpp
    src/DAE2MAVisualSceneImporter.cpp
)

# Headers
set(DAE2MA_LIB_HEADERS
    include/DAE2MAAnimationImporter.h
    include/DAE2MABaseAnimation.h
    include/DAE2MABaseImporter.h
    include/DAE2MACameraImporter.h
    include/DAE2MAControllerImporter.h
    include/DAE2MAConversion.h
    include/DAE2MADocumentImporter.h
    include/DAE2MAEffectAnimation.h
    include/DAE2MAEffectImporter.h
    include/DAE2MAExtraDataCallbackHandler.h
    include/DAE2MAGeometryBinding.h
    include/DAE2MAGeometryImporter.h
    include/DAE2MAImageImporter.h
    include/DAE2MAImportOptions.h
    include/DAE2MALightImporter.h
    include/DAE2MAMaterialExporter.h
    include/DAE2MAMaterialImporter.h
    include/DAE2MAMayaTransform.h
    include/DAE2MAMorphAnimation.h
    include/DAE2MANode.h
    include/DAE2MANodeImporter.h
    include/DAE2MAPrerequisites.h
    include/DAE2MASaxErrorHandler.h
    include/DAE2MAShadingBinding.h
    include/DAE2MAStableHeaders.h
    include/DAE2MASyntax.h
    include/DAE2MATransformAnimation.h
    include/DAE2MAVisualSceneImporter.h
)

# Build dae2ma static library
add_library(dae2ma_static STATIC ${DAE2MA_LIB_SOURCES} ${DAE2MA_LIB_HEADERS})

target_include_directories(dae2ma_static PUBLIC ${DAE2MA_INCLUDE_DIRS})

# Set output name
set_target_properties(dae2ma_static PROPERTIES OUTPUT_NAME dae2ma)

# Link with OpenCOLLADA libraries
target_link_libraries(dae2ma_static
    OpenCOLLADASaxFrameworkLoader_static
    OpenCOLLADAFramework_static
    OpenCOLLADABaseUtils_static
    GeneratedSaxParser_static
    xml_static
    pcre_static
    UTF_static
)

# Build console application if requested
if(BUILD_DAE2MA_CONSOLE)
    add_executable(dae2ma_console src/DAE2MAConsoleMain.cpp)
    
    target_include_directories(dae2ma_console PRIVATE ${DAE2MA_INCLUDE_DIRS})
    
    target_link_libraries(dae2ma_console
        dae2ma_static
        OpenCOLLADASaxFrameworkLoader_static
        OpenCOLLADAFramework_static
        OpenCOLLADABaseUtils_static
        GeneratedSaxParser_static
        xml_static
        pcre_static
        UTF_static
    )
    
    set_target_properties(dae2ma_console PROPERTIES OUTPUT_NAME dae2ma)
    
    # Install target
    install(TARGETS dae2ma_console DESTINATION bin)
endif()

# Install library
install(TARGETS dae2ma_static ARCHIVE DESTINATION lib)
install(FILES ${DAE2MA_LIB_HEADERS} DESTINATION include/dae2ma)