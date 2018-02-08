﻿<#
.SYNOPSIS
    Very fast displays system information on a local or remote computer.
.DESCRIPTION
    The function uses WMI to collect information related to the characteristics of the computer
    The function uses multithreading. Multithreading is implemented through powershell runspace and WMI Job
    The function allows you to quickly get the system information of a large number of computers on the network
    After executing, two variables are created: 
    $Result-contains successful queries, 
    $ErrorResult-contains computers that have errors.
.PARAMETER ProcessFor
    This parameter determines the maximum number of computers for which WMI operations that can be executed simultaneously.
    By default, the value of this parameter is 50.
.PARAMETER JobTimeout
    Specifies the amount of time that the function waits for a response from the wmi job or runspace job.
    By default, the value of this parameter is 60 seconds.
.PARAMETER Protocol
    Defines the connection protocol to remote machine
    By default DCOM protocol
.PARAMETER AppendToResult
    Adds the output to the $Result global variable. Without this parameter, $Result global variable replaces.
.PARAMETER Credential
    Specifies a user account that has permission to perform this action. The default is the current user. Type a user n
    ame, such as "User01", "Domain01\User01", or User@domain01.com. Or, enter a PSCredential object, such as an object t
    hat is returned by the Get-Credential cmdlet. When you type a user name, you are prompted for a password.
.EXAMPLE
    Get-SystemInfo
    ComputerName     : Localhost
    OsCaption        : Майкрософт Windows 10 Pro
    OsArchitecture   : 64-разрядная
    OsUpTime         : 10:1:17:41
    OsLoggedInUser   : Domain\Username
    CPUName          : Intel(R) Core(TM) i3-2105 CPU @ 3.10GHz
    MotherboardModel : H61M-S1
    DeviceModel      : To be filled by O.E.M.
    MemoryTotal      : 4,0Gb
    MemoryModules    :
                       Capacity MemoryType Speed Manufacturer PartNumber
                       -------- ---------- ----- ------------ ----------
                       2Gb      DDR3       1333  Kingston     99U5595-005.A00LF
                       2Gb      DDR3       1333  Kingston     99U5595-005.A00LF
    HddDevices       :
                       Size  InterfaceType Model                           SmartStatus
                       ----  ------------- -----                           --------------
                       112Gb IDE           KINGSTON SHFS37A120G ATA Device ОК
                       149Gb IDE           ST3160813AS ATA Device          OK
    VideoModel       : Intel(R) HD Graphics 3000
    MonitorName      : E2042
    CdRom            : TSSTcorp CDDVDW SH-222BB
    This command get the system information on the local computer.
.EXAMPLE
    Get-SystemInfo -Computername comp1,comp2,comp3
    This command receives system information from computers comp1, comp2, comp3. By default, the current account must be a member of the Administrators group on the
    remote computer.
.EXAMPLE
    1..254 | foreach {"192.168.1.$_"} | Get-SystemInfo -Properties OsCaption,OSArchitecture,OsInstallDate -Credential Domain01\administrator01 | Out-GridView
    Get OsCaption, OSArchitecture, OsInstallDate from the computers that are in the 192.168.1.0/24 network and sends them to a grid view window. This command uses 
    the Credential parameter. The value of the Credential parameter is a user account name. The user is prompted for a password.
.EXAMPLE
    Get-ADComputer -Filter * | Get-SystemInfo -Cpu -Motherboard -Memory -Properties OsVersion,OsProductKey -ProcessFor 100 -JobTimeOut 30
    Get CPU, Motherboard, Memory and OsVersion, OsProductKey information from all domain computers. The module activedirectory must be installed and loaded. 
    This command uses -ProcessFor and JobTimeOut parameter.
.EXAMPLE 
    Get-ADComputer -Filter * | Get-SystemInfo -Protocol WSMAN
    This command gets system information from all domain computers. Wsman protocol is used for connection
    If errors occur, such as timeout expired  or other errors.
    After some time, you can repeat the command for computers that have had errors.To do this, you need to use the variable $ErrorResult and -AppendToResult parameter to add the result to a variable $Result. 
    PS C:\>$ErrorResult | Get-SystemInfo -Protocol WSMAN
