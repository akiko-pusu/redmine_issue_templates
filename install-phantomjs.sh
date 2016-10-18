#!/bin/sh

cd /tmp
wget https://github.com/paladox/phantomjs/releases/download/2.1.7/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar xfj phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo cp /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin