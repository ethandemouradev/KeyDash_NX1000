# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appKeyDash_NX1000_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appKeyDash_NX1000_autogen.dir\\ParseCache.txt"
  "appKeyDash_NX1000_autogen"
  )
endif()
