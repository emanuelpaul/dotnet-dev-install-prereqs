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
    
    Write-Output 'Installing Visual Studio 2022 with dependencies...'
    winget install Microsoft.VisualStudio.2022.Professional -s winget --override "--wait --quiet --add Microsoft.VisualStudio.Workload.Node --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools --add Microsoft.Net.Component.4.8.1.SDK --add Microsoft.Net.Component.4.8.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.1.DeveloperTools --add Microsoft.Net.Core.Component.SDK.2.1 --add Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1 --add wasm.tools --add Microsoft.NetCore.Component.Runtime.3.1"
}

function Create-Bak-When-Exists {
    param  
    (  
        $file
    ) 

    if (Test-Path -Path $file ) {
        Write-Output "File $file existis. Creating backup copy $file.bak"
        cp $settingsFile $settingsFile.bak
    }
}

function ChangeFont-WindowsTerminal {
    Write-Output 'Changing default font for windows terminal...'
    $settingsFile = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Create-Bak-When-Exists -file $settingsFile
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/settings.json -o settings.json
    cp .\settings.json $settingsFile -Force
}

function Set-Powershell-Profile {
    Write-Output 'Setting powershell profile'
    Install-Module PSReadLine -Force
    Install-Module -Name Terminal-Icons -Repository PSGallery
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/Microsoft.PowerShell_profile.ps1 -o Microsoft.PowerShell_profile.ps1
    Create-Bak-When-Exists -file $PROFILE
    cp Microsoft.PowerShell_profile.ps1 $PROFILE -Force
}

Install-Apps

$fontFiles = Get-Fonts

Install-Fonts -fontsToInstall $fontFiles

ChangeFont-WindowsTerminal

Set-Powershell-Profile

shutdown -r -t 60