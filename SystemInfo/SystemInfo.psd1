#
# Манифест модуля для модуля "SystemInfo".
#
# Создано: Gavrilyuk S.A
#
# Дата создания: 13.02.2018
#

@{

# Файл модуля сценария или двоичного модуля, связанный с этим манифестом.
# RootModule = ''

# Номер версии данного модуля.
ModuleVersion = '1.0.4'

# Уникальный идентификатор данного модуля
GUID = '8225660c-fa83-4d1f-926e-cddedb0aa736'

# Автор данного модуля
Author = 'Gavrilyuk S.A'

# Компания, создавшая данный модуль, или его поставщик
CompanyName = 'Неизвестно'

# Заявление об авторских правах на модуль
Copyright = '(c) 2017 Gavrilyuk S.A.'

# Описание функций данного модуля
Description = '
The function allows you to quickly get the system information of a large number of computers on the network

Function allows you to use protocols DCOM or WSMAN

The function uses WMI to collect information related to the characteristics of the computer


The function uses multithreading. 
Multithreading is implemented through powershell runspace and PsJob

After executing, two variables are created: 

$Result-contains successful queries, 

$ErrorResult-contains computers that have errors.'

# Минимальный номер версии обработчика Windows PowerShell, необходимой для работы данного модуля
PowerShellVersion = '2.0'

# Имя узла Windows PowerShell, необходимого для работы данного модуля
# PowerShellHostName = ''

# Минимальный номер версии узла Windows PowerShell, необходимой для работы данного модуля
# PowerShellHostVersion = ''

# Минимальный номер версии Microsoft .NET Framework, необходимой для данного модуля
# DotNetFrameworkVersion = ''

# Минимальный номер версии среды CLR (общеязыковой среды выполнения), необходимой для работы данного модуля
# CLRVersion = ''

# Архитектура процессора (нет, X86, AMD64), необходимая для этого модуля
# ProcessorArchitecture = ''

# Модули, которые необходимо импортировать в глобальную среду перед импортированием данного модуля
# RequiredModules = @()

# Сборки, которые должны быть загружены перед импортированием данного модуля
# RequiredAssemblies = @()

# Файлы сценария (PS1), которые запускаются в среде вызывающей стороны перед импортом данного модуля.
# ScriptsToProcess = @()

# Файлы типа (.ps1xml), которые загружаются при импорте данного модуля
# TypesToProcess = @()

# Файлы формата (PS1XML-файлы), которые загружаются при импорте данного модуля
FormatsToProcess = 'SystemInfo.Format.ps1xml'

# Модули для импорта в качестве вложенных модулей модуля, указанного в параметре RootModule/ModuleToProcess
NestedModules = 'SystemInfo.psm1'

# Командлеты для экспорта из данного модуля
#CmdletsToExport = '*'

# Переменные для экспорта из данного модуля
VariablesToExport = '*'

# Псевдонимы для экспорта из данного модуля
#AliasesToExport = '*'

# Ресурсы DSC для экспорта из этого модуля
# DscResourcesToExport = @()

# Список всех модулей, входящих в пакет данного модуля
# ModuleList = @()

# Список всех файлов, входящих в пакет данного модуля
# FileList = @()

# Личные данные для передачи в модуль, указанный в параметре RootModule/ModuleToProcess. Он также может содержать хэш-таблицу PSData с дополнительными метаданными модуля, которые используются в PowerShell.
PrivateData = @{

    PSData = @{

        # Теги, применимые к этому модулю. Они помогают с обнаружением модуля в онлайн-коллекциях.
        Tags = @('Hardware', 'Software', 'Report', 'Reporting', 'Inventory')

        # URL-адрес лицензии для этого модуля.
        LicenseUri = 'https://github.com/SAGSA/SystemInfo/blob/master/LICENSE'

        # URL-адрес главного веб-сайта для этого проекта.
        ProjectUri = 'https://github.com/SAGSA/SystemInfo'

        # URL-адрес значка, который представляет этот модуль.
        # IconUri = ''

        # Заметки о выпуске этого модуля
        ReleaseNotes = @' 

## 1.0.4 
 
*  Fixed not responding function. When using the Dcom protocol, in some cases it was possible to hang the function
*  Fixed bug with credentials in powershell 2
*  Added CheckVulnerabilities parameter (Meltdown&Spectre, EternalBlue)
*  Added AntivirusStatus property


## 1.0.3

*  Added parameter Protocol. Defines the connection protocol to remote machine (Dcom, Wsman)
*  The parameter MaxJob is replaced by the parameter ProcessFor.ProcessFor parameter Determines the maximum number of computers for which WMI operations can be executed simultaneously
*  Removed RegistryKey, RegistryValue, RegistryValueType, ShowStatistics parameter
'@

    } # Конец хэш-таблицы PSData

} # Конец хэш-таблицы PrivateData

# Код URI для HelpInfo данного модуля
# HelpInfoURI = ''

# Префикс по умолчанию для команд, экспортированных из этого модуля. Переопределите префикс по умолчанию с помощью команды Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

