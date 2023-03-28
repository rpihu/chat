$multicastAddress = '239.0.0.1'
$port = 123

$udpClient = New-Object System.Net.Sockets.UdpClient($port)
$multicastEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($multicastAddress), $port)
$udpClient.JoinMulticastGroup($multicastEndpoint.Address)
$udpClient.Client.ReceiveTimeout = 1000

Write-Host "Press Ctrl+C to stop the listener"

try {
    while ($true) {
        $sender = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        try {
            $bytes = $udpClient.Receive([ref]$sender)
            $message = [System.Text.Encoding]::ASCII.GetString($bytes)
            Write-Host "[$($sender.Address)] $message"
        } catch [System.Net.Sockets.SocketException] {
            if ($_.Exception.ErrorCode -ne 10060) { # WSAETIMEDOUT
                throw
            }
        }
    }
} catch {
    $udpClient.Close()
    Write-Host "Listener stopped"
}
