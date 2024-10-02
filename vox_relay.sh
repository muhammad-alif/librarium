#!/bin/bash

# Default values
DEFAULT_UPLOAD_PATH="./"
DEFAULT_DOWNLOAD_PATH="./"
DEFAULT_UPLOAD_PORT=9999
DEFAULT_DOWNLOAD_PORT=9998

# PID files for tracking server processes
PID_UPLOAD_FILE="upload_server.pid"
PID_DOWNLOAD_FILE="download_server.pid"

# Function to clean up resources
cleanup() {
    echo "Interrupt received, stopping servers..."

    pkill -f 'python3 -m'

    echo "Servers stopped."
    exit 0
}

# Set up trap to handle Ctrl+C
trap cleanup SIGINT

# Function to start the HTTP Upload Server
start_upload_server() {
    UPLOAD_PATH=${1:-$DEFAULT_UPLOAD_PATH}  # Use provided path or default
    UPLOAD_PORT=${2:-$DEFAULT_UPLOAD_PORT}  # Use provided port or default

    echo "Starting HTTP Upload Server..."
    cd "$UPLOAD_PATH" || exit
    python3 -m uploadserver "$UPLOAD_PORT" &
    echo "HTTP Upload Server started at port $UPLOAD_PORT serving $UPLOAD_PATH"
}

# Function to start the HTTP Download Server
start_download_server() {
    DOWNLOAD_PATH=${1:-$DEFAULT_DOWNLOAD_PATH}  # Use provided path or default
    DOWNLOAD_PORT=${2:-$DEFAULT_DOWNLOAD_PORT}  # Use provided port or default

    echo "Starting HTTP Download Server..."
    cd "$DOWNLOAD_PATH" || exit
    python3 -m http.server "$DOWNLOAD_PORT" &
    echo "HTTP Download Server started at port $DOWNLOAD_PORT serving $DOWNLOAD_PATH"
}

# Start servers with optional arguments
start_upload_server "$1" "$2"
start_download_server "$3" "$4"

# Wait for the servers to be manually terminated
wait