.EXAMPLE
    Get-Content -Path C:\Computers.txt | Get-SystemInfo -Properties MemoryTotal,OsLoggedInUser -WarningAction SilentlyContinue | Where-Object {$_.memorytotal -lt 1.5gb}
    This command gets computers that have a RAM size less than 1.5 gb. List of computers is taken from the file C:\Computers.txt. This command use parameter -WarningAction SilentlyContinue to ignore warning.
    
.EXAMPLE
    Get-Content -Path C:\Computers.txt  | Get-SystemInfo -Properties OsLoggedInUser,HddSmart | Where-Object {$_.hddsmart.smartstatus -eq "Critical" -or $_.hddsmart.smartstatus -eq "Warning"}
    This command gets computers that have hard disk problems
.EXAMPLE
    $Computers=Get-Content -Path C:\Computers.txt
    Get-SystemInfo -Computername $Computers | ConvertTo-Html -Head "SystemInformation" | Out-File -FilePath C:\report.html
    This command create html report
.NOTES
    Author: SAGSA
    https://github.com/SAGSA/SystemInfo
    Requires: Powershell 2.0
#>
function Get-SystemInfotest
{
[CmdletBinding()]
    param(
            [parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,Position=0)]
            [Alias('CN','Computername','DnsHostname')]
            [string[]]$Name=$Env:COMPUTERNAME,          
            [switch]$OsInfo,
            [switch]$Cpu,
            [switch]$Motherboard,
            [switch]$Memory,
            [switch]$HDD,
            [switch]$Video,
            [switch]$Monitor,
            [switch]$NetworkAdapter,
            [switch]$PrinterInfo,
            [switch]$UsbDevices,
            [switch]$SoftwareList,
            $Credential,
            [ValidateSet("Dcom","Wsman")]
            $Protocol="Dcom",
            [Alias("ThrottleLimit")]
            $ProcessFor=50,
            [ValidateRange(1,1000)]
            [int]$MaxWmiJob=20,
            [Alias("Timeout")]
            [ValidateRange(1,6000)]
            [int]$JobTimeOut=60,
            [switch]$AppendToResult,  
            [ValidateSet("*","OsVersion","OSArchitecture","OsCaption","OsInstallDate","OsUpTime","OsLoggedInUser","OsProductKey","MemoryTotal","MemoryFree","MemoryModules","MemoryModInsCount",
            "MemoryMaxIns","MemorySlots","ECCType","MemoryAvailable","Motherboard","MotherboardModel","DeviceModel","Cdrom","CdromMediatype","HddDevices","HddDevCount","HDDSmart",
            "HddSmartStatus","VideoModel","VideoRam","VideoProcessor","CPUName","CPUSocket","MaxClockSpeed","CPUCores","CPULogicalCore","MonitorManuf",
            "MonitorPCode","MonitorSN","MonitorName","MonitorYear","NetPhysAdapCount","NetworkAdapters","Printers","IsPrintServer","UsbConPrOnline","UsbDevices","CPULoad","SoftwareList","RegistryValue","OsAdministrators","OsActivationStatus")] 
            [array]$Properties
            
            )
