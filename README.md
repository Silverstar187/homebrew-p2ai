# Homebrew tap for Passwort2AI by Fingerprint

Brew formula for [`passwort2ai-by-fingerprint`](https://github.com/Silverstar187/passwort2ai-by-fingerprint) — Touch-ID-gated KeePass secret retrieval for terminals and AI agents.

## Install

```bash
brew install silverstar187/p2ai/passwort2ai
```

That's it. After install, run `p2ai setup` once.

## What this tap does

- Pulls the [pinned source release](https://github.com/Silverstar187/passwort2ai-by-fingerprint/releases) (SHA-pinned tarball).
- Compiles the Swift binaries (`p2ai-master`, `p2ai-agent`) locally.
- Installs the `p2ai` CLI to your Homebrew prefix.
- Recommends `keepassxc` (for `keepassxc-cli`).

## Updates

```bash
brew upgrade passwort2ai
```

The formula is auto-bumped on each upstream release tag.

## License

MIT (matches upstream).
