
@echo off

odin build . -o:speed -no-crt
copy dol_dumpy.exe ..\bin\dol_dumpy.exe
