@echo off
rem -------------------------------------------------------------------------
rem dcm2jpg  Launcher
rem -------------------------------------------------------------------------

if not "%ECHO%" == ""  echo %ECHO%
if "%OS%" == "Windows_NT"  setlocal

set MAIN_CLASS=org.dcm4che3.tool.dcm2jpg.Dcm2Jpg
set MAIN_JAR=dcm4che-tool-dcm2jpg-5.31.2.jar

set DIRNAME=.\
if "%OS%" == "Windows_NT" set DIRNAME=%~dp0%

rem Read all command line arguments

set ARGS=
:loop
if [%1] == [] goto end
        set ARGS=%ARGS% %1
        shift
        goto loop
:end

if not "%DCM4CHE_HOME%" == "" goto HAVE_DCM4CHE_HOME

set DCM4CHE_HOME=%DIRNAME%..

:HAVE_DCM4CHE_HOME

if not "%JAVA_HOME%" == "" goto HAVE_JAVA_HOME

set JAVA=java

goto SKIP_SET_JAVA_HOME

:HAVE_JAVA_HOME

set JAVA=%JAVA_HOME%\bin\java

:SKIP_SET_JAVA_HOME

set CP=%DCM4CHE_HOME%\etc\dcm2jpg\
set CP=%CP%;%DCM4CHE_HOME%\lib\%MAIN_JAR%
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-core-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-net-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-image-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-imageio-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-imageio-opencv-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-imageio-rle-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-tool-common-5.31.2.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\weasis-core-img-4.8.1.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\jai_imageio-1.2-pre-dr-b04.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\clibwrapper_jiio-1.2-pre-dr-b04.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\slf4j-api-2.0.9.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\logback-core-1.4.14.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\logback-classic-1.4.14.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\commons-cli-1.6.0.jar

rem Setup the native library path
"%JAVA%" -version 2>&1 | findstr 64-Bit >nul && set "OS=windows-x86-64" || set "OS=windows-x86"
set JAVA_LIBRARY_PATH=%DCM4CHE_HOME%\lib\%OS%

set JAVA_OPTS=%JAVA_OPTS% -Djava.library.path="%JAVA_LIBRARY_PATH%"

if not "%IMAGE_READER_FACTORY%" == "" ^
 set JAVA_OPTS=%JAVA_OPTS% -Dorg.dcm4che3.imageio.codec.ImageReaderFactory=%IMAGE_READER_FACTORY%

rem Required from JDK 16 with legacy image API (Decompressor and Compressor)
set JAVA_OPTS=%JAVA_OPTS% -XX:+IgnoreUnrecognizedVMOptions --add-opens=java.desktop/javax.imageio.stream=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED

"%JAVA%" %JAVA_OPTS% -cp "%CP%" %MAIN_CLASS% %ARGS%