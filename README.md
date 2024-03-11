## Usage

* Step 1: `git clone git@github.com:julyfun/mfa.fish.git`
* Step 2: In your `~/.config/fish/config.fish`, add:

```
source <path-to-repo-in-step-1>/mfa.fish
source <path-to-repo-in-step-1>/jst.fish # optional
```

| Command       | Param (Example)                                        | Result                                                       |
| ------------- | ------------------------------------------------------ | ------------------------------------------------------------ |
| `mfa upa`     | `mfa upa https://github.com/wangwc18/mygoFlaskProject` | Upload this address to Mfans server                          |
| `jst cmm`     |                                                        | Show git commit message help                                 |
| `jd`          | `jd python`                                            | Jump to subdirectory with similar name to `python`           |
| `jm`          | `jm fix typo`                                          | Commit all changes with message `fix typo`                   |
| `jp`          | `jp update README.md`                                  | Commit all changes and push with message `update README.md`  |
| `jst dl`      | `jst dl autojump`                                      | Download and configure `autojump` automatically              |
| `jst gf`      | `jst gf iostream`                                      | Search `iostream` in current directory by title and contents |
| `jst run`     | `jst run 1.cpp`                                        | Compile `1.cpp` with c++17 standard and run it               |
| `jst ret`     |                                                        | Return to the root folder of current repo                    |
| `jst git ig`  |                                                        | Generate a useful default `.gitignore` file                  |
| `jst git log` |                                                        | Show beautiful commit history of current repo                |
| `jst git o`   | `jst git o README.md`                                  | Open the github page of `README.md` in current folder        |

## Introduction

这是一个神奇的快捷工具箱，只为 fish shell 提供，因为 fish shell 的语法舒服。分为两个部分：

`mfa.fish`: Mfans Fish-shell Assistant. 利用 mfans 服务器完成跨设备操作，以及一些不暴露给用户的快捷函数。

`jst.fish`: Just do something. 基于 `mfa.fish` 实现的超便捷指令。

## Features

## Todo

- [ ] mfa upa 时自动 mfa init
- [x] just 系列命令整合
- [ ] 用 toml 自定义短命令
- [ ] 建立 jst dl 下载和配置的清单。需要考虑用什么形式实现。

## Priciples

- 避免敏感操作，如 `apt upgrade`

