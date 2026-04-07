#!/bin/bash
set -e

echo "Starting automated build, test, and audit sequence..."
target_repo_dir="/workspace/Blockchain-Lab"
cd "$target_repo_dir"

echo "============================="
echo " Phase 1: Foundry Operations "
echo "============================="

if [ ! -d "lib" ]; then
    echo "Installing missing Foundry dependencies..."
    forge install
fi

echo "Building contracts..."
forge build --sizes

echo "Running Foundry test suite..."
forge test -vvv

echo "Executing Foundry deployment scripts (Dry Run)..."
find script -name "*.s.sol" | while read -r script_file; do
    echo "Running script: $script_file"
    forge script "$script_file" -vvv
done

echo "=========================="
echo " Phase 2: Security Audits "
echo "=========================="

TIMEOUT=60

echo " Running Slither (Static Analysis)"
slither . || true

echo " Running Surya (Architecture & Graphs)"
ALL_CONTRACTS=$(find src -name "*.sol")
surya describe $ALL_CONTRACTS || true
surya inheritance $ALL_CONTRACTS || true

echo " Running Mythril (Symbolic Execution)"
find src -name "*.sol" | while read -r contract_file; do
    echo "Analyzing $contract_file with Mythril (Max ${TIMEOUT}s)..."
    myth analyze "$contract_file" --execution-timeout $TIMEOUT || true
done

echo " Running Echidna (Fuzzing)"
find test -name "*.sol" | while read -r contract_file; do
    base_name=$(basename -- "$contract_file")
    contract_name="${base_name%.*}"
    echo "Fuzzing $contract_file (Target: $contract_name, Max ${TIMEOUT}s)..."
    timeout $TIMEOUT echidna "$contract_file" --contract "$contract_name" || true
done

echo "Running cleanup..."
forge clean
rm -rf crytic-export

echo "===================="
echo " Execution Complete "
echo "===================="

echo "--- Omitted Tools & Justifications ---"
echo "* SmartBugs & Securify: Omitted entirely. These tools rely on Docker-in-Docker (DinD) architectures, which compromise the security and stability of an isolated local container."
echo "* Manticore: Omitted entirely. Its custom Python EVM emulator struggles to parse modern Solidity (0.8+) panic opcodes and recent network forks, causing deployment exceptions."
echo "* Tenderly CLI: Installed for manual debugging, but bypassed in automation. It is a cloud-based platform that requires API credentials and live network forks to simulate transactions."
echo "* Forta Agent: Installed for bot development, but bypassed in automation. Forta is a runtime monitoring network designed for live, deployed contracts, not local static/symbolic analysis."
echo "======================================"