require "mkmf"
$extout_prefix = '/numru'
alias __install_dirs install_dirs
def install_dirs
  dirs = __install_dirs
  dirs.assoc("RUBYARCHDIR")[1].sub!(/target_prefix/,'extout_prefix')
  dirs
end

#dir_config('narray',$sitearchdir,$sitearchdir)
gem_home=(`gem environment GEM_HOME`).chomp
narray_dir = Dir.glob("#{gem_home}/gems/narray-*").sort[-1]
narray_include = narray_dir
narray_lib = narray_dir
dir_config('narray',narray_include,narray_lib)

if ( ! ( have_header("narray.h") && have_header("narray_config.h") ) ) then
print <<EOS
** configure error **
   Header narray.h or narray_config.h is not found. If you have these files in
   /narraydir/include, try the following:

   % ruby extconf.rb --with-narray-include=/narraydir/include

EOS
   exit(-1)
end

if /cygwin|mingw/ =~ RUBY_PLATFORM
  unless have_library("narray")
   print <<-EOS
   ** configure error **
   libnarray.a is not found.
   % ruby extconf.rb --with-narray-lib=/narraydir/lib

   EOS
   exit(-1)
  end
end

create_makefile("gphys_ext")
