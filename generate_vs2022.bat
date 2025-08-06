set current_dir=%~dp0
set cmake_temp_dir=cmake_temp_msvc2022
rd /Q /S %cmake_temp_dir%
mkdir %cmake_temp_dir%
cd %cmake_temp_dir%
cmake -G "Visual Studio 17 2022" ..\
cd %current_dir%
