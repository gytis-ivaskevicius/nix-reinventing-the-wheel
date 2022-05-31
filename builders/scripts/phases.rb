require 'etc' # nprocessors
require 'find'

def patchelf_phase
  path = ENV['out']
  Find.find(path) do |it|
    debug "patchelf - processing file #{it}"
    file = File.stat(it)
    `patchelf --shrink-rpath '#{it}' || true` if !file.directory? && file.executable?
  end
end

# https://gist.github.com/sinisterchipmunk/133504kk1/5be4e6039d899c9b8cca41869dc6861c8eb71f13

def unpack_phase
  src = $drvOpts['src']
  file = File.stat(src)
  if !file.directory?
    `tar -xf '#{src}' -C .`
  else
    cp(src, '.')
  end

  # Files that don't start with '.' in current directory
  entries = Dir.entries('.').filter { |it| it.index(".") != 0 }
  Dir.chdir entries[0] if entries.size == 1
end

def configure_phase
  outputs = ENV['outputs']
  args = Array.new($drvOpts['configureFlags'])
  args.push('--bindir=$bin/bin') if outputs.include? 'bin'
  args.push('--libdir=$lib/lib') if outputs.include? 'lib'
  args.push('--mandir=$man/man') if outputs.include? 'man'
  args.push('--infodir=$man/share/info') if outputs.include? 'info'
  args.push('--includedir=$dev/include --oldincludedir=$dev/include') if outputs.include? 'dev'
  `./configure #{args.join(' ')}`
end

def build_phase
  args = Array.new($drvOpts['buildFlags'] + $drvOpts['makeFlags'])
  args.push("-f #{$drvOpts['makefilePath']}") if $drvOpts.key? :makefilePath

  `make SHELL=$SHELL -j#{$build_cores} -l#{$build_cores} #{args.join(' ')}`
end

def check_phase
  args = Array.new($drvOpts['checkFlags'] + $drvOpts['makeFlags'])
  args.push("-f #{$drvOpts['makefilePath']}") if $drvOpts.key? :makefilePath

  `make SHELL=$SHELL #{args.join(' ')} check`
end

def install_phase
  args = Array.new($drvOpts['installFlags'] + $drvOpts['makeFlags'])
  args.push("-f #{$drvOpts['makefilePath']}") if $drvOpts.key? :makefilePath

  `make SHELL=$SHELL prefix=$out #{args.join(' ')} install`
end
