class Passwort2ai < Formula
  desc "Touch-ID-gated KeePass secret retrieval for terminals and AI agents"
  homepage "https://github.com/Silverstar187/passwort2ai-by-fingerprint"
  url "https://github.com/Silverstar187/passwort2ai-by-fingerprint/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "ed02fb7359925ea6f194fdbf278f4e1cb714565426276ee64b24a73d522a131f"
  license "MIT"
  version "0.5.1"

  depends_on :macos
  depends_on xcode: ["12.0", :build]

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
    doc.install "README.md", "SKILL.md", "CHANGELOG.md", "LICENSE"
  end

  def caveats
    <<~EOS
      Run `p2ai setup` once to enroll your master password in the macOS Keychain
      and pick your KeePass .kdbx via a native file dialog.

      `keepassxc-cli` is required at runtime — install via the cask if you don't
      already have KeePassXC.app:
        brew install --cask keepassxc

      Touch-ID-gated retrieval requires an Apple Silicon or Intel Mac with the
      Touch-ID hardware enrolled (`bioutil -c` shows ≥1 template).
    EOS
  end

  test do
    assert_match "Passwort2AI by Fingerprint", shell_output("#{bin}/p2ai -h")
    assert_match "fetch", shell_output("#{bin}/p2ai -h")
  end
end
