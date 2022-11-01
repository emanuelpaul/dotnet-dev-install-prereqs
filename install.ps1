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
    Write-Warning 'If prompted to install NuGet choose Y'
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

    Write-Output 'Installing wsl...'
    wsl --install
    
    Write-Output 'Getting winget install script...'
    Install-Script -Name winget-install -Force
    
    Write-Output 'Installing winget...'
    winget-install.ps1
    sleep 5
    
    Write-Output 'Getting winget-apps.json...'
    irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/winget-apps.json -o winget-apps.json
    
    Write-Output 'Starting to install apps using winget...'
    winget import winget-apps.json
    
    Write-Output 'Installing Visual Studio 2022 with dependencies...'
    winget install Microsoft.VisualStudio.2022.Professional -s winget --override "--wait --quiet --add Microsoft.VisualStudio.Workload.Node --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools --add Microsoft.Net.Component.4.8.1.SDK --add Microsoft.Net.Component.4.8.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.1.DeveloperTools --add Microsoft.Net.Core.Component.SDK.2.1 --add Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1 --add wasm.tools --add Microsoft.NetCore.Component.Runtime.3.1"
}

Install-Apps

$fontFiles = Get-Fonts

Install-Fonts -fontsToInstall $fontFiles

shutdown -r -t 60