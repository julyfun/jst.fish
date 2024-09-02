## Install `jst.fish`

```
git clone git@github.com:julyfun/jst.fish.git
```

In your `~/.config/fish/config.fish`, add:

```
source <path_to_repo>/jst.fish
source <path_to_repo>/kickstart.fish # optional
```

**Extension:** If you want to setup your remote server, edit `$MFA_USER_HOST` in `~/.config/mfa/config.fish`, and then:

```
ssh-copy-id $MFA_USER_HOST
```

## Exapmle usage

| Command example    | Result                                                   |
| ------------------ | -------------------------------------------------------- |
| `jp`               | Show and commit all changes, then push to remote         |
| `jst t ros2`       | Get a ros2 template project of best practice             |
| `jst git log`      | Show beautiful git log                                   |
| `cpwd`             | Copy current dir path                                    |
| `jst fmt cpp`      | Add cpp format config here                               |
| `jd vim / jdr vim` | Jump to file named like `vim` in current dir / workspace |
| `jst run 1.cpp`    | Compile and run `1.cpp`                                  |
| `jst gf include`   | Search all `include` keyword under the dir               |
| `jst cmm`          | Remind you of a standard commit message form             |
| `jst find *.cpp`   | Find cpp file under the dir                              |
| `jst git ig`       | Generate a default `.gitignore` file                     |
| `jst git dl`       | Download github file with lightning speed                |
| `jst git o`        | Open this repo / repofile in github.com instantly        |
| `jst crun demo`    | Build the cmake project and run the executable `demo`    |
| `jst how`          | Create a template file with title and url filename       |
| `jcp`              | pipeline to this command to copy text to clipboard       |
| `jst his`          | Show and select command history to copy to clipboard     |
| `jst sc`           | In fish shell, source a bash file                        |
| `jst upgrade`      | Upgrade `jst.fish`                                       |
| `jst mi pip`       | Copy a pip mirror command to clipboard                   |
| `jst md tb 5 7`    | Copy a 5 \* 7 markdown table code to clipboard           |
| `jst up main.cpp`  | Upload `main.cpp` to server (Specify server first)       |
| `jst dl main.cpp`  | Download the file from server                            |
| `jst upa Hello!`   | Upload `Hello!` message to server on any OS              |
| `jst dla`          | Copy the just uploaded message                           |

![](https://telegraph-image-bhi.pages.dev/file/5793b27ff193a9afbbcb8.png)

## Introduction

这是一个神奇的快捷工具箱，只为 fish shell 提供，因为 fish shell 的语法舒服。

## Extensions

Some `jst` command would require these, but it's ok not to download them if you don't use the command:

### Linux

```
sudo apt install xclip
```

### Macos

```
no
```

## Todo

- [ ] mfa upa 时自动 mfa init
- [x] jst 系列命令整合
- [ ] 用 toml 自定义短命令
- [ ] 建立 jst dl 下载和配置的清单。需要考虑用什么形式实现。
- [x] jst title 支持汉字
- [ ] 统计为您节省多少时间，以及创作这个命令花了多久

## Principles

- 避免敏感操作，如 `apt upgrade`
