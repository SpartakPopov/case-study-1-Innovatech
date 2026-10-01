# Opens an SSM port-forwarding tunnel to the monitoring server.
#   .\scripts\monitoring-tunnel.ps1               -> Grafana    on http://localhost:3000
#   .\scripts\monitoring-tunnel.ps1 prometheus    -> Prometheus on http://localhost:9090
# Leave it running while you use the browser; Ctrl+C closes the tunnel.
param(
    [ValidateSet("grafana", "prometheus")]
    [string]$Service = "grafana"
)

$region = "eu-central-1"
$port = if ($Service -eq "prometheus") { 9090 } else { 3000 }

# Look the instance up by its Name tag, because the ID changes on every rebuild
$id = aws ec2 describe-instances --region $region `
    --filters "Name=tag:Name,Values=innovatech-monitoring" "Name=instance-state-name,Values=running" `
    --query "Reservations[0].Instances[0].InstanceId" --output text

if (-not $id -or $id -eq "None") {
    Write-Error "No running innovatech-monitoring instance found. Is the environment deployed, and are you logged in (aws sso login)?"
    exit 1
}

Write-Host "Tunnel to $Service on $id - open http://localhost:$port (Ctrl+C to stop)"
aws ssm start-session --region $region --target $id `
    --document-name AWS-StartPortForwardingSession `
    --parameters "portNumber=$port,localPortNumber=$port"
