{ lib, config, system, ... }:
let
  inherit (lib) mkOption mkDefault types filterAttrs;
  inherit (types) either submodule nullOr attrsOf oneOf str bool float int path package listOf anything;
in
{
  imports = [
    ./commonPhases.options.nix
  ];

  options = {
    configureScriptPath = mkOption {
      default = "./configure";
      description = "Path of 'configure' script";
      example = "./xyz/configure";
      type = str;
    };

    configureFlags = mkOption {
      default = [ "--prefix=$out" "--host=${system}" ];
      description = "List of flags to be passed to 'configure' script";
      example = [ "--xyz" ];
      type = listOf (oneOf [ package path bool float int str ]);
    };


    makefilePath = mkOption {
      default = null;
      description = "Path of makefile";
      example = "./xyz/Makefile";
      type = nullOr str;
    };

    makeFlags = mkOption {
      default = [ ];
      description = "List of flags to be passed to gnumake";
      example = [ "--prefix=$out/xyz" ];
      type = listOf (oneOf [ package path bool float int str ]);
    };

    buildFlags = mkOption {
      default = [ ];
      description = "List of flags to be passed to during build phase";
      example = [ "--prefix=$out/xyz" ];
      type = listOf (oneOf [ package path bool float int str ]);
    };

    checkFlags = mkOption {
      default = [ ];
      description = "List of flags to be passed to during check phase";
      example = [ "--prefix=$out/xyz" ];
      type = listOf (oneOf [ package path bool float int str ]);
    };

    installFlags = mkOption {
      default = [ ];
      description = "List of flags to be passed to during install phase";
      example = [ "--prefix=$out/xyz" ];
      type = listOf (oneOf [ package path bool float int str ]);
    };
  };

  config = {
    drvOpts = {
      inherit (config)
        src
        source
        buildtimeDeps
        deps
        configureScriptPath
        configureFlags
        makefilePath
        makeFlags
        buildFlags
        checkFlags
        installFlags
        ;
      phases = filterAttrs (_: it: it != null) config.phases;
    };

    source = [ ./scripts/phases.rb ];

    phases.phase-0-setup = config.setupPhase;
    phases.phase-10-unpack = config.unpackPhase;
    phases.phase-20-patch = config.patchPhase;
    phases.phase-30-configure = config.configurePhase;
    phases.phase-40-build = config.buildPhase;
    phases.phase-50-check = config.checkPhase;
    phases.phase-60-install = config.installPhase;
    phases.phase-70-patchelf = config.patchelfPhase;
    phases.phase-80-strip = config.stripPhase;
    phases.phase-90-patchShebangs = config.patchShebangsPhase;
    phases.phase-100-compresManPages = config.compressManPagesPhase;

    setupPhase = mkDefault "load_environment";
    unpackPhase = mkDefault "unpack_phase";
    configurePhase = mkDefault "configure_phase";
    buildPhase = mkDefault "build_phase";
    checkPhase = mkDefault "check_phase";
    installPhase = mkDefault "install_phase";
    patchelfPhase = "patchelf_phase";
  };
}
