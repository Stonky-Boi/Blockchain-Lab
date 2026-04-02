FROM --platform=linux/amd64 ubuntu:22.04

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive
# Combine Foundry and pipx executable paths
ENV PATH="/root/.foundry/bin:/root/.local/bin:${PATH}"

# 1. Install system prerequisites (Added pipx here)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    software-properties-common \
    libz3-dev \
    z3 \
    pipx \
    && rm -rf /var/lib/apt/lists/*

# Install the latest stable Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 2. Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash \
    && /root/.foundry/bin/foundryup

# 3. Install solc-select (Crucial for Python tools to resolve Solidity versions)
RUN pip3 install solc-select \
    && solc-select install 0.8.20 \
    && solc-select use 0.8.20

# 4. Install Python-based tools in completely isolated environments!
RUN pipx install slither-analyzer
RUN pipx install mythril && pipx runpip mythril install -U "setuptools<70.0.0"
RUN pipx install "manticore[native]" && pipx runpip manticore install -U "protobuf<=3.20.3" "setuptools<70.0.0" \
    && sed -i 's/collections.Callable/collections.abc.Callable/g' /root/.local/pipx/venvs/manticore/lib/python3.10/site-packages/wasm/types.py
RUN pipx install crytic-compile

# 5. Install Node-based tools
RUN npm install -g surya forta-agent

# 6. Install Echidna (Pre-compiled Haskell binary)
RUN wget https://github.com/crytic/echidna/releases/download/v2.2.0/echidna-2.2.0-Ubuntu-22.04.tar.gz \
    && tar -xzvf echidna-2.2.0-Ubuntu-22.04.tar.gz \
    && mv echidna /usr/local/bin/ \
    && rm echidna-2.2.0-Ubuntu-22.04.tar.gz

# 7. Install Tenderly CLI
RUN curl https://raw.githubusercontent.com/Tenderly/tenderly-cli/master/scripts/install-linux.sh | sh

# 8. Set up the workspace and clone the repository
WORKDIR /workspace
# Using --recurse-submodules to grab forge-std and openzeppelin-contracts
RUN git clone --recurse-submodules https://github.com/Stonky-Boi/Blockchain-Lab.git

# 9. Copy and set permissions for the execution script
COPY setup.sh /workspace/setup.sh
RUN chmod +x /workspace/setup.sh

# Set the script as the default execution command
ENTRYPOINT ["/workspace/setup.sh"]