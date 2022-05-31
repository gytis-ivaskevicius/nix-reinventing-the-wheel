{ pkgs, ... }:
rec  {
  default = gcc;
  runRubyTest = pkgs.builders.runRuby "test" "touch($out)";

  gcc = pkgs.builders.gnumake {
    inherit (pkgs.gcc-unwrapped) pname version src;

    configureFlags = [
      "--disable-libcc1"
      "--disable-bootstrap"
      "--with-newlib"
      "--without-headers"
      "--enable-initfini-array"
      "--disable-nls"
      "--disable-shared"
      "--disable-multilib"
      "--disable-decimal-float"
      "--disable-threads"
      "--disable-libatomic"
      "--disable-libgomp"
      "--disable-libquadmath"
      "--disable-libssp"
      "--disable-libvtv"
      "--disable-libstdcxx"
      "--enable-languages=c,c++"
    ];

    deps = [ mpfr gmp m4 mpc pkgs.libtool ];
    checkPhase = null;
    debug = true;
  };

  mpc = pkgs.builders.gnumake {
    inherit (pkgs.libmpc) pname version src;

    deps = [ gmp mpfr ];
    checkPhase = null; # Passes
    debug = true;
  };

  mpfr = pkgs.builders.gnumake {
    inherit (pkgs.mpfr) pname version src;

    deps = [ gmp ];
    checkPhase = null; # Passes
    debug = true;
  };

  gmp = pkgs.builders.gnumake {
    inherit (pkgs.gmp) pname version src;
    deps = [ m4 ];
    checkPhase = null; # Passes
    debug = true;
  };

  m4 = pkgs.builders.gnumake {
    inherit (pkgs.m4) pname version src;
    deps = [ pkgs.help2man ];
    checkPhase = null; # Fails
    debug = true;
  };
}
