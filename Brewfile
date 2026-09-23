# Shared command-line tools
brew "eza"
brew "bat"
brew "fd"
brew "ripgrep"
brew "zoxide"
brew "stow"
brew "procs"
brew "glow"
brew "hunk"
tap "Giammarco-Ferranti/deja", trusted: { formula: "deja" }
brew "Giammarco-Ferranti/deja/deja"
tap "anomalyco/tap", trusted: { formula: "opencode" }
brew "anomalyco/tap/opencode"

if RUBY_PLATFORM.match?(/linux/)
  # Linux-only command-line tools
end

if RUBY_PLATFORM.match?(/darwin/)
  cask_args appdir: "/Applications"

  # macOS-only command-line tools
  brew "tmux"
  brew "watch"
  brew "httpie"
  brew "jq"
  brew "git"
  brew "ffmpeg"
  brew "gh"
  brew "fresh-editor"

  # macOS desktop applications
end
