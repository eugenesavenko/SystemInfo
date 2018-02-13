#Default Information (information output when executed Get-SystemInfo without parameters)
$DefaultInfoConfig=@(
"OsCaption","OsArchitecture","OsUpTime","OsLoggedInUser","CPUName","MotherboardModel","DeviceModel","MemoryTotal","MemoryModules","HddDevices","VideoModel","MonitorName","CdRom"
)
#FunctionConfig
$FunctionConfig=@{

#Os section

OsVersion=          '-Class Win32_OperatingSystem -Property Version'
OsCaption=          '-Class Win32_OperatingSystem -Property Caption'
OSArchitecture=     '-Class Win32_OperatingSystem -Property OSArchitecture'
OsInstallDate=      '-Class Win32_OperatingSystem -Script OS\OsInstallDate.ps1'
OsUpTime=           '-Class Win32_OperatingSystem -Script OS\OsUptime.ps1 '
OsProductKey=       '-Class StdRegProv            -Script OS\OsProductKey.ps1'
OsLoggedInUser=     '-Class Win32_ComputerSystem  -Property UserName'
OsAdministrators=   '-Class Win32_OperatingSystem -Script OS\OsAdministrators.ps1'
OsActivationStatus= '-Query Select * From SoftwareLicensingProduct Where ApplicationID = "55c92734-d682-4d71-983e-d6ec3f16059f" And Licensestatus > 0 -Script OS\OsActivationStatus.ps1'
AntivirusStatus=    '-Class Win32_OperatingSystem -Script OS\AntivirusStatus.ps1'

#Memory section

MemoryTotal=        '-Class Win32_PhysicalMemory      -Script Memory\MemoryTotal.ps1'
MemoryAvailable=    '-Class Win32_OperatingSystem     -Script Memory\MemoryAvailable.ps1'
MemoryFree=         '-Class Win32_OperatingSystem     -Script Memory\MemoryFree.ps1'                           
MemoryModules=      '-Class Win32_PhysicalMemory      -Script Memory\MemoryModules.ps1'
MemoryModInsCount=  '-Class Win32_PhysicalMemory      -Script Memory\MemoryModInsCount.ps1'
MemoryMaxIns=       '-Class Win32_PhysicalMemoryArray -Script Memory\MemoryMaxIns.ps1'
MemorySlots=        '-Class Win32_PhysicalMemoryArray -Script Memory\MemorySlots.ps1'
ECCType=            '-Class Win32_PhysicalMemoryArray -Script Memory\ECCType.ps1'

#GPU section

VideoModel=         '-Class Win32_VideoController -Script gpu\VideoModel.ps1'
VideoRam=           '-Class Win32_VideoController -Script gpu\VideoRamMb.ps1'
VideoProcessor=     '-Class Win32_VideoController -Script gpu\VideoProcessor.ps1'

#CPU section

CPUName=            '-Class Win32_Processor -Property Name'
CPUSocket=          '-Class Win32_Processor -Property SocketDesignation'
MaxClockSpeed=      '-Class Win32_Processor -Property MaxClockSpeed'
CPUCores=           '-Class Win32_Processor -Property NumberOfCores'
CPULogicalCore=     '-Class Win32_Processor -Property NumberOfLogicalProcessors'
CPULoad=            '-Class Win32_Processor -Property LoadPercentage'

#Motherboard section

Motherboard=        '-Class win32_baseboard      -Property Manufacturer'
MotherboardModel=   '-Class Win32_BaseBoard      -Property Product'
DeviceModel=        '-Class Win32_Computersystem -Property model'

#Monitor section

MonitorManuf=       '-Class wmiMonitorID -Script Monitor\MonitorManuf.ps1'
MonitorPCode=       '-Class wmiMonitorID -Script Monitor\MonPCode.ps1'
MonitorSN=          '-Class wmiMonitorID -Script Monitor\MonSn.ps1'
MonitorName=        '-Class wmiMonitorID -Script Monitor\MonName.ps1'
MonitorYear=        '-Class wmiMonitorID -Property YearOfManufacture'

#Network section

NetworkAdapters=    '-Class Win32_NetworkAdapterConfiguration -Script Network\NetworkAdapters.ps1'
NetPhysAdapCount=   '-Class Win32_NetworkAdapter              -Script Network\NetPhysAdapCount.ps1'

#Printer section

Printers=           '-Class Win32_Printer -Script Printer\Printers.ps1'
UsbConPrCount=      '-Class Win32_Printer -Script Printer\UsbConPrCount.ps1'
IsPrintServer=      '-Class Win32_Printer -Script Printer\IsPrintServer.ps1'
UsbConPrOnline=     '-Class Win32_Printer -Script Printer\UsbConPrOnline.ps1'

#CDROM Section

Cdrom=              '-Class Win32_CDROmDrive -Property Caption'
CdromMediatype=     '-Class Win32_CDROMDrive -Property MediaType'

#UsbDevice section

UsbDevices=         '-Class Win32_USBControllerDevice -Script UsbDevice\UsbDevice.ps1'

#Software section

SoftwareList=       '-Class StdRegProv -Script Software\SoftwareList.ps1'

#Hdd section

HddDevices=         '-Class Win32_DiskDrive,MSStorageDriver_FailurePredictStatus,MSStorageDriver_FailurePredictData -Script Storage\HddDevices.ps1'
HDDSmart=           '-Class MSStorageDriver_FailurePredictStatus,MSStorageDriver_FailurePredictData,Win32_DiskDrive -Script Storage\HddSmart.ps1'
HddSmartStatus=     '-Class MSStorageDriver_FailurePredictStatus,MSStorageDriver_FailurePredictData,Win32_DiskDrive -Script Storage\HddSmartStatus.ps1'

#Vulnerabilities section

MeltdownSpectreStatus='-Class Win32_OperatingSystem,StdRegProv,Win32_Processor,Win32_QuickFixEngineering   -Script Vulnerabilities\MeltdownSpectreStatus.ps1'
EternalBlueStatus=    '-Class Win32_OperatingSystem,Win32_QuickFixEngineering,StdRegProv                   -Script Vulnerabilities\EternalBlueStatus.ps1'
#End config
}

