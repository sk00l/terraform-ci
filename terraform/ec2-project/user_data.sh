#!/bin/bash

# User data script for EC2 instance
# Environment: ${environment}
# Project: ${project}

set -e

# Update system
yum update -y

# Install basic packages
yum install -y \
    httpd \
    php \
    php-mysql \
    mysql \
    git \
    unzip \
    wget \
    curl \
    jq \
    aws-cli

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create basic web page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>SauravBhattarai EC2 Instance</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .info { margin: 20px 0; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SauravBhattarai EC2 Instance</h1>
            <p class="status">✅ Instance is running successfully!</p>
        </div>
        <div class="info">
            <h2>Instance Information</h2>
            <p><strong>Environment:</strong> ${environment}</p>
            <p><strong>Project:</strong> ${project}</p>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>Instance Type:</strong> <span id="instance-type">Loading...</span></p>
        </div>
        <div class="info">
            <h2>System Status</h2>
            <p><strong>Uptime:</strong> <span id="uptime">Loading...</span></p>
            <p><strong>Memory Usage:</strong> <span id="memory">Loading...</span></p>
            <p><strong>Disk Usage:</strong> <span id="disk">Loading...</span></p>
        </div>
    </div>
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/instance-type')
            .then(response => response.text())
            .then(data => document.getElementById('instance-type').textContent = data);
        
        // Update system info
        function updateSystemInfo() {
            fetch('/system-info.php')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('uptime').textContent = data.uptime;
                    document.getElementById('memory').textContent = data.memory;
                    document.getElementById('disk').textContent = data.disk;
                });
        }
        
        updateSystemInfo();
        setInterval(updateSystemInfo, 30000); // Update every 30 seconds
    </script>
</body>
</html>
EOF

# Create PHP script for system information
cat > /var/www/html/system-info.php << 'EOF'
<?php
header('Content-Type: application/json');

$uptime = shell_exec('uptime -p');
$memory = shell_exec('free -h | grep Mem | awk \'{print $3 "/" $2}\'');
$disk = shell_exec('df -h / | tail -1 | awk \'{print $5}\'');

echo json_encode([
    'uptime' => trim($uptime),
    'memory' => trim($memory),
    'disk' => trim($disk)
]);
?>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create CloudWatch configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/sauravbhattarai-${environment}",
                        "log_stream_name": "{instance_id}/httpd-access"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/sauravbhattarai-${environment}",
                        "log_stream_name": "{instance_id}/httpd-error"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/sauravbhattarai-${environment}",
                        "log_stream_name": "{instance_id}/system"
                    }
                ]
            }
        }
    },
    "metrics": {
        "metrics_collected": {
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Create a simple health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

# Log the completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log 