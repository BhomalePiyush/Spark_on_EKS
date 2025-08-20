#!bin/bash

# uncomment if brew not already installed
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#echo $PATH
#export PATH=$PATH:/opt/homebrew/bin

# INSTALL DOCKER DESKTOP https://docs.docker.com/desktop/setup/install/mac-install/

# UPDATE brew
brew update

# install aws cli
brew install awscli
# check installation
aws --version

export YOUR_ACCESS_KEY_ID=<your_access_key>
export YOUR_SECRET_ACCESS_KEY=<your_secret_access_key>

aws configure set aws_access_key_id ${YOUR_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${YOUR_SECRET_ACCESS_KEY}
aws configure set default.region us-east-1

# install eksctl
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap aws/tap
brew install eksctl
# validate installation
eksctl version

# install kubectl
brew install kubectl

# install Helm
brew install helm

# install k9s for cluster visualization
brew install k9s



