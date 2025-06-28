#!/bin/bash

# A script to fetch recent roulette game history from an API
# and save the results to a CSV file.

# --- Configuration ---
# The base URL for the API endpoint. The page number will be appended to this.
BASE_URL="https://blaze.bet.br/api/singleplayer-originals/originals/roulette_games/recent/history/1?startDate=2025-05-28T23:59:00.000Z&endDate=2025-06-28T00:00:00.000Z&page="
# The name of the file where the results will be saved.
OUTPUT_CSV="roulette_history.csv"

# --- Pre-flight Checks ---
# Check if the user provided the number of pages as an argument.
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_pages>"
  echo "Example: $0 100"
  exit 1
fi

# Check if 'jq' is installed, as it's required for parsing JSON.
if ! command -v jq &> /dev/null; then
    echo "'jq' is not installed, but it's required for this script to work."
    echo "Please install it to continue. (e.g., 'sudo apt-get install jq' or 'brew install jq')"
    exit 1
fi

# Total number of pages to fetch, taken from the first command-line argument.
TOTAL_PAGES=$1

# --- Main Logic ---
echo "Starting data fetch for $TOTAL_PAGES pages..."

# Create the CSV file and write the header row.
# This will overwrite the file if it already exists.
echo "id,created_at,color,roll,server_seed" > "$OUTPUT_CSV"

# Loop from 1 to the total number of pages specified by the user.
for (( page=1; page<=$TOTAL_PAGES; page++ )); do
    
    echo "Fetching data from page $page of $TOTAL_PAGES..."

    # Construct the full URL for the current page.
    API_URL="${BASE_URL}${page}"

    # Use 'curl' to fetch the data from the API.
    # The '-s' flag makes curl operate in silent mode.
    # The output is piped to 'jq' for processing.
    #
    # 'jq' command explanation:
    # -r: output raw strings, not JSON-escaped strings.
    # .records[]: iterate over each element in the "records" array.
    # |: pipe the output of the previous filter to the next one.
    # [.id, .created_at, .color, .roll, .server_seed]: create an array of these specific values for each record.
    # | @csv: format the array as a CSV row.
    curl -s "$API_URL" | jq -r '.records[] | [.id, .created_at, .color, .roll, .server_seed] | @csv' >> "$OUTPUT_CSV"

    # A small delay to be polite to the API server.
    sleep 0.5
done

echo "--------------------------------------------------"
echo "✅ Done!"
echo "Data has been successfully saved to $OUTPUT_CSV"
echo "--------------------------------------------------"
