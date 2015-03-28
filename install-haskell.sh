#!/usr/bin/env zsh

normaluser=$1
(( $# < 1 ))  && {
    print -- "usage: sudo ${0:t} \$USER" >&2
    exit 1
}

userhome="$(sudo -u $normaluser echo $HOME)"
echo $userhome

if [[ -e $userhome/.cabal ]]; then
    print -- "Moving your ~/.cabal to ~/old.cabal"
    sudo -u $normaluser mv $HOME/{,old}.cabal
fi

if [[ -e $userhome/.ghc ]]; then
    print -- "Moving your ~/.ghc to ~/old.ghc"
    sudo -u $normaluser mv $HOME/{,old}.ghc
fi

# 7.8.4 don't have an official apple-darwin build
ghcversion="7.8.3"
cabalversion="1.20.0.3"
archi=$(uname -m)
if [[ $(uname -s) = "Darwin" ]]; then
    os="apple-darwin"
    cabalos="apple-darwin-mavericks"
else
    if [[ $archi = "i686" ]]; then
        archi=i386
    fi
    cabalversion="1.22.0.0"
    os="unknown-linux-deb7"
    cabalos="unknown-linux"
    # -------------------------
    # apt-get install libgmp-dev
fi

tmpdir=/tmp/install-haskell
mkdir -p $tmpdir

cd $tmpdir
ghctar=ghc-${ghcversion}-${archi}-${os}.tar.xz
if [[ ! -e $ghctar ]]; then
    echo "Downloading GHC..."
    echo "http://www.haskell.org/ghc/dist/${ghcversion}/$ghctar"
    curl -LO "http://www.haskell.org/ghc/dist/${ghcversion}/$ghctar"
else
    echo "Using already downloaded GHC ($tmpdir)..."
fi
echo "Installing GHC..."
tar xJf $ghctar
cd ghc-${ghcversion}
./configure && make install

cd $tmpdir
echo "Downloading cabal..."
cabaltar=cabal-${cabalversion}-${archi}-${cabalos}.tar.gz
[[ $cabalos = "unknown-linux" ]] && cabaltar=cabal-${archi}-${cabalos}.tar.gz
if [[ ! -e $cabaltar ]]; then
    echo "http://www.haskell.org/cabal/release/cabal-install-$cabalversion/$cabaltar"
    curl -LO "http://www.haskell.org/cabal/release/cabal-install-$cabalversion/$cabaltar"
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
sudo -u $normaluser cabal info >/dev/null 2>&1

echo "Using Haskell LTS for GHC 7.8"

# use exclusive snapshot by default.
sudo -u $normaluser curl 'https://www.stackage.org/lts/cabal.config?global=true' >> ~/.cabal/config
sudo -u $normaluser perl -pi -e 's#-- library-profiling: False#library-profiling: True#' $HOME/.cabal/config
sudo -u $normaluser perl -pi -e 's#-- executable-profiling: False#executable-profiling: True#' $HOME/.cabal/config
sudo -u $normaluser cabal update
echo "Install useful binaries"
sudo -u $normaluser cabal install -j alex happy

echo "Update your PATH in .profile for cabal binaries"
sudo -u $normaluser echo 'export PATH=$HOME/.cabal/bin:$PATH' >> $HOME/.profile

echo "================"
echo "Congratulations\!"
echo "================"
echo
echo "You should start using Haskell like a pro now"
echo "You shouldn't use cabal sandbox except if you know what you are doing."
echo "So if you follow a tutorial that use cabal sandbox, don't use it."
echo "Unless you don't mind killing some white bear and waiting a lot."
echo
