#irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/install.ps1 | iex

#more info https://blog.simontimms.com/2021/06/11/installing-fonts/
function Install-Fonts {  
    param  
    (  
        $fontsToInstall
    )  
          
    Write-Output "Installing fonts..."
    $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach ($file in $fontsToInstall)
    {
        $fileName = $file.Name
        if (-not(Test-Path -Path "C:\Windows\fonts\$fileName" )) {
            Write-Output "Installing font $fileName"
            dir $file.fullname | %{ $fonts.CopyHere($_.fullname) }
        }
    }
    cp *.ttf c:\windows\fonts\
    
} 

function Get-Fonts {

    Write-Output "Getting fonts..."

    Invoke-RestMethod https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip?WT.mc_id=-blog-scottha -o cove.zip

    Expand-Archive -Path cove.zip -DestinationPath $pwd\fonts -Force

    $fontFiles = Get-ChildItem $pwd\fonts *.ttf

    return $fontFiles
}

function Install-Apps {    
    Write-Output 'Adding PSGallery'
    Write-Warning 'If prompted to install NuGet press ENTER'
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

    Write-Output 'Installing wsl...'
    wsl --install
    
    Write-Output 'Getting winget install script...'
    Install-Script -Name winget-install -Force
    
    Write-Output 'Installing winget...'
    winget-install.ps1

    Write-Output 'Getting winget-apps.json...'
    sleep 5    
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/winget-apps.json -o winget-apps.json
    
    Write-Output 'Starting to install apps using winget...'
    winget import winget-apps.json
}

function Create-Bak-When-Exists {
    param  
    (  
        $file
    ) 

    if (Test-Path -Path $file ) {
        Write-Output "File $file exists. Creating backup copy $file.bak"
        cp $file $file.bak
    }
}

function HasProperty($object, $propertyName)
{
    $propertyName -in $object.PSobject.Properties.Name
}

function Set-default-font-wt {
    Write-Output "Setting default font windows terminal..."
    Start-Process -FilePath "wt" -WindowStyle Hidden
    sleep 3
    $settingsFile = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Create-Bak-When-Exists -file $settingsFile
    $json = Get-Content -Path $settingsFile -Raw
    $settings = $json | ConvertFrom-Json
    if(-Not (HasProperty -object $settings.profiles.defaults -propertyName "font")){
        $fontFace = '{ "face" : "CaskaydiaCove NF" }' | ConvertFrom-Json
        $settings.profiles.defaults | Add-Member -Name "font" -Value $fontFace -MemberType NoteProperty
    }else {
        if(-Not (HasProperty -object $settings.profiles.defaults.font -propertyName "face")){
            $settings.profiles.defaults.font | Add-Member -Name "face" -Value "CaskaydiaCove NF" -MemberType NoteProperty
        }else{
            $settings.profiles.defaults.font.face="CaskaydiaCove NF"
        }
    }
    $settings | ConvertTo-Json -Depth 9 | Out-File -FilePath $settingsFile -Encoding utf8
}

function Copy-Oh-my-posh-config {
    Write-Output 'Setting oh-my-posh config...'
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/dotnet-oh-my-posh.json -o dotnet-oh-my-posh.json
    $ohMyPoshDir = $HOME + "\\.oh-my-posh";
    if (!(Test-Path -Path $ohMyPoshDir)){
        md $ohMyPoshDir
    }

    cp dotnet-oh-my-posh.json "$ohMyPoshDir\dotnet-oh-my-posh.json"
}

function Change-Powershell-Profile {
    Write-Output 'Changing powershell profile...'
    Install-Module PSReadLine -Force
    Install-Module -Name Terminal-Icons -Repository PSGallery
    pwsh -Command "Install-Module PSReadLine -Force; Install-Module -Name Terminal-Icons -Repository PSGallery" #install in powershell 7
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/Microsoft.PowerShell_profile.ps1 -o Microsoft.PowerShell_profile.ps1
    Create-Bak-When-Exists -file $PROFILE
    cp Microsoft.PowerShell_profile.ps1 $PROFILE -Force

    $windowsPowershellProfile = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    Create-Bak-When-Exists -file $windowsPowershellProfile
    cp Microsoft.PowerShell_profile.ps1 $windowsPowershellProfile -Force

    $powershell7Dir = "$HOME\Documents\PowerShell"
    $powershell7Profile = "$powershell7Dir\Microsoft.PowerShell_profile.ps1"
    if (-Not(Test-Path -Path $powershell7Dir )) {
        mkdir $powershell7Dir -Force
    }
    else{
        Create-Bak-When-Exists -file $powershell7Profile
    }
    cp Microsoft.PowerShell_profile.ps1 $powershell7Profile -Force
}

Install-Apps

# refresh path variable
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

$fontFiles = Get-Fonts

Install-Fonts -fontsToInstall $fontFiles

Set-default-font-wt

Copy-Oh-my-posh-config

Change-Powershell-Profile

Write-Output 'Installing Visual Studio 2022 with dependencies...'
winget install Microsoft.VisualStudio.2022.Professional -s winget --override "--wait --quiet --add Microsoft.VisualStudio.Workload.Node --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools --add Microsoft.Net.Component.4.8.1.SDK --add Microsoft.Net.Component.4.8.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.1.DeveloperTools --add Microsoft.Net.Core.Component.SDK.2.1 --add Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1 --add wasm.tools --add Microsoft.NetCore.Component.Runtime.3.1"

shutdown -r -t 60