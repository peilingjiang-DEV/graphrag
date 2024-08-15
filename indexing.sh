#!/bin/bash

start_time=$(date +%s)

# Check if a command line argument is provided
# if [ $# -eq 0 ]; then
#   echo "Error: Please provide a root directory as a command line argument"
#   exit 1
# fi

# Store the root directory from the command line argument
ROOT_DIR="ragtest"

# * Run the GraphRAG indexing init command
echo "Running GraphRAG indexing... [Init]"
poetry run poe index --verbose --root "$ROOT_DIR" --init

# * Check if the command was successful
if [ $? -eq 0 ]; then
  echo "GraphRAG indexing init completed successfully"
else
  echo "Error: GraphRAG indexing init failed"
  exit 1
fi

# * Copy the .env file to the root directory
echo "Copying .env to $ROOT_DIR"
cp -f ./meta/.env "$ROOT_DIR"

# * Copy the appropriate settings.json file to the root directory
if [ "$1" = "csv" ]; then
  echo "Copying settings-csv.json to $ROOT_DIR/settings.json"
  cp ./meta/settings-csv.json "$ROOT_DIR/settings.json"
elif [ "$1" = "text" ] || [ -z "$1" ]; then
  echo "Copying settings-text.json to $ROOT_DIR/settings.json" # ! Default
  cp ./meta/settings-text.json "$ROOT_DIR/settings.json"
fi
rm -f "$ROOT_DIR/settings.yaml"

# * Copy the meta prompts to cover the auto-gen default prompts
echo "Copying meta prompts to $ROOT_DIR/prompts"
cp -rf ./meta/prompts "$ROOT_DIR"

echo "Indexing prep completed"

# ! Prompt tuning
# poetry run poe prompt_tune --root "$ROOT_DIR" --config "$ROOT_DIR/settings.json" --no-entity-types

# * Run the GraphRAG indexing command
echo "Running GraphRAG indexing... [Actual]"
poetry run poe index --verbose --root "$ROOT_DIR"

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
minutes=$((elapsed_time / 60))
seconds=$((elapsed_time % 60))
echo "Indexing completed in $minutes m $seconds s"
