#!/usr/bin/env zsh

ghcversion="7.8.3"
cabalversion="1.20.0.3"
archi=$(uname -m)
if [[ $(uname -s) = "Darwin" ]]; then
    os="apple-darwin"
    cabalos="apple-darwin-maverick"
    cabalarchi=$archi
else
    os="unknown-linux-deb7"
    cabalos="unknown-linux"
    cabalarchi=i386
fi

tmpdir=/tmp/install-haskell
mkdir -p $tmpdir

cd $tmpdir
ghctar=ghc-${ghcversion}-${archi}-${os}.tar.xz 
if [[ ! -e $ghctar ]]; then
    echo "Downloading GHC..."
    curl -O http://www.haskell.org/ghc/dist/${ghcversion}/$ghctar
else
    echo "Using already downloaded GHC ($tmpdir)..."
fi
echo "Installing GHC..."
tar xJf $ghctar
cd ghc-${ghcversion}
./configure && make install

cd $tmpdir
echo "Downloading cabal..."
cabaltar=cabal-$cabalversion-${cabalarchi}-${cabalos}.tar.gz 
if [[ ! -e $cabaltar ]]; then
    curl -O http://www.haskell.org/cabal/release/cabal-install-$cabalversion/$cabaltar
else
    echo "Using already downloaded cabal ($tmpdir)..."
fi
tar xzf $cabaltar
echo "Installing cabal..."
if [[ -e ./cabal ]]; then
    mv cabal /usr/local/bin
else
    mv ./dist/build/cabal/cabal /usr/local/bin
fi

echo "Init cabal..."
cabal info >/dev/null 2>&1

if [[ $1 = "kernel" ]]; then
    echo "Using Stackage Exclusively..."
    stackageurl="stackage:http://www.stackage.org/stackage/77fb1efe248e3160d1e7dee5a009a0c5713651ae"
else
    echo "Using Stackage..."
    stackageurl="stackage:http://www.stackage.org/stackage/3cb59cb0cfe26e0513c30a727d889e7b0d427efd"
fi
# use exclusive snapshot by default.
perl -pi.bak -e 's#^remote-repo: .*$#remote-repo: '$stackageurl'#' $HOME/.cabal/config
cabal update
echo "Install useful binaries"
cabal install -j alex happy

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
