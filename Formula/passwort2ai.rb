class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "daee195d314f91ebde124f905d4bdeda3164e195c7a1dd8def437b4ccef59f18"
  license "MIT"

  bottle do
    root_url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases/download/v0.7.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a45302dc0fb5d55e2f71917fe69b94b6f5cfd6ac9a89059648bb21a503ee82c6"
    sha256 cellar: :any_skip_relocation, tahoe:         "00d3974e878ab5761e1086a3e3e55a6ea0e4e2378183d1a41c0e9f1de892b8df"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f6c7e4723bfff98ff3d0e583aa07a1def996aa8e68cb12df11dacd93e1e8edc4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "73f0bf1da4835925dba66bfbeb7b8fc7e29543709014a37637434ff1efbc807c"
  end


  version "0.7.3"

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
