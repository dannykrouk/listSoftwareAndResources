# Exports a list of software installed, running services, processor information, memory information, volume information, ODBC drivers, and ODBC Dsns on the target machine
# (default is localhost)
#
# Usage Example
# .\list_software_and_resources.ps1 
# .\list_software_and_resources.ps1 "ps0008426.esri.com" 
# 
# Should be run as the machine administrator ("as administrator")

param	(
		[Parameter(Position=0)][string]$machine="localhost"
		)

if ($machine -eq "localhost")
{
    $machineName = hostname
}
else
{
    $machineName = $machine
}

Get-WmiObject -ComputerName $machineName -Class Win32_Product | select-object -property name,version | Export-Csv "$($machineName)_installed_software.csv" -NoTypeInformation
Get-WmiObject -ComputerName $machineName -Class Win32_Processor | select-object -property name,numberofcores,numberoflogicalprocessors | Export-Csv "$($machineName)_processors.csv"  -NoTypeInformation
Get-WmiObject -ComputerName $machineName -Class Win32_PhysicalMemory | select-object -property name,capacity | Export-Csv "$($machineName)_memory.csv" -NoTypeInformation
get-service -computername $machineName | Where{$_.Status -eq "Running"} | select-object -Property Name, DisplayName, ServiceName, Status, StartType | Export-Csv "$($machineName)_running_services.csv" -NoTypeInformation

if ($machine -eq "localhost")
{

    Get-OdbcDriver | select-object -Property Name, Platform | Export-Csv "$($machineName)_odbcdrivers.csv" -NoTypeInformation
    Get-OdbcDsn | select-object -Property DriverName, DsnType, Name, Platform | Export-Csv "$($machineName)_odbcdsns.csv" -NoTypeInformation
    get-volume | select-object -Property HealthStatus, DriveType, FileSystemType, AllocationUnitSize, DriveLetter, FileSystem, FileSystemLabel, Size, SizeRemaining | Export-Csv "$($machineName)_volumes.csv"  -NoTypeInformation
}
else
{
    $sess = New-CimSession -ComputerName $machine
    Get-OdbcDriver -CimSession $sess  | select-object -Property Name, Platform | Export-Csv "$($machine)_odbcdrivers.csv" -NoTypeInformation
    Get-OdbcDsn -CimSession $sess  | select-object -Property DriverName, DsnType, Name, Platform | Export-Csv "$($machine)_odbcdsns.csv" -NoTypeInformation
    get-volume -CimSession $sess  | select-object -Property HealthStatus, DriveType, FileSystemType, AllocationUnitSize, DriveLetter, FileSystem, FileSystemLabel, Size, SizeRemaining | Export-Csv "$($machine)_volumes.csv"  -NoTypeInformation
}
