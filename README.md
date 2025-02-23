# COTURN Server Setup Script

A bash script for easy installation and configuration of a COTURN server. This script helps you set up a STUN/TURN server with basic authentication and no SSL.

## Features

- Simple interactive installation
- Basic STUN/TURN server configuration
- No SSL/TLS (suitable for basic setups)
- Automatic firewall configuration
- User credential management
- Uses IP as realm

## Requirements

- Ubuntu/Debian based system
- Root privileges
- Internet connection for package installation

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/coturn-setup.git
```

2. Make the script executable:
```bash
chmod +x coturn-setup.sh
```

3. Run the script:
```bash
sudo ./coturn-setup.sh
```

## Usage

The script provides an interactive menu with the following options:

1. Install COTURN
   - Updates system packages
   - Installs COTURN server
   - Enables the service

2. Configure COTURN
   - Sets server IP address
   - Creates user credentials
   - Configures firewall rules
   - Generates configuration file

3. Exit

## Configuration Details

The script will configure COTURN with:
- STUN/TURN ports: 3478 (UDP/TCP)
- Alternative port: 5349
- UDP relay ports: 49152-65535
- No TLS/DTLS encryption
- Simple logging
- Basic authentication

## Output Example

After configuration, you'll receive:
```
Access Information:
----------------------------------------
STUN Server       : stun:YOUR_IP:3478
TURN Server       : turn:YOUR_IP:3478

Username         : your_username
Password         : your_password
Realm           : YOUR_IP

Supported Protocols:
- STUN/TURN UDP    : Port 3478
- STUN/TURN TCP    : Port 3478
----------------------------------------
```

## Security Note

This script configures COTURN without SSL/TLS encryption. It's suitable for basic testing or development environments. For production use, consider adding proper SSL/TLS configuration.

## Contributing

Feel free to fork the repository and submit pull requests for any improvements.

## License

MIT License - feel free to use and modify as needed.
