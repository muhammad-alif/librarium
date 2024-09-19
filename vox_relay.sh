#!/bin/bash

# Default values (if not provided)
DEFAULT_SMB_PATH="/home/kali/Desktop"
DEFAULT_UPLOAD_PATH="/home/kali/Desktop"
DEFAULT_DOWNLOAD_PATH="/home/kali/Desktop"
DEFAULT_UPLOAD_PORT=9999
DEFAULT_DOWNLOAD_PORT=9998
DEFAULT_SMB_USER="user"
DEFAULT_SMB_PASS="password"

# PID files for tracking server processes
PID_SMB_FILE="smb_server.pid"
PID_UPLOAD_FILE="upload_server.pid"
PID_DOWNLOAD_FILE="download_server.pid"

# Function to clean up resources
cleanup() {
    echo "Interrupt received, stopping servers..."

    # Stop the SMB server
    if [ -f "$PID_SMB_FILE" ]; then
        kill "$(cat $PID_SMB_FILE)" 2>/dev/null
        rm "$PID_SMB_FILE"
    fi

    # Stop the upload server
    if [ -f "$PID_UPLOAD_FILE" ]; then
        kill "$(cat $PID_UPLOAD_FILE)" 2>/dev/null
        rm "$PID_UPLOAD_FILE"
    fi

    # Stop the download server
    if [ -f "$PID_DOWNLOAD_FILE" ]; then
        kill "$(cat $PID_DOWNLOAD_FILE)" 2>/dev/null
        rm "$PID_DOWNLOAD_FILE"
    fi

    echo "Servers stopped."
    exit 0
}

# Set up trap to handle Ctrl+C
trap cleanup SIGINT

# Function to start Impacket SMB Server
start_smb_server() {
    SMB_PATH=${1:-$DEFAULT_SMB_PATH}  # Use first argument, or default
    SMB_USER=${2:-$DEFAULT_SMB_USER}
    SMB_PASS=${3:-$DEFAULT_SMB_PASS}
    echo "Starting Impacket SMB Server..."
    impacket-smbserver share "$SMB_PATH" -smb2support -username "$SMB_USER" -password "$SMB_PASS" &
    echo $! > "$PID_SMB_FILE"
    echo "SMB Server started serving $SMB_PATH"
}

# Function to start HTTP Upload Server
start_upload_server() {
    UPLOAD_PATH=${1:-$DEFAULT_UPLOAD_PATH}  # Use first argument, or default
    UPLOAD_PORT=${2:-$DEFAULT_UPLOAD_PORT}  # Use second argument, or default
    echo "Starting HTTP Upload Server..."
    cd "$UPLOAD_PATH" || exit
    python3 -m uploadserver "$UPLOAD_PORT" &
    echo $! > "$PID_UPLOAD_FILE"
    echo "HTTP Upload Server started at port $UPLOAD_PORT serving $UPLOAD_PATH"
}

# Function to start HTTP Download Server
start_download_server() {
    DOWNLOAD_PATH=${1:-$DEFAULT_DOWNLOAD_PATH}  # Use first argument, or default
    DOWNLOAD_PORT=${2:-$DEFAULT_DOWNLOAD_PORT}  # Use second argument, or default
    echo "Starting HTTP Download Server..."
    cd "$DOWNLOAD_PATH" || exit
    python3 -m http.server "$DOWNLOAD_PORT" &
    echo $! > "$PID_DOWNLOAD_FILE"
    echo "HTTP Download Server started at port $DOWNLOAD_PORT serving $DOWNLOAD_PATH"
}

# Parse command-line arguments for SMB, HTTP Upload, and HTTP Download paths and ports
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --smb-path) SMB_PATH="$2"; shift ;;
        --smb-user) SMB_USER="$2"; shift ;;
        --smb-pass) SMB_PASS="$2"; shift ;;
        --upload-path) UPLOAD_PATH="$2"; shift ;;
        --upload-port) UPLOAD_PORT="$2"; shift ;;
        --download-path) DOWNLOAD_PATH="$2"; shift ;;
        --download-port) DOWNLOAD_PORT="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Start SMB Server with optional parameters
if [[ "$SMB_PATH" != "" ]]; then
    start_smb_server "$SMB_PATH" "$SMB_USER" "$SMB_PASS"
fi

# Start HTTP Upload Server with optional parameters
if [[ "$UPLOAD_PATH" != "" ]]; then
    start_upload_server "$UPLOAD_PATH" "$UPLOAD_PORT"
fi

# Start HTTP Download Server with optional parameters
if [[ "$DOWNLOAD_PATH" != "" ]]; then
    start_download_server "$DOWNLOAD_PATH" "$DOWNLOAD_PORT"
fi

# Wait for the servers to be manually terminated
wait
