$multicastAddress = '239.0.0.1'
$port = 123

$udpClient = New-Object System.Net.Sockets.UdpClient
$multicastEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($multicastAddress), $port)

while ($true) {
    Write-Host "Enter your message: " -NoNewline
    $messageToSend = Read-Host

    if ($messageToSend -ne "") {
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($messageToSend)
        $udpClient.Send($bytes, $bytes.Length, $multicastEndpoint)
        Write-Host "You: $messageToSend"
    }
}
