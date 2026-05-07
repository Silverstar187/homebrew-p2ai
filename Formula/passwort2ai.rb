class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "daee195d314f91ebde124f905d4bdeda3164e195c7a1dd8def437b4ccef59f18"
  license "MIT"

  bottle do
    root_url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases/download/v0.7.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e7c9b0425a6f856439dad82d18c3fa770937e20e2180ec3679e6c3f5ee14a0a3"
    sha256 cellar: :any_skip_relocation, tahoe:         "8b746ca09d3b3f2ea89c56dfbfdcd84b0dbe5c42fb5104589984c6790d07bc2f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5160209bd7a5b4d31dc57611e79c7ae2a232962c4bdb311649dde35156016d34"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "615893c569890ccb49c8538fcd79c30f00363d548d2467ec923b9b0683cd81ea"
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
