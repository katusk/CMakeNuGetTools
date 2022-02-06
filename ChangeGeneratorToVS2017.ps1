function Update-CMakeFile() {
	param([string] $fileName)

    (Get-Content $fileName) | 
        ForEach-Object{$_ -replace '-G "Visual Studio 16 2019" -A x64','-G "Visual Studio 15 2017 Win64"'} |
            Set-Content $fileName
}

function Update-JsonFile() {
	param([string] $fileName)

    $text = [string]::Join("`r`n", (Get-Content $fileName))
    [regex]::Replace($text, 
                     """generator"": ""Visual Studio 16 2019"",`r`n            ""architecture"": ""x64"",",
                     """generator"": ""Visual Studio 15 2017 Win64"",",
                     "SingleLine") |
        Set-Content $fileName -NoNewline
}

Update-CMakeFile .\build.cmake
Update-CMakeFile .\CMakeLists.txt
Update-JsonFile .\tests\export_cmake_and_install\CMakeSettings.json
Update-JsonFile .\tests\export_simple_cmake\CMakeSettings.json
Update-JsonFile .\tests\export_simple_dot_targets\CMakeSettings.json
Update-JsonFile .\tests\export_simple_toolchain\CMakeSettings.json
Update-JsonFile .\tests\write_autopkg_nested\CMakeSettings.json
Update-JsonFile .\tests\write_autopkg_simple\CMakeSettings.json
Update-JsonFile .\tests\write_nuspec_simple\CMakeSettings.json
