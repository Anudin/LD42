REM Requires a Godot.exe and 7z.exe in PATH

REM Requres the .exe file of a Windows build [currently 64-bit only] two folders above your project as in:
REM --- DIRECTORY ---
REM Runner.exe
REM Project\game\project.godot

SET game_name=Battle_billiard_galactic_edition

REM Remove leftovers from previous builds
cd build
del *.pck web\*.pck *.x86_64 *.zip 2>nul

REM Generate Windows & Web .pck, generate Linux runnable
cd ..
Godot --export "Windows Desktop" build\%game_name%.pck
Godot --export "Linux/X11" build\%game_name%.x86_64

cd build
REM Windows & Web use the same format, copy Windows build to web folder
copy /Y *.pck web\

REM Create a temporary folder containing the .exe and .pck files for Windows, zip it and remove the folder
mkdir %game_name%
copy /Y ..\..\..\Runner.exe %game_name%\%game_name%.exe
copy /Y *.pck %game_name%\
start /wait 7z a -tzip %game_name%.zip %game_name%\*.exe %game_name%\*.pck
rmdir /s /q %game_name%\

del *.pck 2>nul