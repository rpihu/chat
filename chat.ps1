$multicastAddress = '239.0.0.1'
$port = 123

$udpClient = New-Object System.Net.Sockets.UdpClient($port)
$multicastEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($multicastAddress), $port)
$udpClient.JoinMulticastGroup($multicastEndpoint.Address)
$udpClient.Client.ReceiveTimeout = 1000

$receiveTask = [System.Threading.Tasks.Task]::Run({
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
})

Write-Host "Press Ctrl+C to stop the chat"

while ($true) {
    Write-Host "Enter your message: " -NoNewline
    $messageToSend = Read-Host

    if ($messageToSend -ne "") {
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($messageToSend)
        $udpClient.Send($bytes, $bytes.Length, $multicastEndpoint)
        Write-Host "You: $messageToSend"
    }
}

