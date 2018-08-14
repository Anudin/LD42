del build\*.pck build\web\*.pck build\Battle_billiard_galactic_edition 2>nul
D:\Godot\Godot_v3.0.6-stable_win64.exe --export "Windows Desktop" build\Battle_billiard_galactic_edition.pck
D:\Godot\Godot_v3.0.6-stable_win64.exe --export "Linux/X11" build\Battle_billiard_galactic_edition
copy /Y build\*.pck build\web\
7z a -tzip build\Battle_billiard_galactic_edition.zip build\*.exe build\*.pck