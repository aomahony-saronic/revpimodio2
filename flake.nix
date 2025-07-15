{
  description = "Development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
  };

  outputs = { self, nixpkgs, flake-utils, pyproject-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = 
          let
            python = pkgs.python3;
            python_project = pyproject-nix.lib.project.loadRequirementsTxt {
              projectRoot = ./.;
            };
          in
            pkgs.mkShell {
              packages = [(python.withPackages (python_project.renderers.withPackages { inherit python; }))];

              shellHook = ''
                echo "Setting up development environment..."
                
                # Generate pyrightconfig.json
                cat > pyrightconfig.json << 'EOF'
{
  "include": [
    "src"
  ],
  "exclude": [
    "**/__pycache__",
    "**/.pytest_cache"
  ],
  "reportMissingImports": true,
  "reportMissingTypeStubs": false
  "reportOptionalMemberAccess": "none"
}
EOF
                
                echo "Generated pyrightconfig.json"
              '';
            };
      });
}
