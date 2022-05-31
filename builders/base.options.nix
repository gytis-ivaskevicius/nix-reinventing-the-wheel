{ lib }:
let
  inherit (lib) types mkOption literalExpression filterAttrs mkDefault getExe mkEnableOption;
  inherit (types) either submodule nullOr attrsOf oneOf str bool float int path package listOf anything;
  inherit (builtins) attrNames attrValues mapAttrs isList;
  typeOneOfStringLike = oneOf [ package path bool float int str (listOf (either str path)) ];
in
{ config, system, ... }: {
  options = {

    debug = mkEnableOption "Enable debug mode";

    name = mkOption {
      description = "Full package name";
      example = "llvm-13.0.0";
      type = str;
    };

    pname = mkOption {
      description = "Package name";
      example = "llvm";
      default = null;
      type = nullOr str;
    };

    version = mkOption {
      description = "Package version";
      example = "13.0.0";
      default = null;
      type = nullOr str;
    };

    outputs = mkOption {
      description = "List of derivation outputs";
      example = [ "out" "bin" "lib" "man" "info" "dev" ];
      default = [ "out" ];
      type = listOf str;
    };

    env = mkOption {
      default = { };
      description = "Environment variables";
      example = {
        XDG_DATA_DIR = "xyz";
      };
      type = attrsOf typeOneOfStringLike;
    };

    source = mkOption {
      default = [ ];
      description = "Files to source before executing phases";
      example = [ /path/to/some/file.rb ];
      type = oneOf [ path str (listOf str) ];
      apply = it: if isList it then it else [ it ];
    };

    buildtimeDeps = mkOption {
      default = [ ];
      description = "Dependencies that are required during build only (executabes/tools)";
      example = literalExpression "[ pkgs.python3 ]";
      type = listOf package;
    };

    deps = mkOption {
      default = [ ];
      description = "Package dependencies";
      example = literalExpression "[ pkgs.zlib ]";
      type = listOf package;
    };

    files = mkOption {
      default = { };
      description = "Variables that should be passed as file";
      example = "abcScript";
      type = attrsOf typeOneOfStringLike;
    };

    # TODO: think of nicer DSL
    phases = mkOption {
      type = attrsOf (nullOr str);
      default = { };
      example = literalExpression "lib.mkPhase 123 \"doTheThing\" \"`echo hello world`\"";
      description = "phases to be executed during build";
    };

    builder = mkOption {
      type = str;
      description = "Interpreter to be used";
    };

    args = mkOption {
      type = listOf (either str path);
      description = "Derivation arguments";
      default = [ "-I${./scripts}" ./scripts/builder.rb ];
    };

    src = mkOption {
      type = nullOr package;
      example = literalExpression "pkgs.fetchFromGithub {...}";
      default = null;
      description = "Sources derivation";
    };

    drvOpts = mkOption {
      type = attrsOf anything;
      default = { };
    };

    drv = mkOption {
      type = package;
      readOnly = true;
    };

  };

  config =
    let
      computedDrvAttrs = filterAttrs (_: it: it != null) (config.files // {
        inherit (config) name pname version outputs builder args source;
        inherit system;
        passAsFile = attrNames config.files;
      });
    in
    {
      name = mkDefault (config.pname + "-" + config.version);
      files.drvOpts = builtins.toJSON config.drvOpts;
      drv = derivation computedDrvAttrs // config.env;
    };

}
