
#
# AppLauncherTest5
#

include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

# --------------------------------------------------------------------------
# Test1 - Make sure the launcher output an error message if no application is specified
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  )

print_command_as_string("${command}")

set(expected_error_msg "error: Application does NOT exists []${expected_help_text}")
if(NOT "${ev}" STREQUAL "${expected_error_msg}")
  message(FATAL_ERROR "Test1"
                      "\n  expected_error_msg:${expected_error_msg}"
                      "\n  current_error_msg:${ev}")
endif()

# --------------------------------------------------------------------------
# Test2 - Make sure the launcher output an error message if the application specified
# in the settings file is incorrect

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=this-app-do-not-exist

[LibraryPaths]
1\\path=${library_path}
size=1
")

set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  ERROR_STRIP_TRAILING_WHITESPACE
  )

print_command_as_string("${command}")

set(expected_error_msg "error: Application does NOT exists [this-app-do-not-exist]${expected_help_text}")
if(NOT "${ev}" STREQUAL "${expected_error_msg}")
  message(FATAL_ERROR "Test2"
                      "\n  expected_error_msg:${expected_error_msg}"
                      "\n  current_error_msg:${ev}")
endif()

# --------------------------------------------------------------------------
# Test3 - Make sure the launcher works as expected if the application
# to launch is properly set in the settings file

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}

[LibraryPaths]
1\\path=${library_path}
size=1
")

set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  OUTPUT_QUIET
  ERROR_QUIET
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test3 - Failed to start [${application}]")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--foo myarg --list item1 item2 item3 --verbose

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Test4 - Make sure the launcher works as expected if the application
# to launch and the associated arguments are properly set in the settings file
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test4 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Argument passed:--foo myarg --list item1 item2 item3 --verbose")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test4 - Failed to pass parameters from ${launcher_name} "
                      "to ${application_name}.")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--check-env

[LibraryPaths]
1\\path=${library_path}
size=1

[EnvironmentVariables]
SOMETHING_NICE=Chocolate
SOMETHING_AWESOME=Rock climbing !
")

# --------------------------------------------------------------------------
# Test5 - Make sure the launcher passes the environment variable to the application
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test5 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "SOMETHING_NICE=Chocolate\nSOMETHING_AWESOME=Rock climbing !")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test5 - Failed to pass environment variable from ${launcher_name} "
                      "to ${application_name}.\n${ov}")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--check-path

[LibraryPaths]
1\\path=${library_path}
size=1

[Paths]
1\\path=/home/john/app1
2\\path=/home/john/app2
size=2
")

# --------------------------------------------------------------------------
# Test6 - Make sure the launcher passes the PATH variable to the application
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test6 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(pathsep ":")
if(WIN32)
  set(pathsep ";")
endif()
set(expected_msg "PATH=/home/john/app1${pathsep}/home/john/app2")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if("${current_msg}" STREQUAL "")
  message(FATAL_ERROR "Test6 - Failed to pass PATH variable from ${launcher_name} "
                      "to ${application_name}.\n${ov}")
endif()

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=

[LibraryPaths]
1\\path=${library_path}
size=1
")

# --------------------------------------------------------------------------
# Test7 - Make sure the command line arguments are passed to the launcher
set(command ${launcher_exe} --launcher-no-splash --foo --int 2)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "Test7 - [${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_msg "Argument passed:--foo --int 2")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Test7 - Failed to pass parameters from ${launcher_name} "
                      "to ${application_name}.")
endif()
