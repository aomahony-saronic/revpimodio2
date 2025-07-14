{
  description = "Development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    inputs.pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pyproject-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        #             let
        #               # Parse our pyproject.toml file in our directory
        #               project = pyproject-nix.lib.project.loadPyproject { projectRoot = ./.; };
        #             in 
        #               import ./new_shell.nix {
        #                 pkgs = pkgs;
        #                 shell_hook = import ./shell_hook.nix { 
        #                   lib = pkgs.lib; 
        #                   custom_config = custom_config; 
        #                   home_directory = home_directory;
        #                   shell = dev_shell;
        #                   extra_environment_variables = {
        #                     RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}";
        #                   };
        #                 };
        #                 # Include our Python packages into our devshell
        #                 packages = standard_dev_packages 
        #                               ++ (python.withPackages (project.renderers.withPackages { inherit python; }));
        #               };
        devShells.default = 
          let
            python = pkgs.python3;
            python_project = pyproject-nix.lib.project.loadPyproject {
              projectRoot = ./.;
            };
          in
            pkgs.mkShell {
              buildInputs = [
                python
              ];
              packages = python.withPackages (python_project.renderers.withPackages { inherit python; });

              shellHook = ''
                echo "Setting up development environment..."
                
                # Generate pyrightconfig.json
                cat > pyrightconfig.json << EOF
                  {
                    "include": [
                      "src"
                    ],
                    "exclude": [
                      "**/__pycache__",
                      "**/.pytest_cache"
                    ],
                    "reportMissingImports": true,
                    "reportMissingTypeStubs": false,
                  }
                  EOF
                
                echo "Generated pyrightconfig.json"
              '';
            };
      });
}
