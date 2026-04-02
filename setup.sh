#!/bin/bash
set -e

echo "Starting automated build, test, and audit sequence..."
target_repo_dir="/workspace/Blockchain-Lab"

echo "====================================="
echo " Phase 0: Repository Sync"
echo "====================================="

if [ -d "$target_repo_dir/.git" ]; then
    echo "Repository exists. Pulling latest changes..."
    cd "$target_repo_dir"

    # Fetch and hard reset (safer for CI-like environments)
    git fetch --all
    git reset --hard origin/main

    # Update submodules
    git submodule update --init --recursive

else
    echo "Repository not found. Cloning..."
    git clone --recurse-submodules https://github.com/Stonky-Boi/Blockchain-Lab.git "$target_repo_dir"
    cd "$target_repo_dir"
fi

echo "====================================="
echo " Phase 1: Foundry Operations"
echo "====================================="

echo "Installing missing Foundry dependencies (if any)..."
forge install

echo "Building contracts..."
forge build --sizes

echo "Running Foundry test suite..."
forge test -vvv

echo "Executing Foundry deployment scripts (Dry Run)..."
# Loop through all scripts in the script directory explicitly
for script_file in script/*.s.sol; do
    if [ -f "$script_file" ]; then
        echo "Running script: $script_file"
        forge script "$script_file" -vvv
    fi
done

echo "====================================="
echo " Phase 2: Security Audits"
echo "====================================="

# --- TIMEOUT CONFIGURATION (in seconds) ---
MYTH_TIMEOUT=60
ECHIDNA_TIMEOUT=60
MCORE_TIMEOUT=120
# ------------------------------------------

echo " Running Slither (Static Analysis)"
slither . || true

echo " Running Surya (Architecture & Graphs)"
surya describe src/*.sol || true
surya inheritance src/*.sol || true

echo " Running Mythril (Symbolic Execution)"
for contract_file in src/*.sol; do
    if [ -f "$contract_file" ]; then
        echo "Analyzing $contract_file with Mythril (Max ${MYTH_TIMEOUT}s)..."
        myth analyze "$contract_file" --execution-timeout $MYTH_TIMEOUT || true
    fi
done

echo " Running Echidna (Fuzzing)"
for contract_file in src/*.sol; do
    if [ -f "$contract_file" ]; then
        base_name=$(basename -- "$contract_file")
        contract_name="${base_name%.*}"
        echo "Fuzzing $contract_file (Target: $contract_name, Max ${ECHIDNA_TIMEOUT}s)..."
        timeout $ECHIDNA_TIMEOUT echidna "$contract_file" --contract "$contract_name" || true
    fi
done

echo " Running Manticore (Symbolic Execution)"
for contract_file in src/*.sol; do
    if [ -f "$contract_file" ]; then
        base_name=$(basename -- "$contract_file")
        workspace_dir="mcore_workspace_${base_name%.*}"
        echo "Analyzing $contract_file with Manticore (Max ${MCORE_TIMEOUT}s)..."
        timeout $MCORE_TIMEOUT manticore "$contract_file" --workspace "$workspace_dir" || true
    fi
done

echo "====================================="
echo " Execution Complete"
echo "====================================="
echo "Check the terminal output and the mcore_workspace_* directories for results."
echo "Note: SmartBugs and Securify rely on Docker-in-Docker architectures."
echo "They have been bypassed to preserve standard container stability."