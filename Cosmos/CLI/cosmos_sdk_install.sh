#!/bin/bash
#                                                                                                         
#                                                  jim380 <admin@cyphercore.io>
#  ============================================================================
#  
#  Copyright (C) 2018 jim380
#  
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#  
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#  
#  ============================================================================
function preparation {
    echo "-----------------------------------------"
    echo "               System Update             "
    echo "-----------------------------------------"
    sudo apt-get update && sudo apt-get upgrade -y 
    echo "-----------------------------------------"
    echo "                Preparation              "
    echo "-----------------------------------------"
    sudo apt-get install make gcc g++ -y
    sudo sudo apt autoremove
}

function binary {
    echo "-----------------------------------------"
    echo "             Install Binaries            "
    echo "-----------------------------------------"
    if ! test -d $GOPATH/src/github.com/cosmos
    then
        mkdir -p $GOPATH/src/github.com/cosmos
        cd $GOPATH/src/github.com/cosmos
        git clone https://github.com/cosmos/cosmos-sdk
    fi
    echo "-----------------------------------------"
    echo "             Update Binary               "
    echo "-----------------------------------------"
    REPO=$GOPATH/src/github.com/cosmos/cosmos-sdk
    if [ -d "$REPO" ]
    then
        cd $REPO
        if [ -d "$REPO/.git" ]
        then
        echo "Updating $REPO at
    `date`"
        git status
        echo "-----------------------------------------"
        echo "               Fetching                  "
        echo "-----------------------------------------"
        git fetch
        echo "-----------------------------------------"
        echo "                Pulling                  "
        echo "-----------------------------------------"
        git pull
        else
        echo "-----------------------------------------"
        echo "This is not a git folder."
        echo "-----------------------------------------"
        fi
        echo "Finished updating at
    `date`"
        echo ""
    fi
    echo "-----------------------------------------"
    echo "            Version Checkout             "
    echo "-----------------------------------------"
    read -p "What version would you like to checkout?
Enter 'master' or specify a version number (e.g. 'v0.31.1')
" CHECKOUT_VERSION
    echo "Installing $CHECKOUT_VERSION"
    git checkout $CHECKOUT_VERSION
    echo "-----------------------------------------"
    echo "              Make & Install             "
    echo "-----------------------------------------"
    make get_vendor_deps && make install
}

function init {
    echo "-----------------------------------------"
    echo "                Node Init                "
    echo "-----------------------------------------"
    read -p "What would you like the node to be called?
" NODE_NAME
    echo "Node name has been set to '$NODE_NAME'"
    echo "What would you like the Gaiad home directory to be? (default: ~/.gaiad)"
    read -p "Path: " GAIAD_HOME
    if [ -z "$GAIAD_HOME" ]
    then 
        echo "Gaiad home directory has been set to ~/.gaiad"
        gaiad init $NODE_NAME --home=~/.gaiad
    else
        echo "Gaiad home directory has been set to '$GAIAD_HOME'"
        gaiad init $NODE_NAME --home=$GAIAD_HOME
    fi
}

function genesis {
    echo "-----------------------------------------"
    echo "            Fetch genesis.json           "
    echo "-----------------------------------------"
    if test -d $GAIAD_HOME/config/genesis.json
    then
        rm $GAIAD_HOME/config/genesis.json
    fi
    read -p "Link to genesis.json in raw format:
" GENESIS
    echo ""
    curl $GENESIS > $GAIAD_HOME/config/genesis.json
}

function version {
    echo "-----------------------------------------"
    echo "               gaiad version             "
    echo "-----------------------------------------"
    gaiad version
    echo "-----------------------------------------"
    echo "              gaiacli version"
    echo "-----------------------------------------"
    gaiacli version
}

preparation
binary
echo ""
read -p "Would you like to init a new node? (y/n) " ans
case "$ans" in 
    "y"|"yes"|"Y"|"Yes"|"YES") init
    ;;
    *) echo "Continue..."
    ;;
esac
genesis
version