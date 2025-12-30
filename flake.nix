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

    # TODO: Re-enable mac-app-util when upstream issue is resolved
    # mac-app-util creates trampoline apps so Spotlight/Raycast can index nix-installed .app bundles
    # Currently broken due to gitlab.common-lisp.net returning 404 for the 'iterate' library
    # Upstream issue: https://github.com/hraban/mac-app-util/issues/39
    # mac-app-util = {
    #   url = "github:hraban/mac-app-util";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # MCP servers as Nix packages (no npx at runtime)
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenCode - pinned to v1.0.204 for native skills support
    opencode = {
      url = "github:sst/opencode/v1.0.204";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Emacs overlay - bleeding-edge Emacs packages and variants
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      mcp-servers-nix,
      opencode,
      emacs-overlay,
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
        opencode = opencode.packages.${system}.default;
      };

      # Common special args passed to all modules
      mkSpecialArgs = system: {
        inherit inputs self;
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            customOverlay
            (opencodeOverlay system)
            emacs-overlay.overlays.default
          ];
        };
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
            # Determinate Nix module
            determinate.darwinModules.default

            # Stylix theming
            stylix.darwinModules.stylix

            # TODO: Re-enable mac-app-util when upstream issue is resolved
            # See inputs section for details on the gitlab.common-lisp.net 404 issue
            # mac-app-util.darwinModules.default

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

                # TODO: Re-enable mac-app-util sharedModules when upstream issue is resolved
                # sharedModules = [
                #   mac-app-util.homeManagerModules.default
                # ];
              };
            }

            # sops-nix for secrets
            sops-nix.darwinModules.sops
          ];
        };
    in
    {
      # ============================================================
      # Darwin (macOS) Configurations
      # ============================================================
      darwinConfigurations = {
        # Mac Studio - AI inference server and primary workstation
        "seriousCallersOnly" = mkDarwinSystem {
          hostname = "seriousCallersOnly";
          hostPath = ./hosts/mac-studio;
          username = "john";
        };

        # MacBook Air - Work laptop
        "inOneEar" = mkDarwinSystem {
          hostname = "inOneEar";
          hostPath = ./hosts/inOneEar;
          username = "jrudnik";
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
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
