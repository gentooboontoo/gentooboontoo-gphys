require 'rbconfig'
require 'find'
include Config
if CONFIG["MINOR"].to_i > 6 then $rb_18 = true else $rb_18 = false end
if $rb_18
  require 'fileutils'
else
  require 'ftools'
end

=begin
$version = CONFIG["MAJOR"]+"."+CONFIG["MINOR"]
$libdir = File.join(CONFIG["libdir"], "ruby", $version)
# $archdir = File.join($libdir, CONFIG["arch"])
$site_libdir = $:.find {|x| x =~ /site_ruby$/}
if !$site_libdir
  $site_libdir = File.join($libdir, "site_ruby")
elsif Regexp.compile($site_libdir) !~ Regexp.quote($version)
  $site_libdir = File.join($site_libdir, $version)
end

default_destdir = $site_libdir
=end
default_destdir = CONFIG["sitelibdir"]

default_bindir = CONFIG["bindir"]

def install_rb(srcdir, destdir)
  libdir = "lib"
  libdir = File.join(srcdir, libdir) if srcdir
  path = []
  dir = []
  Find.find(libdir) do |f|
    next unless FileTest.file?(f)
    next if (f = f[libdir.length+1..-1]) == nil
    next if (/CVS$/ =~ File.dirname(f))
    path.push f
    dir |= [File.dirname(f)]
  end
  for f in dir
    next if f == "."
    next if f == "CVS"
    if $rb_18
      FileUtils.makedirs(File.join(destdir, f))
    else
      File::makedirs(File.join(destdir, f))
    end
  end
  for f in path
    next if (/\~$/ =~ f)
    next if (/^\./ =~ File.basename(f))
    if $rb_18
      FileUtils.install(File.join(libdir, f), File.join(destdir, f), {:mode => 0644, :verbose => true})
    else
      File::install(File.join(libdir, f), File.join(destdir, f), 0644, true)
    end
  end
end

def install_bin(srcdir, destbindir)
  localbindir = "bin"
  localbindir = File.join(srcdir, localbindir) if srcdir
  path = []
  dir = []
  Find.find(localbindir) do |f|
    next unless FileTest.file?(f)
    next if (f = f[localbindir.length+1..-1]) == nil
    next if (/CVS$/ =~ File.dirname(f))
    path.push f
    #dir |= [File.dirname(f)]
  end
  #for f in dir
  #  next if f == "."
  #  next if f == "CVS"
  #  File::makedirs(File.join(destbindir, f))
  #end
  for f in path
    next if (/\~$/ =~ f)
    next if (/^\./ =~ File.basename(f))
    if $rb_18
      FileUtils.install(File.join(localbindir, f), File.join(destbindir, f), {:mode => 0755, :verbose => true})
    else
      File::install(File.join(localbindir, f), File.join(destbindir, f), 0755, true)
    end
  end
end

def ARGV.switch
  return nil if self.empty?
  arg = self.shift
  return nil if arg == '--'
  if arg =~ /^-(.)(.*)/
    return arg if $1 == '-'
    raise 'unknown switch "-"' if $2.index('-')
    self.unshift "-#{$2}" if $2.size > 0
    "-#{$1}"
  else
    self.unshift arg
    nil
  end
end

def ARGV.req_arg
  self.shift || raise('missing argument')
end

destdir = default_destdir
bindir = default_bindir

begin
  while switch = ARGV.switch
    case switch
    when '-d', '--destdir'
      destdir = ARGV.req_arg
    when '-b', '--bindir'
      bindir = ARGV.req_arg
    else
      raise "unknown switch #{switch.dump}"
    end
  end
rescue
  STDERR.puts $!.to_s
  STDERR.puts File.basename($0) + 
    " -d <destdir> -b <bindir>"
  exit 1
end    

install_rb(nil, destdir)
install_bin(nil, bindir)

