#!/bin/sh

CAMYO_URL="https://camyourl.com"
SSH_TUNNEL_HOST="user@sshtunnel.com" #only users with no password supported
SSH_TUNNEL_PORT=2222

# either enter a static identifier or use a script to get the serial number of the device
DEVICE_ID="MY_DEVICE"

# exmaple
# DEVICE_ID=$(cat /sys/class/dmi/id/product_serial) or whatever


# the "-k" param ignores SSL certificate errors. Remove it if needed.
getports() {
  echo $(curl -sSL -k "$CAMYO_URL/api/connect/$DEVICE_ID" 2>/dev/null)
}





###############################################################

#       DON'T EDIT BELOW THIS LINE

###############################################################

# Check if required parameters are provided
if [ -z "$SSH_TUNNEL_HOST" ]; then
    echo "Error: SSH_TUNNEL_HOST is required."
fi

# Check if required parameters are provided
if [ -z "$CAMYO_URL" ]; then
    echo "Error: CAMYO_URL is required."
fi




log_message() {
  echo "$1"
}

CHECK_INTERVAL=60  # Check every 60 seconds
TIMEOUT=10  # Timeout for connection checks (in seconds)
MAX_RETRIES=5  # Maximum number of consecutive failed attempts
BACKOFF_TIME=300  # Time to wait after max retries (5 minutes)
# Extract hostname from REMOTE_HOST
REMOTE_HOSTNAME=$(echo "$SSH_TUNNEL_HOST" | cut -d '@' -f2)

ports=""
oldports=""

# Function to ensure only one instance is running
ensure_single_instance() {
  SCRIPT_NAME=$(basename "$0")
  if pidof "$SCRIPT_NAME" | grep -v $$ >/dev/null; then
    log_message "An instance of $SCRIPT_NAME is already running. Exiting."
    exit 1
  fi
}

  # Function to create the SSH reverse tunnel
  # $1 REMOTE_PORT, $2 LOCAL_PORT
create_tunnel() {
    if [[ $1 == "" || $2 == "" ]]; then
      return 1
    fi
    ssh -f -y -N -R *:${1}:0.0.0.0:${2} -p ${SSH_TUNNEL_PORT} \
      -o ExitOnForwardFailure=yes \
      ${SSH_TUNNEL_HOST}
    if [ $? -eq 0 ]; then
      log_message "Tunnel started successfully. $1 -> $2"
      return 0
    else
      log_message "Failed to start tunnel."
      return 1
    fi
}

# Function to log messages


# Function to check if the tunnel is active
# $1 REMOTE_PORT, $2 LOCAL_PORT
check_tunnel() {
    ps aux | grep "ssh.*${SSH_TUNNEL_HOST}" | grep "$1" | grep "$2" | grep -v grep > /dev/null
    return $?
}

# Function to check server reachability (using ping)
check_server() {
    if ping -c 1 -W ${TIMEOUT} ${REMOTE_HOSTNAME} > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}


# Function to kill the SSH process
# $1 REMOTE_PORT, $2 LOCAL_PORT
kill_ssh_process() {
    local pid=$(ps aux | grep "ssh.*${SSH_TUNNEL_HOST}" | grep "$1" | grep "$2" | grep -v grep | awk '{print $2}')
    if [ ! -z "$pid" ]; then
        kill $pid
        log_message "Killed SSH process with PID $pid"
    else
        log_message "No matching SSH process found to kill"
    fi
}

kill_fork_process() {
    local pid=$(ps aux | grep $(basename "$0") | grep "$1" | grep "$2" | grep -v grep | awk '{print $2}')
    if [ ! -z "$pid" ]; then
        kill $pid
        log_message "Killed fork process with PID $pid"
    else
        log_message "No matching fork process found to kill"
    fi
}


# Trap to handle script termination
cleanup() {
    log_message "Script is terminating. Cleaning up..."
    kill_ssh_process $1 $2
    exit 0
}


# Main loop
# $1 REMOTE_PORT, $2 LOCAL_PORT
run() {
retry_count=0
# Set up trap
trap cleanup  SIGINT SIGTERM
# Ensure single instance
ensure_single_instance

kill_ssh_process $1 $2 
sleep 1
while true; do
    if ! check_server; then
        log_message "Remote server is unreachable. Waiting before retry..."
        sleep ${CHECK_INTERVAL}
        ((retry_count++))
        if [ $retry_count -ge $MAX_RETRIES ]; then
            log_message "Max retries reached. Backing off for ${BACKOFF_TIME} seconds."
            sleep ${BACKOFF_TIME}
            retry_count=0
        fi
        continue
    fi

    if ! check_tunnel $1 $2; then
        log_message "Tunnel is not active. Starting SSH reverse tunnel..."
        if create_tunnel $1 $2; then
            retry_count=0
        else
            ((retry_count++))
            if [ $retry_count -ge $MAX_RETRIES ]; then
                log_message "Max retries reached. Backing off for ${BACKOFF_TIME} seconds."
                sleep ${BACKOFF_TIME}
                retry_count=0
            fi
        fi
    else
        log_message "Tunnel is active."
        retry_count=0
    fi

    sleep ${CHECK_INTERVAL}
done
}


createtunnels() {
  for port in $ports; do 
    LOCAL_PORT=$(echo $port | awk -F ':' '{print $1}')
    REMOTE_PORT=$(echo $port | awk -F ':' '{print $2}')
    ./$(basename "$0") $REMOTE_PORT $LOCAL_PORT &
  done
}

kill_old() {
  for port in $oldports; do
    LOCAL_PORT=$(echo $port | awk -F ':' '{print $1}')
    REMOTE_PORT=$(echo $port | awk -F ':' '{print $2}')
    kill_ssh_process $REMOTE_PORT $LOCAL_PORT &
    kill_fork_process $REMOTE_PORT $LOCAL_PORT 
    sleep 0.3
  done

  oldports=""

}

if [[ ${#1} -gt 0 && ${#2} -gt 0 ]]; then
  run $1 $2
fi

while true; do
  ports=$(getports)
  if [[ -z "$ports" ]]; then
    sleep 1
    continue
  fi


  if [[ -z "$oldports" ]]; then
    oldports=$ports
    createtunnels
  else
    if [[ "$ports" != "$oldports" ]]; then
      kill_old
    fi
  fi


  sleep 1
done;
