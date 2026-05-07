class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.9.1.tar.gz"
  sha256 "32caf91625b77650cfe47b315e801fba977126caa0fcaae0d8ee3f490f187b39"
  license "MIT"

  bottle do
    root_url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases/download/v0.9.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6d491d0edc1d06e402a4b5cd7c2b6aa988a4675622872419c19405411e5a285d"
    sha256 cellar: :any_skip_relocation, tahoe:         "6c786e3aadf581839eaf487b10ed28e16dcedad797575230c60f1d087b553629"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4bf7e06036e3cd396b6c22e51133154fac284d26f0c9208eb12bc28869a7f2f0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2d98896c4c5220e6fe2b221e7a18e79ad233367c085f1ee99dff18d8d2817e03"
  end






  version "0.9.1"

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
