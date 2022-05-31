require 'json'
require 'shellutils'

$drvOpts = JSON.parse(File.read(ENV['drvOptsPath']))
$build_cores = get_build_cores

def add_to_env(paths)
  add_to_path paths
  add_to_cpath paths
  add_to_library_path paths
end

def add_to_path(paths)
  ENV['PATH'] = paths.map { |it| it.strip + '/bin' }
                     .filter { |it| File.exist?(it) }
                     .join(':')
end

def add_to_cpath(paths)
  ENV['CPATH'] = paths.map { |it| it.strip + '/include' }
                      .filter { |it| File.exist?(it) }
                      .join(':')
end

def add_to_library_path(paths)
  ENV['LIBRARY_PATH'] = paths.map { |it| it.strip + '/lib' }.join(':')
end

def find_all_deps(paths)
  paths + paths.map { |it| it + '/nix-support/propagated-build-inputs' }
               .filter { |it| File.exist?(it) }
               .flat_map { |it| find_all_deps File.read(it).split('\s+') }
end

def find_inputs(paths)
  add_to_env(find_all_deps(paths))
end

def load_environment
  source_all
  find_inputs($drvOpts['deps'] + $drvOpts['buildtimeDeps'])

  debug $drvOpts
  debug 'Env variables:'
  ENV.each { |k, v| debug "#{k} = #{v}" }
end

def phases
  $drvOpts['phases']
    .map do |k, v|
      key = k.split('-')
      index = key[1].to_i
      name = key[2]
      value = "puts('### Executing phase-#{index}-#{name}')\n" + v
      [index, value]
    end
    .sort
    .to_h
end

# runCommand()
# {
#     findInputs "$buildInputs"
#     findInputs "$propagatedBuildInputs"
#
#     # Write propagated build inputs to config file
#
#     if [ -n "$propagatedBuildInputs" ]
#     then
#         mkdir -p $out/nix-support
#         echo "$propagatedBuildInputs" > $out/nix-support/propagated-build-inputs
#     fi
#
#     # Write setup hooks to config file
#
#     if [ -n "$setupHook" ]
#     then
#         mkdir -p $out/nix-support
#         cp $setupHook $out/nix-support/setup-hook
#     fi
#
#     # Execute build command, if defined
#     if [ -n "$buildCommandPath" ]
#     then
#         source "$buildCommandPath"
#     elif [ -n "$buildCommand" ]
#     then
#         eval "$buildCommand"
#     fi
# }
