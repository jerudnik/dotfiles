{
  description = "John's nix-darwin and home-manager configuration";

  inputs = {
    # Nixpkgs (unstable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin (master tracks unstable)
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager (master tracks unstable)
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Determinate Nix module
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix theming framework (master tracks unstable)
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # treefmt for formatting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # mac-app-util creates trampoline apps so Spotlight/Raycast can index nix-installed .app bundles
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenCode - pinned to v1.0.204 for native skills support
    opencode = {
      url = "github:sst/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS hardware quirks and optimizations
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      determinate,
      sops-nix,
      stylix,
      treefmt-nix,
      opencode,
      nixos-hardware,
      mac-app-util,
      ...
    }@inputs:
    let
      # Supported systems
      systems = {
        darwin = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        linux = [
          "aarch64-linux"
          "x86_64-linux"
        ];
        all = [
          "aarch64-darwin"
          "x86_64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
      };

      # Helper to generate attributes for each system
      forAllSystems = nixpkgs.lib.genAttrs systems.all;

      # Custom overlay for local packages
      customOverlay = import ./overlays;

      # OpenCode overlay - use pinned version from flake input
      opencodeOverlay = system: final: prev: {
        # Disable checks/tests to prevent build hangs on macOS
        opencode = opencode.packages.${system}.default.overrideAttrs (old: {
          doCheck = false;
        });
      };

      # Overlay list per system
      mkOverlays = system: [
        customOverlay
        (opencodeOverlay system)
      ];

      # Shared pkgs constructor
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = mkOverlays system;
        };

      # Common special args passed to all modules (omit pkgs to avoid specialArgs.pkgs assertion)
      mkSpecialArgs = _system: {
        inherit inputs self;
      };

      # Binary cache configuration for faster builds
      nixConfig = {
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gNypCz8Q4uWN73apakVujGOGc74Q="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # Helper to create darwin system configurations
      mkDarwinSystem =
        {
          hostname,
          hostPath,
          username,
        }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = mkSpecialArgs "aarch64-darwin";
          modules = [
            # Provide pkgs explicitly for this system; clear nixpkgs.config since pkgs is external
            {
              nixpkgs.pkgs = mkPkgs "aarch64-darwin";
              nixpkgs.config = { };
            }

            # Determinate Nix module
            determinate.darwinModules.default

            # Stylix theming
            stylix.darwinModules.stylix

            # mac-app-util for Spotlight/Raycast integration
            mac-app-util.darwinModules.default

            # Host-specific configuration
            hostPath

            # home-manager integration
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mkSpecialArgs "aarch64-darwin";
                users.${username} = ./users/${username}/home.nix;
                backupFileExtension = "backup";

                # mac-app-util for Spotlight/Raycast integration
                sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
              };
            }

            # sops-nix for secrets
            sops-nix.darwinModules.sops
          ];
        };

      # Helper to create NixOS system configurations
      mkNixosSystem =
        {
          hostname,
          hostPath,
          username,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs system;
          modules = [
            # Provide pkgs explicitly for this system
            { nixpkgs.pkgs = mkPkgs system; }

            # Stylix theming
            stylix.nixosModules.stylix

            # Host-specific configuration
            hostPath

            # home-manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mkSpecialArgs system;
                users.${username} = ./users/${username}/home-linux.nix;
                backupFileExtension = "backup";
              };
            }

            # sops-nix for secrets
            sops-nix.nixosModules.sops
          ];
        };
    in
    {
      # ============================================================
      # Darwin (macOS) Configurations
      # ============================================================
      darwinConfigurations = {
        # serious-callers-only - AI inference server and primary workstation
        "serious-callers-only" = mkDarwinSystem {
          hostname = "serious-callers-only";
          hostPath = ./hosts/serious-callers-only;
          username = "john";
        };

        # MacBook Air - Work laptop
        "just-testing" = mkDarwinSystem {
          hostname = "just-testing";
          hostPath = ./hosts/just-testing;
          username = "jrudnik";
        };
      };

      # ============================================================
      # NixOS Configurations
      # ============================================================
      nixosConfigurations = {
        # Google Pixelbook (2017) - Portable NixOS workstation
        "sleeper-service" = mkNixosSystem {
          hostname = "sleeper-service";
          hostPath = ./hosts/sleeper-service;
          username = "john";
          system = "x86_64-linux";
        };
      };

      # ============================================================
      # Development Shells
      # ============================================================
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              # Script for applying the nix-darwin configuration
              (writeShellApplication {
                name = "apply";
                runtimeInputs = [
                  nix-darwin.packages.${system}.darwin-rebuild or null
                ];
                text = ''
                  echo "Applying nix-darwin configuration..."
                  HOSTNAME=$(scutil --get LocalHostName)
                  sudo darwin-rebuild switch --flake ".#$HOSTNAME"
                  echo "Configuration applied successfully!"
                '';
              })

              # Script for updating flake inputs
              (writeShellApplication {
                name = "update";
                text = ''
                  echo "Updating flake inputs..."
                  nix flake update
                  echo "Flake inputs updated!"
                '';
              })

              # Formatter
              self.formatter.${system}

              # Secrets management
              sops
              age
              age-plugin-yubikey # Yubikey-backed age encryption
              yubikey-manager # ykman CLI for Yubikey management
              ssh-to-age # Convert SSH keys to age format
            ];
          };
        }
      );

      # ============================================================
      # Formatter
      # ============================================================
      formatter = forAllSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix { inherit pkgs; })
      );
    };
}
