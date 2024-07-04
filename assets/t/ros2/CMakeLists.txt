cmake_minimum_required(VERSION 3.10)
project(vr_track_tcp)

## Use C++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

## By adding -Wall and -Werror, the compiler does not ignore warnings anymore,
## enforcing cleaner code.
add_definitions(-Wall -Werror)

## Export compile commands for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# [find dependencies]

find_package(ament_cmake_auto REQUIRED)
ament_auto_find_build_dependencies()

# [build]

ament_auto_add_library(${PROJECT_NAME} SHARED
  src/main.cpp
)

# [dep.system.Poco]

# find_package(Poco REQUIRED COMPONENTS Foundation Net Util)
# message(STATUS "Poco_FOUND: ${Poco_FOUND}")
# target_include_directories(${PROJECT_NAME} PUBLIC ${Poco_INCLUDE_DIRS})
# target_link_libraries(${PROJECT_NAME} ${Poco_LIBRARIES})

# [dep.local.aubo]

# target_include_directories(${PROJECT_NAME} PUBLIC
#   ${PROJECT_SOURCE_DIR}/third_party/robotSDK/inc
# )
# target_link_directories(${PROJECT_NAME} PUBLIC
#   ${PROJECT_SOURCE_DIR}/third_party/robotSDK/lib/linux_x64
# )
# target_link_libraries(${PROJECT_NAME} auborobotcontroller)
# install(DIRECTORY ${PROJECT_SOURCE_DIR}/third_party/robotSDK/lib/linux_x64/
#   DESTINATION lib
# )

# [register node]
rclcpp_components_register_node(${PROJECT_NAME}
  PLUGIN vr_track_tcp::VrTrackTcp
  EXECUTABLE ${PROJECT_NAME}_node
)

# [testing]

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  list(APPEND AMENT_LINT_AUTO_EXCLUDE
    ament_cmake_copyright
    ament_cmake_uncrustify
    ament_cmake_cpplint
  )
  ament_lint_auto_find_test_dependencies()

  # find_package(ament_cmake_gtest)
  # set(TEST_NAME test_kalman_filter)
  # ament_add_gtest(${TEST_NAME} test/${TEST_NAME}.cpp)
  # target_link_libraries(${TEST_NAME} ${PROJECT_NAME})
endif()

# [install]

ament_auto_package(
  INSTALL_TO_SHARE
)

