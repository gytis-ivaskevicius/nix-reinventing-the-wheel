require 'fileutils'
require 'open3'
require 'etc' # nprocessors
require 'find'

def error(message)
  abort('### Error: ' + message.to_s)
end

def info(message)
  puts('### Info: ' + message.to_s, '')
end

def debug(message)
  puts('### Debug: ' + message.to_s, '') if ENV['debug'] == 'true'
end

def `(it)
  info "Executing '#{it}'"
  Open3.popen3(it) do |stdin, stdout, stderr, wait_thr|
    puts 'stdout is:' + stdout.read
    puts 'stderr is:' + stderr.read
    if !wait_thr.value.success?
      error 'Command '#{it}' exited with non zero status'
    end
  end
  #if !system(it)
  #  error 'Command '#{it}' exited with non zero status'
  #end
end

def expand_path(str)
  Dir[str.gsub(/\$([a-zA-Z_][a-zA-Z0-9_]*)|\${\g<1>}/) { ENV[$1] }]
end

# TODO: wrap the rest of utils https://ruby-doc.org/stdlib-2.4.1/libdoc/fileutils/rdoc/FileUtils.html and get them to auto expand arguments


def mkdir_p(list, mode: nil, noop: nil)
  FileUtils.mkdir_p list, mode: mode, noop: noop, verbose: true
end

def ln_s(src, dest, force: nil, noop: nil)
  FileUtils.ln_s src, dest, force: force, noop: noop, verbose: true
end

def cp(src, dest, force: nil, noop: nil)
  FileUtils.cp src, dest, force: force, noop: noop, verbose: true
end

def touch(list, noop: nil, mtime: nil, nocreate: nil)
  FileUtils.touch list, noop: noop, verbose: true, mtime: mtime, nocreate: nocreate
end

def source(path)
  info 'source '#{path}''
  eval File.new(path).read
end

def source_all
  ENV['source'].split('\s+').each { |it| source it }
end

def get_build_cores()
  ENV['NIX_BUILD_CORES'] == '0' ? Etc.nprocessors.to_s : ENV['NIX_BUILD_CORES']
end
