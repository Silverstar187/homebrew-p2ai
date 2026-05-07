class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.9.4.tar.gz"
  sha256 "cc03677bfad17ec78285b538e2bc9f7366293ecf54c214402780ff42ea880c6d"
  license "MIT"

  bottle do
    root_url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases/download/v0.9.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "97ab97758808bf0b023237604070dbd5f1bd84c5e48c1499a0c71ff196a5781c"
    sha256 cellar: :any_skip_relocation, tahoe:         "7e371890f2719c63fa1f52b0188feb47d790569f5729a41046224e51c268cdd7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "857fc68aa5cbe9aa6599567174ebce547309828d9298fe8fd9c8556c09b00d5f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "126c3e8515383081c35c47f7d7e41fcbbe9dfec416471a4321d827318ae33948"
  end








  version "0.9.4"

  depends_on :macos

  def install
    # Compile native Swift binaries
    %w[p2ai-master p2ai-agent].each do |name|
      system "swiftc", "src/#{name}.swift", "-o", "bin/#{name}", "-O"
    end

    # Install CLI + native binaries
    bin.install "bin/p2ai"
    libexec.install "bin/p2ai-master", "bin/p2ai-agent"

    # Patch p2ai to find native binaries in libexec
    inreplace bin/"p2ai" do |s|
      s.gsub! 'P2AI_MASTER_BIN="${P2AI_MASTER_BIN:-$SCRIPT_DIR/p2ai-master}"',
              "P2AI_MASTER_BIN=\"${P2AI_MASTER_BIN:-#{libexec}/p2ai-master}\""
      s.gsub! 'P2AI_AGENT_BIN="${P2AI_AGENT_BIN:-$SCRIPT_DIR/p2ai-agent}"',
              "P2AI_AGENT_BIN=\"${P2AI_AGENT_BIN:-#{libexec}/p2ai-agent}\""
    end

    # Docs
    doc.install "README.md", "CHANGELOG.md", "LICENSE"
    # SKILL.md goes to pkgshare so `p2ai install-skill` can find it
    pkgshare.install "SKILL.md"
  end

  def caveats
    s = <<~EOS
      Run to finish setup:
        p2ai setup    # enroll master password in Keychain, create ~/passwords.kdbx

      `keepassxc-cli` is required at runtime:
        brew install --cask keepassxc

      For AI agents, run once per project:
        p2ai system-prompt --target cursor  >> .cursorrules   # Cursor / Cline
        p2ai system-prompt --target aider   >> .aider.conf.yml
        p2ai system-prompt --target claude  >> CLAUDE.md
    EOS
    if File.directory?("#{Dir.home}/.claude")
      s += "\nClaude Code detected — run `p2ai install-skill` to register the skill.\n"
    end
    s
  end

  test do
    assert_match "Passwort2AI by Fingerprint", shell_output("#{bin}/p2ai -h")
    assert_match "fetch", shell_output("#{bin}/p2ai -h")
  end
end
