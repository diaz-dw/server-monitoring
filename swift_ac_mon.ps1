# PS scriptlet looking forward to monitoring the network TCP connection to the SWIFT server net socket used by the ...
# (c) douglas.diaz@
# Dec-2022
# Jan-2023
# Tested only with Powershell 5.1

# The Tbot net socket must be reachable previously for this script to work

$PSDefaultParameterValues['Test-NetConnection:InformationLevel'] = 'Quiet'


$SWIFTsrvAddr=""
$SWIFTsrvPort="443"


# FIRST test: Is the remote socket open and reachable?
# This can be manually tested by using the following cmdlet in a Window$ Server PS console:
## tnc 149.134.170.9 -port 443
$Result = Test-NetConnection $SWIFTsrvAddr -Port $SWIFTsrvPort -ErrorAction SilentlyContinue -WarningVariable TestWarn -ErrorVariable TestError 3> $null

If ($TestError) {
    $Result = Invoke-WebRequest -Uri http://172.16.99.144/tbot/tbot.php?from=$env:COMPUTERNAME"&"msg=CRIT:+Connection+test+to+SWIFT+socket+endpoint+failed! -Method 'Get'
	# Restarting the service here is not useful!
    exit 1
}


# SECOND test: Is the connection from local client to remote server?
# From: https://learn.microsoft.com/en-us/answers/questions/230227/time-wait-from-netstat.html
## TCP TIME_WAIT is a normal TCP protocol operation, it means after delivering the last FIN-ACK, client side will wait for double maximum segment life (MSL) Time to pass to be sure the
## remote TCP received the acknowledgement of its connection termination request. By default, MSL is 2 minutes. For the maximum, it can stay in TIME_WAIT for 4 minutes known as two MSL.
## ...
## From Network perspective, TCP TIME_WAIT status is just a normal behavior that after closing the session, TCP stack will hold the high port for little more time to ensure the other 
## side receive the last FIN-ACK packet and no more data will be received in this conversation. TIME_WAIT is not the problem. I would suggest you focus on RPC error for this issue.
$Result =  Get-NetTCPConnection | 
            ##Where-Object {($_.State -eq "Established") -or ($_.State -eq "TimeWait")} |
			Where-Object {($_.State -eq "Established")} |
            Where-Object { $_.RemoteAddress -eq $SWIFTsrvAddr} |
                Select-Object $SWIFTsrvPort

if ([string]::IsNullOrEmpty($Result)) {
	& "C:\Program Files (x86)\SWIFT\Alliance Lite2\bin\SwiftAutoClientMonitor.exe" -start
	
	Start-Sleep -Seconds 30

	$Result =  Get-NetTCPConnection | Where-Object {($_.State -eq "Established") -or ($_.State -eq "TimeWait")} | Where-Object {$_.RemoteAddress -eq $SWIFTsrvAddr} | Select-Object $SWIFTsrvPort
	if ([string]::IsNullOrEmpty($Result)) {	
		$Result = Invoke-WebRequest -Uri http://172.16.99.144/tbot/tbot.php?from=$env:COMPUTERNAME"&"msg=WARN:+autoclient+TCP+connection+to+SWIFT+server+not+established:+Sending+a+start+through+SwiftAutoClientMonitor+did+not+work! -Method 'Get'
	}
	
	#Stop-Service "SWIFT Autoclient Service"
	#Start-Sleep -Seconds 30
    #Start-Service "SWIFT Autoclient Service"
	#Start-Sleep -Seconds 30
	
	# We shoudn't exit here in order to check the service status (after having it restarted) below
	# exit 2
}


$isSvcRunning = Get-Service "SWIFT Autoclient Service" | Where-Object {$_.Status -EQ "Running"}
if ([string]::IsNullOrEmpty($isSvcRunning)) {
	$Result = Invoke-WebRequest -Uri http://172.16.99.144/tbot/tbot.php?from=$env:COMPUTERNAME"&"msg=CRIT:+The+autoclient+Windows+service+is+not+running -Method 'Get'
	
	exit 3
}


# Everything OK
exit 0
