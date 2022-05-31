{ ruby_3_1 }:
{
  ruby = ruby_3_1.override {
    cursesSupport = false;
    docSupport = false;
    fiddleSupport = false;
    opensslSupport = false;
    rubygemsSupport = false;
    useRailsExpress = false;
    yamlSupport = false;
    zlibSupport = false;
    gdbmSupport = false;
  };
}
