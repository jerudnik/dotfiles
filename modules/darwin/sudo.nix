{ config, lib, ... }:

{
  security.sudo.extraConfig = ''
    ${config.system.primaryUser} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild *
  '';
}