$ManualNamespace=@{
wmiMonitorID='-Namespace Root\wmi'
MSStorageDriver_FailurePredictStatus='-Namespace Root\wmi'
MSStorageDriver_FailurePredictData='-Namespace Root\wmi'
StdRegProv='-Namespace ROOT\default'
}

#End FunctionConfig
#################################################################################################################################
#Config Switch Param

$SwitchConfig=@{
OSInfo="OsVersion","OSArchitecture","OsCaption","OsInstallDate","OsUpTime","OsLoggedInUser","OsActivationStatus","OsAdministrators","AntivirusStatus"
Cpu="CPUName","CPUSocket","MaxClockSpeed","CPUCores","CPULogicalCore","CPULoad"
Hdd="HddDevices"
Motherboard="Motherboard","MotherboardModel","DeviceModel"
Memory="MemoryTotal","MemoryFree","MemoryModules","MemoryMaxIns","MemorySlots","MemoryAvailable","MemoryModInsCount","ECCType"
Video="VideoModel","VideoRam","VideoProcessor"
Monitor="MonitorManuf","MonitorName","MonitorPCode","MonitorSN","MonitorYear"
NetworkAdapter="NetworkAdapters","NetPhysAdapCount"
PrinterInfo="Printers","UsbConPrCount","IsPrintServer","UsbConPrOnline"
UsbDevices="UsbDevices"
SoftwareList="SoftwareList"
CheckVulnerabilities="OsCaption","OsLoggedInUser","MeltdownSpectreStatus","EternalBlueStatus"
}

#Exclude switch Param
$ExcludeParam="Verbose","AppendToResult","Debug"
#End Config Switch Param

#################################################################################################################################
#Other param
$LocalComputer=$env:COMPUTERNAME,"Localhost","127.0.0.1"
$AdminRequired="HDDSmart","HddDevices","HddSmartStatus"
$RequiredExecutionPolicy="Unrestricted","RemoteSigned"