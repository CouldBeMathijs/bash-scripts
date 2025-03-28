#!/bin/bash

# Copy and verify success
#!/bin/bash

# Define possible source paths
ENGINE_RELEASE="cmake-build-release/engine"
ENGINE_DEBUG="cmake-build-debug/engine"
DEST_DIR="ini"

# Ensure the destination directory exists
if [ ! -d "$DEST_DIR" ]; then
  echo "Error: Destination directory '$DEST_DIR' does not exist."
  exit 1
fi

# Try copying from release or debug, and handle failures
if [ -f "$ENGINE_RELEASE" ]; then
  cp "$ENGINE_RELEASE" "$DEST_DIR" && echo "Copied from release build."
elif [ -f "$ENGINE_DEBUG" ]; then
  cp "$ENGINE_DEBUG" "$DEST_DIR" && echo "Copied from debug build."
else
  echo "Error: 'engine' file not found in either build directory."
  exit 1
fi

# Change to the destination directory
cd "$DEST_DIR" || { echo "Error: Failed to change directory to '$DEST_DIR'"; exit 1; }
# Run the engine in the background
START_TIME=$(date +%s.%N)
./engine &
PID=$!
# Log file header
echo "Timestamp, PID, PSS (KB), RSS (KB), VSS (KB)" > memory_log.csv

# Initialize max values
MAX_RSS=0
MAX_VSS=0

# Monitor memory usage
while kill -0 $PID 2>/dev/null; do
    if [[ -e /proc/$PID/status ]]; then
        RSS=$(awk '/VmRSS/ {print $2}' /proc/$PID/status)
        VSS=$(awk '/VmSize/ {print $2}' /proc/$PID/status)
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S.%3N")
        echo "$TIMESTAMP, $PID, 0, $RSS, $VSS" >> memory_log.csv

        # Update max values
        if [[ $RSS -gt $MAX_RSS ]]; then
            MAX_RSS=$RSS
        fi
        if [[ $VSS -gt $MAX_VSS ]]; then
            MAX_VSS=$VSS
        fi
    fi
    sleep 0.1
done
END_TIME=$(date +%s.%N)  # Get the end time
# Convert KB to GB
MAX_RSS_GB=$(awk "BEGIN {print $MAX_RSS / 1024 / 1024}")
MAX_VSS_GB=$(awk "BEGIN {print $MAX_VSS / 1024 / 1024}")

# Print max recorded memory usage
echo "Max actual memory in use (RSS): ${MAX_RSS_GB} GB"
echo "Max memory allocated (VSS): ${MAX_VSS_GB} GB"
ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
echo "Execution time: $ELAPSED_TIME seconds"

# Cleanup
rm -f engine
cd ..
