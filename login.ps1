#Get the IP address --------------------------------------------------------------------------------------
$ipaddress = $(ipconfig | where {$_ -match 'IPv4.+\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' } | out-null; $Matches[1])

#Get the Chassis Type ------------------------------------------------------------------------------------
$ChassisType = (Get-CimInstance -ClassName Win32_SystemEnclosure).ChassisTypes
$ChassisType = switch ($ChassisType)
{
            1          {'Other'; break}
          2          {'Unknown'; break}
          3          {'Desktop'; break}
          4          {'Desktop'; break}
          5          {'Desktop'; break}
          6          {'Desktop'; break}
          7          {'Desktop'; break}
          8          {'Laptop'; break}
          9          {'Laptop'; break}
          10         {'Laptop'; break}
          11         {'Laptop'; break}
          12         {'Laptop'; break}
          13         {'Desktop'; break}
          14         {'Laptop'; break}
          15         {'Desktop'; break}
          16         {'Desktop'; break}
          17         {'Server'; break}
          18         {'Desktop'; break}
          19         {'Desktop'; break}
          20         {'Desktop'; break}
          21         {'Server'; break}
          22         {'Server'; break}
          23         {'Server'; break}
          24         {'Desktop'; break}
         Default     {"Unknown"}
         
}


#Get the Username & computer name ------------------------------------------------------------------
$CompName = $env:COMPUTERNAME
$UserName = $env:USERNAME

#Get PC info (ram, os, cpu -------------------------------------------------------------------------
$ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
$cpu = (Get-WmiObject -Class Win32_Processor | Select-Object -Property Name).Name
$os = (Get-WMIObject win32_operatingsystem).caption

#Get Teamviewer ID --------------------------------------------------------------------------------
$TeamViewerVersions = @('6','7','8','9','10','11','12','13','14','')
foreach ($v in $TeamViewerVersions) {
    If ((Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer -ErrorAction SilentlyContinue) -ne $null) {
        $TVID=(Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TeamViewer).GetValue('ClientID')

    } ElseIf ((Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TeamViewer$v -ErrorAction SilentlyContinue) -ne $null) {
        $TVID=(Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TeamViewer$v).GetValue('ClientID')

    }
}


#Get Local Users (Array) -------------------------------------------------------------------------
$localusers = Get-LocalUser | where {$_.Enabled -eq $true} | Select Name












#Send data to DATABASE--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$contentType = 'application/x-www-form-urlencoded' 

#Send Local users----------------------------------------------------------------------------
foreach ($un in $localusers) {
    $site = "http://itdb/scripts/localuser.php"
    $body = "cn=" + $CompName + "&localuser=" + $un.Name
    #write-host $un.Name
    $res = Invoke-WebRequest $site -Method POST -body $body -ContentType $contentType;
}


#Send computer data----------------------------------------------------------------------------
$site = "http://itdb/scripts/sql.php"
$body = "un=" + $UserName + "&cn=" + $CompName + "&log=Logon" + "&ram=" + $ram + "&os=" + $os + "&cpu=" + $cpu + "&tvid=" + $TVID + "&platform=" + $ChassisType + "&IP=" + $ipaddress

$res = Invoke-WebRequest $site -Method POST -body $body -ContentType $contentType;
