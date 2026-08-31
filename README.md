# MulTCPlex

A lightweight TCP multiplexer that accepts incoming client connections and broadcasts their data to multiple backend servers. 
Written in Elixir for high performance and reliability.

## Overview

MulTCPlex acts as a middleware between clients and multiple backend servers. When a client connects and sends data, MulTCPlex:

1. Receives the data from the client
2. Broadcasts it to all configured backend servers for that client
3. Returns an "ok" acknowledgment to the client

**Important:** Clients receive only the acknowledgment from MulTCPlex, not the responses from backend servers.

## Installation

> [!IMPORTANT]
> Pre-built binaries are available only for Linux until v1.0, due to issues with burrito library. 
> For other platforms, you can run it using Elixir interpreter.

```bash
curl -fsSL https://raw.githubusercontent.com/Dodgemaster1/MulTCPlex/main/scripts/install.sh | sh
```

### Verify Installation

After installation, verify that MulTCPlex is correctly installed by checking the version:

```bash
multcplex --version
```

## Configuration

MulTCPlex is configured using a YAML file. By default, it looks for `config.yaml` in the current directory, 
but you can specify a different path using the `-c` or `--config` command-line option.

### Configuration File Structure

```yaml
# List of client configurations (minimum 1)
clients:
  - port: 6561                          # [Required] Unique network port for the client (1-65535)
    
    allowed_ips:                        # [Optional] List of allowed IPv4 addresses
      - 192.168.8.200                   # If omitted, all IPs are allowed. Default: []
      - 192.168.8.166
    
    timeout: 300                        # [Optional] Connection timeout in seconds. Default: 300
    
    name: "main-client"                 # [Optional] Human-readable client name for logging. Default: ""
    
    # [Required] List of target servers connected to this client (minimum 1)
    servers:
      - host: 192.168.8.200             # [Required] IP address or hostname of the target server
        port: 6566                      # [Required] Port of the target server (1-65535)
        name: "testserver1"             # [Optional] Server identifier name. Default: ""
      
      - host: 192.168.8.200
        port: 6567
        name: "testserver2"
```

### Minimal Configuration

If you want a minimal setup, here's the bare minimum required:

```yaml
clients:
  - port: 6561
    servers:
      - host: 192.168.8.200
        port: 6566
      - host: 192.168.8.200
        port: 6567
```

## Command Line Interface

### Basic Usage

```bash
multcplex [options] [subcommands]
```

### Global Options

- **`--help`**  
  Display the help message with available options and subcommands.
  
  ```bash
  multcplex --help
  ```

- **`--version`**  
  Display the version information and author details.
  
  ```bash
  multcplex --version
  ```

### Configuration Options

- **`-c, --config CONFIG`** (optional)  
  Path to the YAML configuration file.  
  Default: `config.yaml`

  Example:
  ```bash
  multcplex -c /etc/multcplex/config.yaml
  multcplex --config ./custom-config.yaml
  ```

### Subcommands

- **`update`**  
  Automatically update MulTCPlex to the latest version.  

  ```bash
  multcplex update
  ```

#### Update Command Requirements

The `update` command has different requirements depending on your operating system:

**Linux/macOS:**
- `curl` - Command-line tool for downloading files
- `sh` - Standard POSIX shell

These are typically pre-installed on most Linux and macOS systems. If not available, install them:

```bash
# macOS
brew install curl

# Ubuntu/Debian
sudo apt-get install curl
```

**Windows:**
- PowerShell 3.0 or later (included with Windows 7 SP1 and later)

The update script uses PowerShell's `Invoke-RestMethod` (irm) and `Invoke-Expression` (iex) commands, which are built-in.
  
## Server Responses

### How It Works

1. **Client sends data** → Connected to MulTCPlex on the configured port
2. **MulTCPlex receives** → Data is received and immediately acknowledged with "ok"
3. **Broadcast to backends** → Data is sent to all configured backend servers
4. **Backend responses** → Backend servers may respond, but this is not forwarded to the client

### Important: Clients Do NOT Receive Backend Responses

When a client sends data to MulTCPlex:
- The client receives an "ok" acknowledgment from MulTCPlex itself
- Any responses from backend servers are **ignored and not sent back to the client**
- This is by design to decouple the client from backend responses

This means:
- MulTCPlex is suitable for **one-way messaging** or **fire-and-forget** scenarios
- Clients cannot expect responses from backend servers through MulTCPlex
- If backend servers need to communicate back to clients, they must do so through a separate channel

## Example Workflow

```
Client                MulTCPlex              Backend Server 1
  |                       |                        |
  |------ "hello" ----->  |                        |
  |                       |                        |
  |  <----- "ok" ------   |                        |
  |                       |---- "hello" ---------> |
  |                       |                        |
  |                       |  <----- "received" --- |
  |                       |  (ignored)             |
  |                       |                        |
```

The response "received" from the backend is discarded and not sent back to the client.
