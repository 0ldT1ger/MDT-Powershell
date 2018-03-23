Function Import-SMSTSENV{
    try
    {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
        Write-Output "$ScriptName - tsenv is $tsenv "
        $MDTIntegration = "YES"
         
        #$tsenv.GetVariables() | % { Write-Output "$ScriptName - $_ = $($tsenv.Value($_))" }
    }
    catch
    {
        Write-Output "$ScriptName - Unable to load Microsoft.SMS.TSEnvironment"
        Write-Output "$ScriptName - Running in standalonemode"
        $MDTIntegration = "NO"
    }
    Finally
    {
    if ($MDTIntegration -eq "YES"){
        $Logpath = $tsenv.Value("LogPath")
        $LogFile = $Logpath + "\" + "$ScriptName.log"
 
    }
    Else{
        $Logpath = $env:TEMP
        $LogFile = $Logpath + "\" + "$ScriptName.log"
    }
    }
}
Function Start-Logging{
    start-transcript -path $LogFile -Force
}
Function Stop-Logging{
    Stop-Transcript
}
Function Invoke-Exe{
    [CmdletBinding(SupportsShouldProcess=$true)]
  
    param(
        [parameter(mandatory=$true,position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Executable,
  
        [parameter(mandatory=$false,position=1)]
        [string]
        $Arguments
    )
  
    if($Arguments -eq "")
    {
        Write-Verbose "Running $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -NoNewWindow -Wait -Passthru
    }else{
        Write-Verbose "Running $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru"
        $ReturnFromEXE = Start-Process -FilePath $Executable -ArgumentList $Arguments -NoNewWindow -Wait -Passthru
    }
    Write-Verbose "Returncode is $($ReturnFromEXE.ExitCode)"
    Return $ReturnFromEXE.ExitCode
}
 
# Set vars
$SCRIPTDIR = split-path -parent $MyInvocation.MyCommand.Path
$SCRIPTNAME = split-path -leaf $MyInvocation.MyCommand.Path
$SOURCEROOT = "$SCRIPTDIR\Source"
$SettingsFile = $SCRIPTDIR + "\" + $SettingsName
$LANG = (Get-Culture).Name
$OSV = $Null
$ARCHITECTURE = $env:PROCESSOR_ARCHITECTURE
 
#Try to Import SMSTSEnv
. Import-SMSTSENV
 
# Set more vars
$Vendor = (get-wmiobject win32_computersystem).manufacturer
$Bios = (Get-WmiObject Win32_bios).smbiosbiosversion

#Start Transcript Logging
. Start-Logging

#Output base info
Write-Output "$ScriptName - ScriptDir: $ScriptDir"
Write-Output "$ScriptName - SourceRoot: $SOURCEROOT"
Write-Output "$ScriptName - ScriptName: $ScriptName"
Write-Output "$ScriptName - Current Culture: $LANG"
Write-Output "$ScriptName - Integration with MDT(LTI/ZTI): $MDTIntegration"
Write-Output "$ScriptName - Log: $LogFile"
Write-Output "$ScriptName - Model : (win32_computersystem): $((Get-WmiObject Win32_ComputerSystem).model)"
Write-Output "$ScriptName - Name : (Win32_ComputerSystemProduct): $((Get-WmiObject Win32_ComputerSystemProduct).Name)"
Write-Output "$ScriptName - Version : (Win32_ComputerSystemProduct): $((Get-WmiObject Win32_ComputerSystemProduct).Version)"

if ($Vendor -eq "Hewlett-Packard" ) {
    $Model = (Get-WmiObject Win32_ComputerSystemProduct).Name
    $Make = "HP"
    $ModelPath = $SOURCEROOT + "\" + $Make + "\" + $Model
    $ModelCorrect = Test-Path $ModelPath
    Write-output "$Make"
    }
    ElseIf ($Vendor -eq “Lenovo” ) {
    $Model = (Get-WmiObject Win32_ComputerSystemProduct).Name
    $Make = "Lenovo"
    $ModelPath = $SOURCEROOT + "\" + $Make + "\" + $Model
    $ModelCorrect = Test-Path $ModelPath
    Write-output "$Make"
    }
    ElseIf ($Vendor -eq “Dell Inc.” ) {
    $Model = (Get-WmiObject Win32_ComputerSystemProduct).Name
    $Make = "Dell"
    $ModelPath = $SOURCEROOT + "\" + $Make + "\" + $Model
    $ModelCorrect = Test-Path $ModelPath
    Write-output "$Make"
    }
            else {
        write-output “No update For this Model”
        }
if ($ModelCorrect -eq $True) {
            $BiosVer = Get-Content ($ModelPath + “\Version1.txt”)
            $BiosCheck =($BiosVer -like $Bios)
            }
If ($Make -eq "Dell") {
                    if ($BiosCheck -eq $False) {
                    Write-Output “$ScriptName – Upgrading BIOS version to = $BiosVer”
                    $Exe = ‘Bios1.exe’
                    $Location = $ModelPath
                    $Executable = $Location + “\” + $exe
                    Set-Location -Path $Location
                    Invoke-Exe -Executable “$Executable” -Arguments "/s" -Verbose
                    }
                        if ($MDTIntegration -eq “YES”){
                        $tsenv.Value(“NeedReboot”) = “YES”
                        $RestartNeeded = 1
                        }
                        else {
                        write-output “This machine does not require a Bios Update”
                        }
                    }
ElseIf ($Make -eq "HP") {
                    if ($BiosCheck -eq $False) {
                    Write-Output “$ScriptName – Upgrading BIOS version to = $BiosVer”
                    $Exe = ‘Bios1.exe’
                    $Location = $ModelPath
                    $Executable = $Location + “\” + $exe
                    Set-Location -Path $Location
                    Invoke-Exe -Executable “$Executable” -Arguments "/s" -Verbose
                        if ($MDTIntegration -eq “YES”){
                        $tsenv.Value(“NeedReboot”) = “YES”
                        $RestartNeeded = 1
                        }
                    }
                        else {
                        write-output “This machine does not require a Bios Update”
                        }
                    }
ElseIf ($Make -eq "Lenovo") {
                    if ($BiosCheck -eq $False) {
                    Write-Output “$ScriptName – Upgrading BIOS version to = $BiosVer”
                    $Exe = ‘Bios1.exe’
                    $Location = $ModelPath
                    $Executable = $Location + “\” + $exe
                    Set-Location -Path $Location
                    Invoke-Exe -Executable “$Executable” -Arguments "/s" -Verbose
                        if ($MDTIntegration -eq “YES”){
                        $tsenv.Value(“NeedReboot”) = “YES”
                        $RestartNeeded = 1
                        }
                    }
                        else {
                        write-output “This machine does not require a Bios Update”
                        }
                    }
$Version2 = $Modelpath + "\" + "Version2.txt"
$FileTest = test-path $Version2
If ( $FileTest -eq $True ) {
    $tsenv.Value(“Run2nd”) = "Yes"}

#Stop Logging
. Stop-Logging