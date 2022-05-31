{
  description = "Nix builders POC";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlay ]; };
    in
    {

      overlay = final: prev: {
        basePackages = final.callPackage ./basePackages.nix { };
        builders = final.callPackage ./builders { bootstrap = final.basePackages; };
      };

      packages.x86_64-linux = pkgs.callPackage ./example.nix { };

      checks = self.packages;
    };
}
