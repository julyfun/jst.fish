function __jst.get.zoxide
    zoxide --version; and return
end

function __jst.get.zed
    if type -q zed; return; end
    curl -f https://zed.dev/install.sh | sh
end

function __jst.get.zerotier
    zerotier --version; and return
    curl -s https://install.zerotier.com/ | bash
end

function __jst.get.fzf
    if type -q fzf
        return
    end
    switch (__mfa.os)
    case Darwin
        brew install fzf
    case Linux
        sudo apt install fzf
    end
end

function __jst.get.rustup
    rustup --version; and return
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
end

function __jst.get.uv
    uv --version; and return
    curl -LsSf https://astral.sh/uv/install.sh | sh
end

function __jst.get.omf -d "A fish plugin manager"
    omf -v; and return
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    omf install l
    exec fish
end

function __jst.get.neovim
    nvim --version; and return
    set where "$HOME/$MFA_DOWNLOADS_DIR/neovim"
    set here (pwd)
    __mfa.try-mkdir $where
    cd $where
    switch (uname)
    case Linux
        switch (uname -m)
        case aarch64
            jst git dl https://github.com/matsuu/neovim-aarch64-appimage/releases/download/v0.10.2/nvim-v0.10.2.aarch64.appimage
            mv nvim-v0.10.2.aarch64.appimage nvim
            chmod +x ./nvim
            jst path
        case x86_64
            switch (lsb_release -cs)
            case focal
        curl -SL https://github.com/neovim/neovim-releases/releases/download/v0.11.2/nvim-linux-x86_64.appimage -o nvim
                chmod +x ./nvim
                jst path
            case jammy
            end
        end
    case Darwin
        if test -e $where/nvim-macos-arm64.tar.gz
            rm $where/nvim-macos-arm64.tar.gz
        end
        jst git dl https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
        xattr -c ./nvim-macos-arm64.tar.gz
        tar xzvf nvim-macos-arm64.tar.gz
        rm nvim-macos-arm64.tar.gz
        jst path ./nvim-macos-arm64/bin
    end
    cd $here
    exec fish
end

function __jst.get.autojump
    command git clone git@github.com:wting/autojump.git --depth=1 $HOME/$MFA_DOWNLOADS_DIR/autojump
    command echo "source $HOME/$MFA_DOWNLOADS_DIR/autojump/bin/autojump.fish" >> $MFA_FISH_CONFIG_PATH
end

function __jst.get.pip
    pip --version; and return
    curl https://bootstrap.pypa.io/get-pip.py | python3
end

function __jst.get -d "Download and configure tools auto"
    __jst.get.$argv[1] $argv[2..-1]
end

