cmake_minimum_required(VERSION 3.0.0)
project(HotFix VERSION 0.1.0)

include(CTest)
enable_testing()

# aux_source_directory(. DIR_SRCS)
# set(EXECUTABLE_OUTPUT_PATH, ${PROJECT_BINARY_DIR}/bin)

# include_directories(${PROJECT_SOURCE_DIR}/include)
# add_subdirectories(src)

set(exe_sources)
list(APPEND exe_sources main.cpp)
list(APPEND exe_sources FileManage.cpp)


#add_executable(HotFix main.cpp)

add_executable(HotFix ${exe_sources})
#target_link_libraries(HotFix FileManage.cpp)



set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)

message(STATUS, ${PROJECT_SOURCE_DIR} "-------完成编译和链接生成可执行文件-----")
