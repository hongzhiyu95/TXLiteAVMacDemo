# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/LiteAVQTDemo_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/LiteAVQTDemo_autogen.dir/ParseCache.txt"
  "LiteAVQTDemo_autogen"
  )
endif()
