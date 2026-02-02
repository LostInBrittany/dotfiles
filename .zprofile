eval "$(/opt/homebrew/bin/brew shellenv)"

. "$HOME/.cargo/env"


export PATH=~/opt/tinygo/bin:~/opt/bin:~/go/bin:$PATH

export WASMTIME_HOME="$HOME/.wasmtime"
export PATH="$WASMTIME_HOME/bin:$PATH"


# Added by Windsurf
export PATH="/Users/horacio/.codeium/windsurf/bin:$PATH"

export PATH="/Users/horacio/.local/bin:$PATH"

# Login shell specific
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
fi

