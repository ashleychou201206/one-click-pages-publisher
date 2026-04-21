# One-Click Pages Publisher

Publish the latest local HTML file to GitHub Pages with one click.

Built for people who generate HTML reports locally, want to keep a single public URL updated, and do not want to use Git manually every time.

## Highlights

- Picks the newest `.html` file from a local folder
- Prefers filename date/version numbers over modified time
- Publishes directly to a GitHub Pages repository through the GitHub API
- Saves the token to macOS Keychain after first use
- Can inject a lightweight `Refresh Page` button into the published page

## Good Fit For

- AI-generated HTML reports
- Monthly or weekly report pages
- Research briefings
- Lightweight static microsites
- Non-technical publishing workflows

## Quick Start

```bash
chmod +x publish.command

export SOURCE_DIR="$HOME/Desktop/html-reports"
export TARGET_REPO="your-github-name/your-pages-repo"
export TARGET_BRANCH="main"
export TARGET_PATH="index.html"
export KEYCHAIN_ACCOUNT="your-github-name"

bash publish.command
```

On first run, the script asks for a GitHub token and stores it in macOS Keychain.

## How Latest File Selection Works

The script prefers filename numbers first.

Example:

- `report_2026_04_v0_5_0416.html`
- `report_2026_04_v0_6_0428.html`

The second file is treated as newer.

## Requirements

- macOS
- A GitHub Pages repository
- A GitHub token with repository contents write access
- `curl`, `ruby`, `base64`, and `security`

## Notes

- The page refresh button only reloads the online page
- It does not read local files or trigger publishing

## Docs

- English quick overview: `README.md`
- Chinese guide: [`README.zh-CN.md`](./README.zh-CN.md)
- Suggested repo metadata: [`REPO_METADATA.md`](./REPO_METADATA.md)

## License

MIT
