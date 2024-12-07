#!/bin/bash

# Enter user directory
cd ~ || exit

# Stop old titan program
sudo systemctl stop titan

# Back up the .titan directory. If something goes wrong in the middle, you can use the backup to restore and then execute again.
mv ~/.titan ~/titan_bak_08_08_02

# Copy directory and other information to the new path
rsync -av --exclude "data" ~/titan_bak_08_08_02/* ~/.titan

wget -P ~/. https://raw.githubusercontent.com/Titannet-dao/titan-chain/main/addrbook/addrbook.json

mv ~/addrbook.json ~/.titan/config/addrbook.json

# Download new genesis file
wget -P ~/. https://raw.githubusercontent.com/Titannet-dao/titan-chain/main/genesis/genesis.json

# Replace new genesis file
mv ~/genesis.json ~/.titan/config/genesis.json

mkdir ~/.titan/data
# Build data/priv_validator_state.json 文件
echo '{
  "height": "0",
  "round": 0,
  "step": 0
}' > ~/.titan/data/priv_validator_state.json

rm -rf titan-chain
git clone https://github.com/Titannet-dao/titan-chain.git
sleep 5
cd titan-chain
git fetch origin
sleep 5
git checkout origin/main
sleep 5
go build ./cmd/titand
sleep 5
mv /root/titan-chain/titand /root/.titan/cosmovisor/genesis/bin/
sleep 5
sudo ln -sfn $HOME/.titan/cosmovisor/genesis $HOME/.titan/cosmovisor/current
sleep 5
sudo ln -sfn $HOME/.titan/cosmovisor/current/bin/titand /usr/local/bin/titand
sleep 5
sudo systemctl daemon-reload

# Update config/client.toml chain-id
echo '# This is a TOML config file.
# For more information, see https://github.com/toml-lang/toml

###############################################################################
###                           Client Configuration                            ###
###############################################################################

# The network chain ID
chain-id = "titan-test-3"
# The keyring s backend, where the keys are stored (os|file|kwallet|pass|test|memory)
keyring-backend = "os"
# CLI output format (text|json)
output = "text"
# <host>:<port> to Tendermint RPC interface for this chain
node = "tcp://localhost:29657"
# Transaction broadcasting mode (sync|async)
broadcast-mode = "sync"' > ~/.titan/config/client.toml

sudo systemctl start titan
