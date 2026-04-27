
<#
================================================================================
Script Name  : Printer SNMP Report Generator
Author       : Ramanjaneyulu Butharaju (@RamB)
Description  :
    This PowerShell script collects printer information using SNMP queries
    and generates a structured HTML report.

    It retrieves key details such as Printer Name, Model, Serial Number,
    and Page Count (meter readings) from network printers across multiple
    locations.

Features     :
    - SNMP-based data collection from printers
    - Supports multiple locations (e.g., Hyderabad, Mumbai)
    - Retrieves printer name, model, serial number, and page count
    - Handles errors gracefully for unreachable devices
    - Generates clean HTML report with tables
    - Easy to view in any web browser

Requirements :
    - SNMP-enabled printers
    - PowerShell SNMP module (Get-SnmpData command available)
    - Network connectivity to printer IPs

Output       :
    - HTML report file containing printer details
    - Includes separate sections per location

Usage        :
    - Update printer IP lists as needed
    - Ensure SNMP OIDs are correct for your environment
    - Run the script to generate the report
    - Open the HTML file in a browser

================================================================================
#>



# Define the printer IPs for each location
$hyderabadPrinters = @(

"10.176.172.14",
"10.176.164.95"
)

$mumbaiPrinters = @(

"10.178.112.61",
"10.180.38.143"

)

# Define the OIDs
$oids = @{
    PrinterName  = ".1.3.6.1.4.1.367.3.2.1.7.3.5.1.1.2.1.1"
    Model        = ".1.3.6.1.2.1.25.3.2.1.3.1"
    SerialNumber = ".1.3.6.1.2.1.43.5.1.1.17.1"
    PageCount    = ".1.3.6.1.2.1.43.10.2.1.4.1.1"
}

# Function to get SNMP data from a printer
function Get-SNMPData {
    param (
        [string]$IP,
        [string]$OID
    )
    try {
        $result = Get-SnmpData -IPAddress $IP -OID $OID
       # Write-Output "Retrieved data from $IP for OID $OID: $($result.Value)"
        return $result.Value
    }
    catch {
       # Write-Output "Error retrieving data from $IP for OID $OID: $($_)"
        return "Error"
    }
}

# Function to create HTML table rows for printers
function Get-PrinterHTML {
    param (
        [array]$printers,
        [hashtable]$oids
    )
    $html = ""
    foreach ($printer in $printers) {
        $printerName  = Get-SNMPData -IP $printer -OID $oids.PrinterName
        $model        = Get-SNMPData -IP $printer -OID $oids.Model
        $serialNumber = Get-SNMPData -IP $printer -OID $oids.SerialNumber
        $pageCount    = Get-SNMPData -IP $printer -OID $oids.PageCount
        
        $html += "<tr>"
        $html += "<td>$printer</td>"
        $html += "<td>$printerName</td>"
        $html += "<td>$model</td>"
        $html += "<td>$serialNumber</td>"
        $html += "<td>$pageCount</td>"
        $html += "</tr>"
    }
    return $html
}

# Generate HTML report
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Printer Report</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Printer Report - Hyderabad</h1>
    <table>
        <tr>
            <th>IP Address</th>
            <th>Printer Name</th>
            <th>Model</th>
            <th>Serial Number</th>
            <th>Page Count</th>
        </tr>
        $(Get-PrinterHTML -printers $hyderabadPrinters -oids $oids)
    </table>

    <h1>Printer Report - Mumbai</h1>
    <table>
        <tr>
            <th>IP Address</th>
            <th>Printer Name</th>
            <th>Model</th>
            <th>Serial Number</th>
            <th>Page Count</th>
        </tr>
        $(Get-PrinterHTML -printers $mumbaiPrinters -oids $oids)
    </table>
</body>
</html>
"@

# Save the HTML report to a file
$reportPath = "C:\Users\Ram\Desktop\Old Laptop backups\Python Scripts\Python\metercounts.ps1\PrinterReportV5.html"
$html | Out-File -FilePath $reportPath -Encoding utf8

Write-Output "Report generated: $reportPath"
