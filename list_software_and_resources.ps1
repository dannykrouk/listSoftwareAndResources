# Exports a list of software installed, processor information, memory information, ODBC drivers, and ODBC Dsns on the target machine
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


Get-WmiObject -ComputerName $machine -Class Win32_Product | select-object -property name,version | Export-Csv "$($machine)_installed_software.csv" -NoTypeInformation
Get-WmiObject -ComputerName $machine -Class Win32_Processor | select-object -property name,numberofcores,numberoflogicalprocessors | Export-Csv "$($machine)_processors.csv"  -NoTypeInformation
Get-WmiObject -ComputerName $machine -Class Win32_PhysicalMemory | select-object -property name,capacity | Export-Csv "$($machine)_memory.csv" -NoTypeInformation

if ($machine -eq "localhost")
{
    Get-OdbcDriver | select-object -Property Name, Platform | Export-Csv "$($machine)_odbcdrivers.csv" -NoTypeInformation
    Get-OdbcDsn | select-object -Property DriverName, DsnType, Name, Platform | Export-Csv "$($machine)_odbcdsns.csv" -NoTypeInformation
}
else
{
    $sess = New-CimSession -ComputerName $machine
    Get-OdbcDriver -CimSession $sess  | select-object -Property Name, Platform | Export-Csv "$($machine)_odbcdrivers.csv" -NoTypeInformation
    Get-OdbcDsn -CimSession $sess  | select-object -Property DriverName, DsnType, Name, Platform | Export-Csv "$($machine)_odbcdsns.csv" -NoTypeInformation
}
