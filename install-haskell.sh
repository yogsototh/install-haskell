#!/usr/bin/env zsh

normaluser=$SUDO_USER

if [[ $normaluser = "" ]]; then
    print -- "Please set the SUDO_USER variable with"
    print -- "export SUDO_USER=\$USER;"
    exit 1
fi

# -- To use colors
autoload colors
colors
for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
    eval $COLOR='$fg_no_bold[${(L)COLOR}]'
    eval BOLD_$COLOR='$fg_bold[${(L)COLOR}]'
done
eval RESET='$reset_color'
# --

userhome="$(sudo -u $normaluser echo $HOME)"
echo $userhome

function unpriviledged() {
    print -- ${GREEN}$@${RESET}
    eval sudo -u $normaluser $@
}

function priviledged() {
    print -- ${BOLD_RED}$@${RESET}
    eval $@
}

if [[ -e $userhome/.cabal ]]; then
    print -- "Moving your ~/.cabal to ~/old.cabal"
    unpriviledged mv $HOME/{,old}.cabal
fi

if [[ -e $userhome/.ghc ]]; then
    print -- "Moving your ~/.ghc to ~/old.ghc"
    unpriviledged mv $HOME/{,old}.ghc
fi

ghcversion="7.8.4"
cabalversion="1.22.0.0"
archi=$(uname -m)
if [[ $(uname -s) = "Darwin" ]]; then
    os="apple-darwin"
    cabalos="apple-darwin-mavericks"
else
    if [[ ! -e /etc/debian_version ]]; then
        print -- "You don't appear to be on a Debian based Linux"
        print -- "This script might install files not necessarily at the right place for your distribution"
        print -- "Do you want to continue?"
        read answer
        case $answer in
            y|Y|yes|YES) print -- "OK" ;;
            *) print -- "Bye!"; exit 1;;
        esac
    fi
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
    priviledged curl -LO "http://www.haskell.org/ghc/dist/${ghcversion}/$ghctar"
else
    echo "Using already downloaded GHC ($tmpdir)..."
fi
echo "Installing GHC..."
priviledged tar xJf $ghctar
priviledged cd ghc-${ghcversion}
priviledged ./configure && make install

cd $tmpdir
echo "Downloading cabal..."
cabaltar=cabal-${cabalversion}-${archi}-${cabalos}.tar.gz
[[ $cabalos = "unknown-linux" ]] && cabaltar=cabal-${archi}-${cabalos}.tar.gz
if [[ ! -e $cabaltar ]]; then
    echo "http://www.haskell.org/cabal/release/cabal-install-$cabalversion/$cabaltar"
    priviledged curl -LO "http://www.haskell.org/cabal/release/cabal-install-$cabalversion/$cabaltar"
else
    echo "Using already downloaded cabal ($tmpdir)..."
fi
priviledged tar xzf $cabaltar
echo "Installing cabal..."
if [[ -e ./cabal ]]; then
    priviledged mv cabal /usr/local/bin
else
    priviledged mv ./dist/build/cabal/cabal /usr/local/bin
fi

echo "Init cabal..."
unpriviledged cabal info >/dev/null 2>&1

echo "Using Haskell LTS for GHC 7.8"

# use exclusive snapshot by default.
unpriviledged "curl 'https://www.stackage.org/lts/cabal.config?global=true' >> ~/.cabal/config"
unpriviledged "perl -pi -e 's#-- library-profiling: False#library-profiling: True#' $HOME/.cabal/config"
unpriviledged "perl -pi -e 's#-- executable-profiling: False#executable-profiling: True#' $HOME/.cabal/config"
unpriviledged cabal update
echo "Install useful binaries"
unpriviledged cabal install -j alex happy

if grep 'export PATH=$HOME/.cabal/bin:$PATH' $HOME/.profile >/dev/null; then
    echo "PATH variable already set in your .profile"
else
    echo "Update your PATH in .profile for cabal binaries"
    unpriviledged echo 'export PATH=$HOME/.cabal/bin:$PATH' >> $HOME/.profile
fi

echo "================"
echo "Congratulations!"
echo "================"
echo
echo "You should start using Haskell like a pro now"
echo "You shouldn't use cabal sandbox except if you know what you are doing."
echo "So if you follow a tutorial that use cabal sandbox, don't use it."
echo "Unless you don't mind killing some white bears and waiting a lot."
echo
