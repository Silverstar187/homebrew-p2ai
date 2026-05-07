class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "1323352c9defdc9f2ba8a4d8cc399c0b7f13ff4184c9a629657145b4c48442be"
  license "MIT"

  bottle do
    root_url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases/download/v0.7.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "efe4cb20398c78dc0a3ebbbb20333b9000e71d37886de258085ed9795f870e49"
    sha256 cellar: :any_skip_relocation, tahoe:         "b07acce46f0b244c887a18ff1de87f7df2c28ec13e764c43e056ab6f5b24af7e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a46fe3a72daffb824274105f51eb25f3323f4d1e908fd497c1dd61ccc5608ef1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "37616b7f22bdbb7e0a6922f52e0af8ba9cbbca736ca6471a947ee55ae3641bc0"
  end
  version "0.7.1"

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
