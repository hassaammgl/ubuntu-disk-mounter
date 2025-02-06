sudo apt update && upgrade

sudo apt install curl
sudo apt install git
sudo apt-get install gnupg curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo systemctl daemon-reload

sudo systemctl start mongod


# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Download and install Node.js:
nvm install 23

# Verify the Node.js version:
node -v # Should print "v23.7.0".
nvm current # Should print "v23.7.0".

# Verify npm version:
npm -v # Should print "10.9.2".

# Download and install Yarn:
corepack enable yarn

# Verify Yarn version:
yarn -v

# Download and install pnpm:
corepack enable pnpm

# Verify pnpm version:
pnpm -v

sudo apt install python3

sudo apt install python3-pip

pip3 --version

sudo pip3 install --upgrade pip

sudo apt install python3-venv

cd .. && cd ./Downloads 

sudo dpkg -i ./*.deb


sudo snap install vlc
sudo snap install pieces-os
sudo snap connect pieces-os:process-control :process-control
sudo snap install pieces-for-developers
sudo snap refresh

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg

sudo apt update && sudo apt install microsoft-edge-stable

pieces-os
pieces-for-developers
