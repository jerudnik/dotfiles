# Advanced Nix Patterns

Reference for complex Nix patterns used in this repository. Consult when working on
modules that require advanced lib functions, custom derivations, or platform-specific logic.

## Lib Helper Patterns

### optionalString

Include text conditionally in strings:

```nix
${lib.optionalString cfg.enableFeature "--feature-flag"}
${lib.optionalString (cfg.port != null) "--port ${toString cfg.port}"}
```

### filterAttrs / mapAttrs

Filter and transform attribute sets:

```nix
# Filter to enabled items only
enabledServers = lib.filterAttrs (name: server: server.enabled or true) cfg.servers;

# Transform each attribute
lib.mapAttrs (name: server: {
  command = server.command;
  args = server.args or [];
}) enabledServers;
```

### optionalAttrs

Conditionally include attributes:

```nix
{
  baseConfig = "value";
}
// lib.optionalAttrs (cfg.extraConfig != null) {
  extraConfig = cfg.extraConfig;
}
// lib.optionalAttrs cfg.enableDebug {
  debug = true;
  logLevel = "verbose";
}
```

## Platform-Specific Code

Include packages or config only on specific platforms:

```nix
home.packages = with pkgs; [
  common-package
] ++ lib.optionals pkgs.stdenv.isLinux [
  linux-only-package
] ++ lib.optionals pkgs.stdenv.isDarwin [
  darwin-only-package
];
```

## Assertion Pattern

Validate configuration with helpful error messages:

```nix
config = mkIf cfg.enable {
  assertions = [
    {
      assertion = cfg.requiredOption != null;
      message = "services.myservice.enable requires requiredOption to be set.";
    }
    {
      assertion = cfg.port > 1024 || config.users.users.root.name == "root";
      message = "Ports below 1024 require root privileges.";
    }
  ];
  # ... rest of config
};
```

## Custom Package Derivation

Template for packages in `pkgs/`:

```nix
{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchzip {
    url = "https://github.com/user/repo/archive/v${version}.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 files/* -t $out/share/path
    runHook postInstall
  '';

  meta = with lib; {
    description = "Brief description";
    homepage = "https://example.com";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
```

## Activation Script Patterns

### Setup Info Box

Display setup instructions after activation:

```nix
system.activationScripts.myservice-setup.text = ''
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  Service Name - Configuration Applied"
  echo "════════════════════════════════════════════════════════════"
  echo ""
  echo "  Next steps:"
  echo "    1. Run initial setup command"
  echo "    2. Configure authentication"
  echo ""
'';
```

### Pre/Post Activation Ordering

Control activation order for dependencies:

```nix
system.activationScripts.preActivation.text = ''
  # Runs before main activation - cleanup old state
  rm -rf /path/to/old/state
'';

system.activationScripts.postActivation.text = ''
  # Runs after main activation - apply settings
  /usr/bin/killall SystemUIServer 2>/dev/null || true
'';
```
