{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (types) nullOr str;

  mkPhaseOption = name: mkOption {
    description = "${name} phase";
    default = null;
    example = "doSomething()";
    type = nullOr str;
  };
in
{
  options = {
    setupPhase = mkPhaseOption "Setup";
    unpackPhase = mkPhaseOption "Unpack";
    patchPhase = mkPhaseOption "Patch";
    configurePhase = mkPhaseOption "Configure";
    buildPhase = mkPhaseOption "Build";
    checkPhase = mkPhaseOption "Check";
    installPhase = mkPhaseOption "Install";
    patchelfPhase = mkPhaseOption "Patchelf";
    stripPhase = mkPhaseOption "Strip";
    patchShebangsPhase = mkPhaseOption "Patch shebangs";
    compressManPagesPhase = mkPhaseOption "Compress man pages";
  };

}
