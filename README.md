## Usage

* Step 1: `git clone git@github.com:julyfun/mfa.fish.git`
* Step 2: In your `~/.config/fish/config.fish`, add:

```
source <path-to-repo-in-step-1>/mfa.fish
source <path-to-repo-in-step-1>/jst.fish # optional
```

## Introduction

这是一个神奇的快捷工具箱，只为 fish shell 提供，因为 fish shell 的语法舒服。分为两个部分：

`mfa.fish`: Mfans Fish-shell Assistant. 利用 mfans 服务器完成跨设备操作，以及一些不暴露给用户的快捷函数。

`jst.fish`: Just do something. 基于 `mfa.fish` 实现的超便捷指令。

## Todo

- [ ] mfa upa 时自动 mfa init
- [x] just 系列命令整合
- [ ] 用 toml 自定义短命令
- [ ] 建立 jst dl 下载和配置的清单。需要考虑用什么形式实现。

## Priciples

- 避免敏感操作，如 `apt upgrade`

