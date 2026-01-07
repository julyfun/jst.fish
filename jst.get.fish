function __jst.get.btop
    type -q btop; and btop -v; and return
    switch (__jst.os)
    case Darwin
        brew install btop
    end
end

function __jst.get.picgo
    switch (__jst.os)
    case Darwin
        brew install picgo --cask
    end
end

function __jst.get.bun
    type -q bun; and bun --version; and return
    curl -fsSL https://bun.sh/install | bash
end

function __jst.get.tldr
    if type -q tldr; tldr -v; return; end
    python3 -m pip install tldr
end

function __jst.get.zoxide
    zoxide --version; and return
    set here (pwd)
    cd $JST_CACHE_DIR
    curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.8/zoxide_0.9.8-1_amd64.deb
    sudo dpkg -i zoxide_0.9.8-1_amd64.deb
    cd $here
end

function __jst.get.zed
    if type -q zed; zed --version; return; end
    curl -f https://zed.dev/install.sh | sh
end

function __jst.get.zig
    set url (curl -s https://ziglang.org/download/index.json | jq -r '.master["aarch64-macos"].tarball')
    set dir "$JST_DOWNLOADS_DIR/zig"
    jst try-mkdir "$dir"
    set here (pwd)
    cd $dir
    curl -L $url | tar xz
    fish_add_path "$JST_DOWNLOADS_DIR/zig"
    cd $here
end

function __jst.get.zigup
    set dir "$JST_DOWNLOADS_DIR/zigup"
    jst try-mkdir "$dir"
    switch (__jst.os)
    case Darwin
        curl -L https://github.com/marler8997/zigup/releases/download/v2025_05_24/zigup-aarch64-macos.tar.gz | tar xz -C "$dir"
    case Linux
        curl -L https://github.com/marler8997/zigup/releases/latest/download/zigup-x86_64-linux.tar.gz | tar xz -C "$dir"
    end
    jst path "$dir"
end

function __jst.get.zls
    switch (__jst.os)
    case Darwin
    case Linux
        curl -L https://builds.zigtools.org/zls-linux-x86_64-0.14.0.tar.xz | tar xz
    end
end

function __jst.get.zerotier
    zerotier --version; and return
    curl -s https://install.zerotier.com/ | bash
end

function __jst.get.fzf
    if type -q fzf
        return
    end
    switch (__jst.os)
    case Darwin
        brew install fzf
    case Linux
        sudo apt install fzf
    end
end

function __jst.get.rustup
    type -q rustup; and rustup -V; and return
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
    if type -q nvim; nvim --version; return; end
    set where "$JST_DOWNLOADS_DIR/neovim"
    set here (pwd)
    __jst.try-mkdir $where
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
            curl -SL https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.appimage -o nvim
                chmod +x ./nvim
                jst path
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

function __jst.get.pip
    pip --version; and return
    curl https://bootstrap.pypa.io/get-pip.py | python3
end

function __jst.get -d "Download and configure tools auto"
    __jst.get.$argv[1] $argv[2..-1]
end
