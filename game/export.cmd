cd build
del *.pck web\*.pck *.x86_64 *.zip 2>nul

cd ..
D:\Godot\Godot_v3.0.6-stable_win64.exe --export "Windows Desktop" build\Battle_billiard_galactic_edition.pck
D:\Godot\Godot_v3.0.6-stable_win64.exe --export "Linux/X11" build\Battle_billiard_galactic_edition.x86_64

cd build
copy /Y *.pck web\

mkdir Battle_billiard_galactic_edition\
copy /Y *.exe Battle_billiard_galactic_edition\
copy /Y *.pck Battle_billiard_galactic_edition\
start /wait 7z a -tzip Battle_billiard_galactic_edition.zip Battle_billiard_galactic_edition\*.exe Battle_billiard_galactic_edition\*.pck
rmdir /s /q Battle_billiard_galactic_edition\

del *.pck 2>nul