> This project has two homes.
> It is ok to work in github, still, for a better decentralized web
> please consider contributing (issues, PR, etc...) throught:
>
> https://gitlab.esy.fun/yogsototh/install-haskell

---


install-haskell
===============

A script to install Haskell and minimize cabal hell.

If you are on Linux install `libgmp-dev`, `bzip2` and `zsh`.

```
curl https://raw.githubusercontent.com/yogsototh/install-haskell/master/install-haskell.sh | sudo zsh
```

If something goes wrong:

```
export SUDO_USER=$USER; curl https://raw.githubusercontent.com/yogsototh/install-haskell/master/install-haskell.sh | sudo zsh
```

