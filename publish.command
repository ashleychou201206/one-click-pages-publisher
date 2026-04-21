#!/bin/bash

set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-$HOME/Desktop/html-reports}"
TARGET_REPO="${TARGET_REPO:-owner/repo-name}"
TARGET_PATH="${TARGET_PATH:-index.html}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-one-click-pages-publisher-token}"
KEYCHAIN_ACCOUNT="${KEYCHAIN_ACCOUNT:-github-user}"
API_ROOT="https://api.github.com/repos/$TARGET_REPO/contents/$TARGET_PATH"

WORK_FILE="$(mktemp "/tmp/one-click-pages.XXXXXX.html")"
PAYLOAD_FILE="$(mktemp "/tmp/one-click-pages-payload.XXXXXX.json")"
RESPONSE_FILE="$(mktemp "/tmp/one-click-pages-response.XXXXXX.json")"

finish() {
  status=$?
  rm -f "$WORK_FILE" "$PAYLOAD_FILE" "$RESPONSE_FILE"
  if [[ -t 0 ]]; then
    echo
    if [[ $status -eq 0 ]]; then
      echo "Finished successfully."
    else
      echo "Script failed with exit code $status."
    fi
    read -r -p "Press Enter to close..."
  fi
}
trap finish EXIT

if [[ "$TARGET_REPO" == "owner/repo-name" ]]; then
  echo "Please set TARGET_REPO before publishing."
  echo "Example:"
  echo '  export TARGET_REPO="your-github-name/your-pages-repo"'
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  GITHUB_TOKEN="$(security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" -w 2>/dev/null || true)"
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  printf "Enter your GitHub token: "
  read -rs GITHUB_TOKEN
  echo
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GitHub token is required."
  exit 1
fi

if ! security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" >/dev/null 2>&1; then
  security add-generic-password -U -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" -w "$GITHUB_TOKEN" >/dev/null
  echo "Saved GitHub token to your Mac Keychain for future one-click publishing."
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source folder not found: $SOURCE_DIR"
  exit 1
fi

SOURCE_FILE="$(ruby -e '
source_dir = File.expand_path(ARGV[0])
work_file = ARGV[1]

def version_key(path)
  name = File.basename(path, ".html")
  groups = name.scan(/\d+/)
  return [-1] if groups.empty?
  groups.map { |group| [group.length, group.to_i] }.flatten
end

html_files = Dir.children(source_dir)
  .map { |name| File.join(source_dir, name) }
  .select { |path| File.file?(path) && File.extname(path).downcase == ".html" }
  .sort_by { |path| [version_key(path), File.mtime(path).to_i, File.basename(path)] }
  .reverse

abort("No HTML files found in #{source_dir}") if html_files.empty?

source = html_files.first
html = File.read(source, encoding: "UTF-8")
marker = %q{id="site-refresh-button"}

unless html.include?(marker)
  snippet = <<~HTML
    <style>
      .site-refresh-shell{position:fixed;right:18px;top:18px;z-index:9999}
      .site-refresh-button{border:0;border-radius:999px;padding:12px 18px;background:#0f8f6f;color:#fff;font:600 15px/1 -apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;box-shadow:0 10px 24px rgba(15,143,111,.24);cursor:pointer}
      .site-refresh-button:hover{background:#0a7d61}
      @media (max-width:720px){
        .site-refresh-shell{right:14px;top:14px}
      }
    </style>
    <div class="site-refresh-shell">
      <button id="site-refresh-button" class="site-refresh-button" type="button" onclick="window.location.reload()">Refresh Page</button>
    </div>
  HTML
  html = html.include?("</body>") ? html.sub("</body>", "#{snippet}\n</body>") : html + snippet
end

File.write(work_file, html)
puts source
' "$SOURCE_DIR" "$WORK_FILE")"

echo "Prepared latest report from source folder."
echo "Source file: $SOURCE_FILE"

SHA="$(curl -fsS -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "$API_ROOT?ref=$TARGET_BRANCH" 2>/dev/null | ruby -rjson -e 'input = STDIN.read.strip; if input.empty? then print "" else data = JSON.parse(input) rescue {}; print(data["sha"] || "") end' || true)"

MESSAGE="Publish latest local HTML report"

ruby -rjson -e '
work_file = ARGV[0]
content_b64 = [File.binread(work_file)].pack("m0")
payload = {
  "message" => ARGV[1],
  "content" => content_b64,
  "branch" => ARGV[2]
}
payload["sha"] = ARGV[3] unless ARGV[3].nil? || ARGV[3].empty?
puts JSON.generate(payload)
' "$WORK_FILE" "$MESSAGE" "$TARGET_BRANCH" "$SHA" > "$PAYLOAD_FILE"

curl -fsS -X PUT \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD_FILE" \
  "$API_ROOT" > "$RESPONSE_FILE"

ruby -rjson -e '
data = JSON.parse(File.read(ARGV[0], encoding: "UTF-8"))
commit = data["commit"] || {}
content = data["content"] || {}
puts "Publish complete."
puts "File: #{content["html_url"]}" if content["html_url"]
puts "Commit: #{commit["html_url"]}" if commit["html_url"]
puts "GitHub Pages usually refreshes within about 1 minute."
' "$RESPONSE_FILE"
