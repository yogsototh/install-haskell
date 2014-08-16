#!/usr/bin/env bash

ghcversion=7.8.3
cabalversion=1.20.0.3

tmpdir=/tmp/install-haskell-osx
mkdir -p $tmpdir
cd $tmpdir

echo "Downloading GHC..."
curl -O
echo "Installing GHC..."
cd ghc
./configure && make install

echo "Downloading cabal..."
curl -O http://www.haskell.org/cabal/release/cabal-install-$cabalversion/cabal-$cabalversion-x86_64-apple-darwin-mavericks.tar.gz
echo "Installing cabal..."
tar xzf cabal-$cabalversion-x86_64-apple-darwin-mavericks.tar.gz
sudo mv ./dist/build/cabal/cabal /usr/local/bin

echo "Using Stackage..."
stackageurl=
perl -pi.bak -e 's#remote-repo: .*$#remote-repo: '$stackageurl $HOME/.cabal/config
cabal update
echo "Install usefull binaries"
cabal install alex happy

echo "Update your PATH in .profile for cabal binaries"
echo 'export PATH=$HOME/.cabal/bin:$PATH' >> $HOME/.profile

echo
echo "Congratulations"
echo "==============="
echo
echo "You should start using Haskell like a pro now"
echo "You shouldn't use cabal sandbox except if you know what you are doing."
echo "So if you follow a tutorial that use cabal sandbox, don't use it."
echo "Unless you don't mind killing some white bear and waiting a lot."
