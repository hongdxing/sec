param(
    [String]$target = '',
    [String[]]$ports 
)

if ( $target -eq ''){
    echo 'missing -target'
    return
}

if ( $ports.Length -eq 0 ){
    $ports = 22, 45, 80, 443, 8080
} elseif( $ports.Length -eq 1 -and $ports[0] -eq 0 ){
    $ports = 1..65535
}

echo "target: $target"
<#
foreach($port in $ports){
    $result = Test-NetConnection $target -port $port 3>null

    if( $result.TcpTestSucceeded -eq 'True'){
        echo $port
    }
}
#>

$ports | %{

    $script={
        param($target, $port) 
        $result = Test-NetConnection $target -port $port -WA 0 
	#echo $result
        if( $result.TcpTestSucceeded -eq 'True' ){
            echo "[v] $port"
        }
    }
    $null=Start-Job $script -ArgumentList $target, $_ 
}
$jobs = Get-Job 
$jobCount = $jobs | where { $_.state -eq 'Running'} | measure 
While ($jobCount.count -gt 0) {
    Start-Sleep 2
    $jobs = Get-Job 
    $jobCount = $jobs | where { $_.state -eq 'Running'} | measure
}
# Display output from all jobs
Get-Job | Receive-Job

# Cleanup
Remove-Job *