begin
{
$TestAdmin = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$IsAdmin=$TestAdmin.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
$CurrentExecutionPolicy=Get-ExecutionPolicy
$ExecutionPolicyChanged=$false
if (!($RequiredExecutionPolicy -eq $CurrentExecutionPolicy))
{
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -Confirm:$false 
        if ($?)
        {
            $ExecutionPolicyChanged=$true
        }
        else
        {
            Write-Error "Formatting objects does not work. Run the command Set-ExecutionPolicy -ExecutionPolicy RemoteSigned and retry now" -ErrorAction Stop
        }    
}
#LoadFunctions
#####################################################################################################
$FunctionFolderName="Function"
$LoadScripts=@(
"Config\functionconfig.ps1",
"$FunctionFolderName\ParseParam.ps1",
"$FunctionFolderName\CreateResult.ps1",
"$FunctionFolderName\FormatObject.ps1",
"$FunctionFolderName\GetHddSmart.ps1",
"$FunctionFolderName\wmi.ps1",
"$FunctionFolderName\Registry.ps1",
"$FunctionFolderName\CreateErrorObject.ps1",
"$FunctionFolderName\PsJob.ps1",
"$FunctionFolderName\RunspaceJob.ps1"
)


$LoadScripts | foreach {
    .(Join-Path -Path $PSScriptRoot -ChildPath $_)
    if(!$?)
    {
        break
    }
}

#####################################################################################################
$BeginFunction=get-date

if ($PSBoundParameters['Credential'])
{
    if (!($Credential.gettype().name -eq "PSCredential"))
    {
        $Credential=Get-Credential $Credential
    }    
}
#Clear Old Job
Write-Verbose "Clear old Job"
Get-Job | Where-Object {$_.state -ne "Running"} | Remove-Job -Force

#Collection all Properties
$AllPropertiesSwitch=@()
$AllPropertiesSwitch+=$PSCmdlet.MyInvocation.BoundParameters.keys | foreach {
    if ($PSCmdlet.MyInvocation.BoundParameters[$_].ispresent -and !($ExcludeParam -eq $_))
    {
        $SwitchConfig[$_]        
    
    }

}

if ($AllPropertiesSwitch[0] -eq $Null -and $Properties -eq $null)
{
    $AllPropertiesSwitch=$DefaultInfoConfig   
}
$AllProperties+=$AllPropertiesSwitch+$Properties

if ($AllProperties.GetType().name -ne "string")
{
    $AllProperties=0..$AllProperties.Count | foreach {if ($AllProperties[$_] -ne $null){$AllProperties[$_]}}
    $AllProperties = $AllProperties | Select-Object -Unique
}

if ($AllProperties -match "\*")
{
    Write-Verbose "Property: $($FunctionConfig.Keys)"
    $AllProperties=$FunctionConfig.Keys -ne "RegistryValue"
}
else
{
    Write-Verbose "Property: $AllProperties"
}

#Parse FunctionConfig
$PropertyParams=$AllProperties | ParseFunctionConfig -FunctionConfig $FunctionConfig -Protocol $Protocol 
$Propertyparams.Keys | foreach {$PropertyParams[$_] | Where-Object {$_.script}} | foreach {
    $ScriptTmp=$_
    $ScriptPath=Join-Path -Path $PSScriptRoot -ChildPath "scripts\$($ScriptTmp.script)" 
    $Script=Get-Content -Path $ScriptPath -ErrorAction Stop | Out-String 
        if ((Split-Path -Path $ScriptPath) -match ".+\\(.+)")
        {
            $RootFoolder=$Matches[1]
            $FunctionName="FunctInf"+$RootFoolder+$((Split-Path -Path $ScriptPath -Leaf) -replace "\.ps1","")
            
        }
        else
        {
            Write-Error "$FunctionProperty incorrect path" -ErrorAction Stop
        }
    [void](New-Item -Path function: -Name $FunctionName -Value $Script -ErrorAction Stop)
    
    $ScriptTmp | Add-Member -MemberType NoteProperty -Name Function -Value $FunctionName
    
}

#Create wmi param
$WmiParamArray=CreateWmiObject -PropertyParams $PropertyParams -ManualNamespace $ManualNamespace
    
#Remove old ps1xml file
if (Test-Path $($env:TEMP+"\SystemInfoAutoformat.ps1xml"))
{
    Write-Verbose "Remove ps1xml file $($env:TEMP+"\SystemInfoAutoformat.ps1xml")"
    Remove-Item -Path $($env:TEMP+"\SystemInfoAutoformat.ps1xml") -Force
}

$computers=@()
$MainJobs = New-Object System.Collections.ArrayList
$GetWmicompletedForComputers = New-Object System.Collections.ArrayList
#$HashtableResult=@{}
#$HashtableWMi=@{}
$HashtableRunspace=@()
$Global:ErrorResult=@()
$UpdateFormatData=$true

if ($PSBoundParameters["AppendToResult"].IsPresent)
{
    if (!(Get-Variable -Name Result -Scope Global))
    {
        $Global:Result=@()
    }
    elseif((Get-Variable -Name Result -Scope Global -ValueOnly).count -eq $null)
    {
        $OldRes=$Global:Result
        $Global:Result=@()
        $Global:Result+=$OldRes
    }
}
else
{
    $Global:Result=@()
}

[ScriptBlock]$SbLocalHost=
{
    $HashtableWMi=@{}
    $WmiParamArray | foreach {
        $WmiParam=$_
        if ($WmiParam.Name)
        {
            if (!($HashtableWMi.ContainsKey($($WmiParam.Name))))
            {
                #$HashtableWMi[$($WmiParam.Name)]
                $HashtableWMi.Add($WmiParam.Name,$null)
            }
        }
                
            
    }
            
    $jobs = New-Object System.Collections.ArrayList
    StartWmiJob -computername $Computername -WmiParamArray $WmiParamArray
    do
    {
        GetWmiJob
    }
    while($jobs.Count -ne 0)  
            
    CreateResult  
}

$CountComputers=0

[Array]$ExportFunctionsName="StartWmiJob","GetWmiJob","CreateResult"
    $PropertyReqHddSmartFunctions="HddDevices","HddSmartStatus","HddSmart"
    $PropertyReqRegistryFunctions="OsProductKey","SoftwareList"
    $WmiParamArray | foreach {
        if ($PropertyReqHddSmartFunctions -eq $_.property)
        {
            if (!($ExportFunctionsName -eq "GetHddSmart"))
            {
                $ExportFunctionsName+="GetHddSmart"  
            }

        }
        if ($PropertyReqRegistryFunctions -eq $_.property)
        {
            if (!($ExportFunctionsName -eq "RegGetValue"))
            {
                $ExportFunctionsName+="RegGetValue","RegEnumKey"  
            }
        }
            
    }

Write-Verbose "$protocol protocol"
if ($Protocol -eq "DCOM" -and $PSCmdlet.MyInvocation.InvocationName -ne $PSCmdlet.MyInvocation.line)
{
    $ExportFunctionsName+="StartWmi"
    $RunspaceImportVariables="WmiParamArray","Credential"    
    $SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        Get-Command -CommandType Function -Name $ExportFunctionsName | foreach {
            $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $_.name, $_.Definition         
            Write-Verbose "Add Function $($_.name)"
            $SessionState.Commands.Add($SessionStateFunction)
                
        }
        Get-Command -CommandType Function -Name FunctInf* | foreach {
                $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $_.name, $_.Definition         
                Write-Verbose "Add script Function $($_.name)"
                $SessionState.Commands.Add($SessionStateFunction)
                
            }

    $SessionStateVariables=New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList "WmiParamArray", $WmiParamArray, "WmiParamArray"
    $SessionState.Variables.Add($SessionStateVariables)       
    $SessionStateVariables=New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList "Credential", $Credential, "Credential"
    $SessionState.Variables.Add($SessionStateVariables) 
    $SessionStateVariables=New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList "VerbosePreference", $VerbosePreference, "VerbosePreference"
    $SessionState.Variables.Add($SessionStateVariables)   
    
    $RunspacePool = [runspacefactory]::CreateRunspacePool(1,$ProcessFor,$SessionState,$Host)
    Write-Verbose "Open Runspace"
    $RunspacePool.Open()
}
else
{
    $VerboseStatus=$VerbosePreference
    $ExportFunctions=@()
    $ExportFunctionsName | foreach {$ExportFunctions+=Get-ChildItem -Path function:$_}

    $ExportScriptFunction=@()
    $ExportScriptFunction=Get-ChildItem -Path function:\FunctInf*
    
    [Array]$ExportVariablesName="WmiParamArray","MaxWmiJob","VerboseStatus"
    $ExportVariables=@()
    $ExportVariablesName | foreach {$ExportVariables+=Get-Variable -Name $_}
  
    $HashtableParam=@{
    ImportFunctions=$ExportFunctions
    ImportScriptFunction=$ExportScriptFunction
    ImportVariables=$ExportVariables
    }           

}


}
process
{
$computers=@()
if ($Name -ne $null)
{
    $computers+=$Name                
}

$computers| foreach {
    $ComputerName=$_
    $CountComputers++
        $AllProperties | foreach {
                if (!$IsAdmin)
                {
                    if ($LocalComputer -eq $ComputerName)
                    {
                        if ($AdminRequired -eq $_)
                        {

                            Write-Warning "$ComputerName Information may be incomplete. The $_ property requires administrator privileges. Close powershell and run as administrator"
                        
                        }
                    }
                } 
        }
  
    if ($LocalComputer -eq $ComputerName)
    {
        Write-Verbose "$Computername running local"
        &$SbLocalHost  | OutResult        
    }
    elseif ($Protocol -eq "Wsman")
    {
    #Protocol WSMAN
        if ($MainJobs.count -ge $ProcessFor)
        {
        Start-Sleep -Milliseconds 20
            do{
                $repeat=$true
                GetPsJob | OutResult
                if ($MainJobs.Count -lt $ProcessFor)
                {
                    $repeat=$false
                }
                else
                {
                    Start-Sleep -Milliseconds 20
                }   
            }while($repeat)
        
        
        }
        
        $NewJob=StartPsJob -ComputerName $ComputerName -ScriptBlock $InvokeScriptBlock -ArgumentList $HashtableParam,$ComputerName -Credential $Credential
        if ($NewJob)
        {
            [void]$MainJobs.Add($NewJob)
        }
    }
    else
    {
    #Protocol DCOM
        if ($MainJobs.count -ge $ProcessFor)
        {
        Start-Sleep -Milliseconds 10
            do{
                $repeat=$true
                GetRunspaceJob | OutResult
                if ($MainJobs.Count -lt $ProcessFor)
                {
                    $repeat=$false
                }
                else
                {
                    Start-Sleep -Milliseconds 20
                }   
            }while($repeat)
        
        
        }
        
        Write-Verbose "$Computername StartRunspaceJob"
        $RunspaceJob=StartRunspaceJob -Computername $Computername -RunspacePool $RunspacePool
        if ($?)
        {
            [void]$MainJobs.Add($RunspaceJob)
        }
        
        
        
    }   
#End Foreach
}


}
end
{

if ($MainJobs.Count -eq 1 -and $LocalComputer -eq $MainJobs[0].location)
{
    Start-Sleep -Milliseconds 10
        do
        {
            GetPsJob | OutResult
      
        }
        while($MainJobs.Count -ne 0)
}
elseif ($Protocol -eq "Wsman" -and $MainJobs.Count -ne 0)
{
    Start-Sleep -Milliseconds 10
    do
    {
        GetPsJob | OutResult
      
    }
    while($MainJobs.Count -ne 0)  
}
elseif ($mainjobs.Count -ne 0)
{
    do
    {
        Start-Sleep -Milliseconds 10
        GetRunspaceJob | OutResult
    }
    while($MainJobs.Count -ne 0) 
    Write-Verbose "RunspacePool close"
    $RunspacePool.Close()
}

$Global:ErrorResult=$Global:ErrorResult | Sort-Object -Property Warning
if ($Global:ErrorResult -eq $null)
{
    $ErrResCount=0
}
elseif ($Global:ErrorResult.count -eq $null)
{
    $ErrResCount=1
}
else
{
    $ErrResCount=$Global:ErrorResult.count
}

$ResultCount=$Global:Result.count
if ($Global:Result.Count -eq 1)
{
    $Global:Result=$Global:Result | foreach {$_}
}
        
if ($ExecutionPolicyChanged)
{
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $CurrentExecutionPolicy -Force -Confirm:$false -ErrorAction SilentlyContinue
}
#Write-Verbose "Clear all failed wmi job"
#Get-Job | Where-Object {$_.State -eq "Failed"} | Remove-Job -Force
if ($ResultCount -gt 1)
{
    Write-Verbose  "Function running  $((New-TimeSpan -Start $BeginFunction).TotalSeconds) seconds" -Verbose
    Write-Verbose  "Total Computers   $CountComputers" -Verbose
    Write-Verbose  "Success           $ResultCount" -Verbose
    Write-Verbose  "Errors            $ErrResCount" -Verbose
}

#End Function
}




}