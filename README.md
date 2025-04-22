# Marble Browser

This is a flake for Marble browser.

Just add it to your NixOS `flake.nix` or home-manager:

```nix
inputs = {
  zen-browser.url = "github:Erizur/marble-flake";
  ...
}
```

## 1Password

Marble has to be manually added to the list of browsers that 1Password will communicate with. See [this wiki article](https://nixos.wiki/wiki/1Password) for more information. To enable 1Password integration, you need to add the line `.marble-wrapped` to the file `/etc/1password/custom_allowed_browsers`.
