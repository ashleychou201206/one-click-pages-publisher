# 一键发布到 GitHub Pages

这是一个面向非技术用户的轻量发布工具，用来把本地文件夹中最新的 HTML 文件，一键发布到 GitHub Pages。

它特别适合这些场景：

- 用 ChatGPT 或其他 AI 工具生成 HTML 报告
- 持续更新同一个公开网页链接
- 不想每次手动登录 GitHub 上传文件
- 不熟悉 `git add`、`commit`、`push`
- 想把“本地生成内容”快速变成“在线可访问页面”

## 主要功能

- 自动扫描本地文件夹中的 `.html` 文件
- 优先按文件名中的日期或版本号判断最新文件
- 自动覆盖发布到 GitHub 仓库中的目标页面，例如 `index.html`
- 首次输入 GitHub Token 后，自动保存到 macOS 钥匙串
- 支持在发布后的页面中自动注入一个 `Refresh Page` 按钮

## 适合谁用

- 行业研究人员
- 市场和运营团队
- 咨询顾问
- 独立创作者
- 用 AI 生成网页内容的人

## 它解决了什么问题

很多人已经可以用 AI 快速生成网页内容，但“把本地 HTML 稳定更新到固定在线链接”这一步，仍然比较麻烦。

这个工具的目标就是把发布过程简化成：

1. 把新 HTML 文件放进本地文件夹
2. 双击运行脚本
3. 在线页面更新完成

## 工作原理

1. 你把多个 HTML 文件放在一个本地目录中
2. 脚本自动找到其中最新的文件
3. 脚本通过 GitHub API 把它上传到指定仓库
4. 仓库中的目标文件被覆盖更新
5. GitHub Pages 随后展示新的页面内容

如果别人之前已经打开旧页面，可能需要手动刷新浏览器才能看到最新内容。

## 如何判断“最新文件”

脚本优先根据文件名中的数字序列来判断版本新旧，而不是只看修改时间。

例如：

- `report_2026_04_v0_5_0416.html`
- `report_2026_04_v0_6_0428.html`

脚本会把第二个文件识别为更新版本。

只有在文件名数字完全相同时，才会使用修改时间作为补充判断。

## 使用要求

- macOS
- 已配置 GitHub Pages 的 GitHub 仓库
- 具有仓库写权限的 GitHub Personal Access Token
- 系统中可用 `curl`、`ruby`、`base64` 和 `security`

## 快速开始

1. 下载或复制 `publish.command`
2. 赋予执行权限：

```bash
chmod +x publish.command
```

3. 配置环境变量：

```bash
export SOURCE_DIR="$HOME/Desktop/html-reports"
export TARGET_REPO="your-github-name/your-pages-repo"
export TARGET_BRANCH="main"
export TARGET_PATH="index.html"
export KEYCHAIN_ACCOUNT="your-github-name"
```

4. 运行脚本：

```bash
bash publish.command
```

首次运行时，脚本会提示输入 GitHub Token，并把它保存到 macOS 钥匙串中。后续通常不需要重复输入。

## GitHub Token 建议权限

推荐使用：

- Fine-grained personal access token
- 只授权给目标仓库
- `Contents` 权限设置为 `Read and write`

也可以使用 classic token，但权限范围通常更大。

## 安全说明

- 仓库中不包含任何个人 token
- token 不会写入代码仓库
- token 保存在本地 macOS 钥匙串
- 仓库名、账号名、本地路径都由使用者自行配置

## 限制说明

- 当前版本仅适用于 macOS
- 当前设计主要面向单个 HTML 页面发布
- 页面上的 `Refresh Page` 按钮只负责刷新线上页面
- `Refresh Page` 按钮不会读取本地文件，也不会触发发布

## 推荐仓库定位

如果你要公开发布这个项目，可以把它描述为：

“一个给非技术用户使用的 GitHub Pages 一键发布工具，用来把本地最新 HTML 页面快速更新到固定在线链接。”

## 许可证

MIT
