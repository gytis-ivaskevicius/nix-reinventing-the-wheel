{ system
, lib
, bootstrap
, bash
, binutils-unwrapped
, builders
, coreutils
, diffutils
, file
, findutils
, gawk
, gcc
, gnugrep
, gnumake
, gnused
, gnutar
, gzip
, lbzip2
, patchelf
, xz
}:

let
  inherit (lib) evalModules getExe;
  eval = it: evalModules {
    modules = [ (import ./base.options.nix { inherit lib; }) it ];
    specialArgs.system = system;
  };
  trace = it: builtins.trace it it;
  resolveFnOrAttrs = arg:
    let
      result = arg result;
    in
    if builtins.isFunction arg then result else arg;

in
{

  minimal = fnOrAttrs:
    let
      evaluated = eval (resolveFnOrAttrs fnOrAttrs);
    in
    {
      inherit (evaluated.config.drv) type all drvAttrs drvPath name pname version out outPath outputName;
      inherit (evaluated) config options;
    };

  gnumake = fnOrAttrs:
    builders.minimal (self: {
      imports = [
        (resolveFnOrAttrs fnOrAttrs)
        ./gnumake.options.nix
      ];
      builder = getExe bootstrap.ruby;
      deps = [ coreutils findutils diffutils gnused gnugrep gawk bash gcc gnutar xz gzip lbzip2 binutils-unwrapped file gnumake patchelf ];
      env.CC = "${gcc}/bin/gcc";
      env.SHELL = getExe bash;

    });

  runRuby = name: script:
    builders.minimal (self: {
      inherit name;
      builder = lib.getExe bootstrap.ruby;
      files.script = script;
      phases."phase-0-execScript" = "source $scriptPath";
    });

}
