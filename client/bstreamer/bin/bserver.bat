@REM ----------------------------------------------------------------------------
@REM  Copyright 2001-2006 The Apache Software Foundation.
@REM
@REM  Licensed under the Apache License, Version 2.0 (the "License");
@REM  you may not use this file except in compliance with the License.
@REM  You may obtain a copy of the License at
@REM
@REM       http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM  Unless required by applicable law or agreed to in writing, software
@REM  distributed under the License is distributed on an "AS IS" BASIS,
@REM  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@REM  See the License for the specific language governing permissions and
@REM  limitations under the License.
@REM ----------------------------------------------------------------------------
@REM
@REM   Copyright (c) 2001-2006 The Apache Software Foundation.  All rights
@REM   reserved.

@echo off

set ERROR_CODE=0

:init
@REM Decide how to startup depending on the version of windows

@REM -- Win98ME
if NOT "%OS%"=="Windows_NT" goto Win9xArg

@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" @setlocal

@REM -- 4NT shell
if "%eval[2+2]" == "4" goto 4NTArgs

@REM -- Regular WinNT shell
set CMD_LINE_ARGS=%*
goto WinNTGetScriptDir

@REM The 4NT Shell from jp software
:4NTArgs
set CMD_LINE_ARGS=%$
goto WinNTGetScriptDir

:Win9xArg
@REM Slurp the command line arguments.  This loop allows for an unlimited number
@REM of arguments (up to the command line limit, anyway).
set CMD_LINE_ARGS=
:Win9xApp
if %1a==a goto Win9xGetScriptDir
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto Win9xApp

:Win9xGetScriptDir
set SAVEDIR=%CD%
%0\
cd %0\..\.. 
set BASEDIR=%CD%
cd %SAVEDIR%
set SAVE_DIR=
goto repoSetup

:WinNTGetScriptDir
for %%i in ("%~dp0..") do set "BASEDIR=%%~fi"

:repoSetup
set REPO=


if "%JAVACMD%"=="" set JAVACMD=java

if "%REPO%"=="" set REPO=%BASEDIR%\repo

set CLASSPATH="%BASEDIR%"\etc;"%REPO%"\ffmpeg-7.1.1-1.5.12.jar;"%REPO%"\javacpp-1.5.12.jar;"%REPO%"\netty-transport-4.2.9.Final.jar;"%REPO%"\netty-common-4.2.9.Final.jar;"%REPO%"\netty-buffer-4.2.9.Final.jar;"%REPO%"\netty-resolver-4.2.9.Final.jar;"%REPO%"\netty-transport-classes-epoll-4.2.9.Final.jar;"%REPO%"\netty-transport-native-unix-common-4.2.9.Final.jar;"%REPO%"\netty-transport-classes-io_uring-4.2.9.Final.jar;"%REPO%"\netty-transport-classes-kqueue-4.2.9.Final.jar;"%REPO%"\netty-handler-4.2.9.Final.jar;"%REPO%"\netty-codec-base-4.2.9.Final.jar;"%REPO%"\netty-codec-http-4.2.9.Final.jar;"%REPO%"\netty-codec-compression-4.2.9.Final.jar;"%REPO%"\log4j-core-2.25.3.jar;"%REPO%"\log4j-api-2.25.3.jar;"%REPO%"\log4j-slf4j-impl-2.25.3.jar;"%REPO%"\slf4j-api-1.7.36.jar;"%REPO%"\jackson-dataformat-yaml-3.0.3.jar;"%REPO%"\snakeyaml-engine-2.10.jar;"%REPO%"\jackson-core-3.0.3.jar;"%REPO%"\jackson-databind-3.0.3.jar;"%REPO%"\jackson-annotations-2.20.jar;"%REPO%"\commons-cli-1.4.jar;"%REPO%"\ffmpeg-7.1.1-1.5.12-linux-x86_64.jar;"%REPO%"\netty-transport-native-epoll-4.2.9.Final-linux-x86_64.jar;"%REPO%"\netty-transport-native-io_uring-4.2.9.Final-linux-x86_64.jar;"%REPO%"\bstreamer-1.0.0.jar

set ENDORSED_DIR=
if NOT "%ENDORSED_DIR%" == "" set CLASSPATH="%BASEDIR%"\%ENDORSED_DIR%\*;%CLASSPATH%

if NOT "%CLASSPATH_PREFIX%" == "" set CLASSPATH=%CLASSPATH_PREFIX%;%CLASSPATH%

@REM Reaching here means variables are defined and arguments have been captured
:endInit

%JAVACMD% %JAVA_OPTS%  -classpath %CLASSPATH% -Dapp.name="bserver" -Dapp.repo="%REPO%" -Dapp.home="%BASEDIR%" -Dbasedir="%BASEDIR%" me.vzhilin.bstreamer.ServerCLI %CMD_LINE_ARGS%
if %ERRORLEVEL% NEQ 0 goto error
goto end

:error
if "%OS%"=="Windows_NT" @endlocal
set ERROR_CODE=%ERRORLEVEL%

:end
@REM set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" goto endNT

@REM For old DOS remove the set variables from ENV - we assume they were not set
@REM before we started - at least we don't leave any baggage around
set CMD_LINE_ARGS=
goto postExec

:endNT
@REM If error code is set to 1 then the endlocal was done already in :error.
if %ERROR_CODE% EQU 0 @endlocal


:postExec

if "%FORCE_EXIT_ON_ERROR%" == "on" (
  if %ERROR_CODE% NEQ 0 exit %ERROR_CODE%
)

exit /B %ERROR_CODE%
