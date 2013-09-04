=begin
=class NumRu::GDir

A class to represent diretories and data files for GPhys.

==Overview

A GDir object represents a directory, or a file (such as a NetCDF
file or GrADS control file), for which
GPhys objects can be defined for the variables in it.
This means that a NetCDF file, for example, is treated a
directory, rather than a plain file.

GDir serves a directory tree under a root (top) directory, which can
be set as a class variable with ((<GDir.top=>)). All the absolute path
of GDir is actually relative to the root directory, and to access
outside the root directory is prohibited.  Furthermore, it has a
working directory as a class variable, whose initial value is the top
directory and can be changed by ((<GDir.cd>)).

NEW(2005/06): Now GDir can accept DODS URL as a path. Also,
the top directory can be set to a DODS URL.

==Class Methods

---GDir.top=(top)
    Sets the root directory. This should be done before making
    any GDir objects by ((<GDir.new>)). The default root directory
    is the root directory of the local file system ('/').

    ARGUMENTS
    * ((|top|)) (String): path of the top directory

    RETURN VALUE
    * absolute path of the top directory (String) (followed by a '/')

---GDir.top

    RETURN VALUE
    * absolute path of the top directory (String) (followed by a '/')

---GDir.new(path)
    Constructor.

    ARGUMENTS
    * ((|path|)) (String): path of the directory to open as a GDir. 
      The path is expressed in terms of the top directory.

    RETURN VALUE
    * a GDir

    ERRORS
    * ArgumentError if ((|path|)) is out of the directory 
      tree (originated at the top directory).

    EXAMPLES
    * If the top directory is "/hoge", you can open
      "/hoge/ho" directory by any of the following.

         gdir = GDir.new("/ho")
         gdir = GDir.new("./ho")

      If you want to open "/hoge" (the top directly), then

         gdir = GDir.new("/")
         gdir = GDir.new(".")

      To open a NetCDF file or GrADS control file,

         gdir = GDir.new("/ho/data.nc")
         gdir = GDir.new("/ho/data.ctl")

---GDir.set_text_pattern(*regexps)

    Sets regular expressions to match the file name of text files.
    The default is /\.txt$/ and /^\w*$/.

    ARGUMENTS
    * zero or more Regular expressions (zero means no file will be treated
      as a NetCDF file).

    RETURN VALUE
    * nil

    ERRORS
    * TypeError if any of the arguments is not a Regexp

---GDir.add_text_pattern(regexp [, regexp [, ...]])
    Similar to ((<GDir.set_text_pattern>)), but adds regular expressions
    instead of replacing existing ones.

    RETURN VALUE
    * nil

    ERRORS
    * TypeError if any of the arguments is not a Regexp

---GDir.cd(path)

    Changes the working directory of the class.

    RETURN VALUE
    * a GDir

---GDir.cwd=(path)
    Aliased to ((<GDir.cd>)).

---GDir.cwd
    Returns the current working directory as a GDir. The initial value of 
    the working directory is the top directory.

    RETURN VALUE
    * a GDir

---GDir.cd(path)
    Changes the working directory to path

    RETURN VALUE
    * a GDir (current working directory changed by path)

---GDir[]
---GDir.data
---GDir.text
---GDir.list_dirs
---GDir.list_dirs_v
---GDir.list_data
---GDir.list_data_v
---GDir.list_texts
---GDir.list_texts_v
---GDir.ls
---GDir.ls_v

    All of these are dispatched to the current working directory.
    Thus, (('GDir.show')) is equivalent to (('GDir.cwd.show')), for example.

==Instance Methods

---close
    Closes the file/directory objects in the GDir.

---path
    Returns the path (relative to the top directory)

    RETURN VALUE
    * a String

---name
    Name of the GDir

    RETURN VALUE
    * a String

---inspect
    Returns the path

    RETURN VALUE
    * a String

---[](path)
    Returns a GDir, GPhys, or File (text), by calling
    ((<dir>)), ((<data>)), or ((<text>)) depending on (('path')).

    ARGUMENTS
    * ((|path|)) (String): Either relative or absolute.

    RETURN VALUE
    * a GDir, GPhys, or File (text assumed)

    ERROR
    * an exception is raised if ((|path|)) is not appropriate.


---dir(path)
    Returns a GDir specified the ((|path|)).

    ARGUMENTS
    * ((|path|)) (String): Either relative or absolute.

    RETURN VALUE
    * a GDir

    ERROR
    * an exception is raised if ((|path|)) is invalid as a GDir.

---data(path)
    Returns a GPhys specified the ((|path|)).

    ARGUMENTS
    * ((|path|)) (String): Either relative or absolute.

    RETURN VALUE
    * a GPhys

    ERROR
    * an exception is raised if ((|path|)) is invalid as a GPhys.

---text(path)
    Returns a text file object specified the ((|path|)).

    ARGUMENTS
    * ((|path|)) (String): Either relative or absolute.

    RETURN VALUE
    * a File

    ERROR
    * an exception is raised if ((|path|)) is invalid as a text file
      (based on the pattern: see above).

---find_dir( filt )
    Recursively search a GDir whose name match ((|filt|))..

    ARGUMENTS
    * ((|filt|)) (Regexp or String) If String, converted to Regexp
      with (('Regexp.new(filt)')).

    RETURN VALUE
    * an Array holding pathes (String) that matched.

---find_data( name=nil,long_name=nil,units=nil )
    Recursively search data variables under the directory.
    Mathces are by taking "AND" for non-nil arguments.
    (At least one of the three arguments must be non-nil.)

    ARGUMENTS
    * ((|name|)) (Regexp or String or nil) Variable name. If String, 
      converted to Regexp with (('Regexp.new(name)')).
    * ((|long_name|)) (Regexp or String or nil) long_name. If String, 
      converted to Regexp with (('Regexp.new(long_name)')).
    * ((|long_name|)) (Units or String or nil) long_name. If String, 
      converted to Units with (('Units.new(units)')).

    RETURN VALUE
    * an Array holding the path and variable name that matched 
      (two-element Array of String; [path, variable_name] ).

---list_dirs(path=nil)
    Returns the names of the directories.

    See also ((<ls>)).

    ARGUMENTS
    * ((|path|)) (nil or String): if nil, the method is applied to the
      current directory. If specified, listing is made for the directory
      designated by it. Either relative or absolute.

    RETURN VALUE
    * an Array of String

---list_dirs_v(path=nil)
    Verbose version of ((<list_dirs>)), showing size and mtime like 'ls -l'.

    See also ((<ls_l>)).

    ARGUMENTS
    * See ((<list_dirs>)).

    RETURN VALUE
    * an Array of String

      Example of a string:
          275492  Apr 12 19:15 hogehoge_data.nc/

---list_data(path=nil)
    Returns the names of the data (variables on which GPhys objects
    can be defined.) Returns a non-empty array if the GDir (current
    or at the path) is actually a file recognized by GPhys (i.e.,
    NetCDF or GrADS control file).

    ARGUMENTS
    * ((|path|)) (nil or String): if nil, the method is applied to the
      current directory. If specified, listing is made for the directory
      designated by it. Either relative or absolute.

    RETURN VALUE
    * an Array of String

---list_data_v(path=nil)
    Verbose version of ((<list_data>)), showing shape, long_name,
    and units.

    See also ((<ls_l>)).

    ARGUMENTS
    * See ((<list_data>)).

    RETURN VALUE
    * an Array of String

      Example of a string:
         u     [lon=120,lat=120,z=40,t=73]     'x components of velocity'      (m/s)

---list_texts(path=nil)
    Returns the names of the text files.
    Whether a file is a text file or not is judged based on the
    name of the file: That matched the predefined patters is
    judged as a text file regardless whether it is really so.
    The default pattern is /\.txt$/ and /^\w*$/. The patterns
    can be customized by ((<set_text_patterns>)) or 
    ((<add_text_patterns>)).

    ARGUMENTS
    * ((|path|)) (nil or String): if nil, the method is applied to the
      current directory. If specified, listing is made for the directory
      designated by it. Either relative or absolute.

    RETURN VALUE
    * an Array of String

---list_texts_v(path=nil)
    Verbose version of ((<list_texts>)), showing size and mtime like 'ls -l'.

    See also ((<ls_l>)).

    ARGUMENTS
    * See ((<list_texts>)).

    RETURN VALUE
    * an Array of String

---ls(path=nil)
    Prints the results of ((<list_dirs>)), ((<list_data>)), and 
    ((<list_texts>)) on the standard output.

    RETURN VALUE
    * nil

---each_dir
    Iterator for each directory (GDir) under  self.

---each_data
    Iterator for each GPhys under self.

---ls_l(path=nil)
    Verbose version of ((<ls>)).
    Prints the results of ((<list_dirs_v>)), ((<list_data_v>)), and 
    ((<list_texts_v>)) on the standard output.

    RETURN VALUE
    * nil

---mtime
    Returns the last modified time.

    RETURN VALUE
    * a Time

---atime
    Returns the last accessed time.

    RETURN VALUE
    * a Time
    
---ctime
    Returns ctime.

    RETURN VALUE
    * a Time

---mtime_like_ls_l

    Returns the last modified time formated as in ls -l.
    That is, if  the  time  of last modification is greater than 
    six months ago, it is shown in the format 'month date year';
    otherwise, 'month date time'.

    RETURN VALUE
    * a String.

=end

require "numru/gphys"
require "numru/htdir"

module NumRu

  class GDir

    @@top = '/'        # default
    @@top_pat =  Regexp.new('^'+@@top)

    @@text_pattern = [/\.txt$/,/^\w*$/]

    @@cwd = nil        # current working directory

    HtDir.dods_interpret = true

    def initialize(path)
      http = false
      if /^http/ =~ path
	http = true
	abspath = path.sub(/\/+$/,'')
	@path = @abspath = ( abspath + '/' )
      elsif /^http/ =~ @@top
	http = true
	abspath = @@top + path.sub(/\/+$/,'')
	abspath = File.expand_path( '/'+abspath ).sub(/^\//,'').sub(/^http:\//,'http://')  # to clean up the path
	@path = @abspath = ( abspath + '/' )
      else
	path = '/' + path if /^\// !~ path      # to always start with '/'
	path = File.expand_path( path )         # to clean up the path
	abspath = @@top.sub(/^(\/.*)\/$/,'\1')+path.sub(/\/+$/,'')
	@path = abspath.sub(@@top_pat,'') + '/'
	@abspath = abspath + '/'
      end
      ftype = __ftype(abspath)
      case ftype
      when "directory"
	if http
	  @dir = HtDir.new(abspath)
	else
	  @dir = Dir.new(abspath)
	end
	@file = nil
      when "file"
	if (file_class = GPhys::IO::file2file_class( abspath ))
	  # non-nil means GPhys knows it.
	  @dir = nil
	  @file = file_class.open( abspath )
	else
	  raise path+" are not dealt with GPhys. " +
	        "Use GPhys::IO::add_(nc|gr)_pattern if it should be."
	end
      else
	raise ArgumentError, abspath+": Unsupported file type "+ftype
      end
    end

    ####### CLASS METHODS ######

    class << self
      alias open new

      def top=(top)
	if /^http:\/\// =~ top
	  top = top.sub(/\/+$/,'')
	else
	  top = File.expand_path( top )   # to absolute path
	end
        ### top.untaint
        @@top_pat =  Regexp.new('^'+top)
	@@top = top + '/'
	@@cwd = GDir.new('/') if @@cwd    # reset to the top if set
	@@top
      end

      alias set_top top=

      def top
	@@top
      end

      ## // private >>
      def set_cwd
	@@cwd = GDir.new('/') if !@@cwd
      end
      private :set_cwd
      ## << private //

      def cwd
	set_cwd
	@@cwd
      end

      def pwd
	cwd.path
      end

      def cd(path)
	if /^\// =~ path
	  # absolute path
	  @@cwd = GDir.new( path )
	else
	  # relative path
	  set_cwd
	  @@cwd = GDir.new( @@cwd.path + path )
	end
      end

      alias chdir cd
      alias cwd= cd

      [ ## 'mtime','ctime','atime',
        ## 'size','mtime_like_ls_l',
       '[]','data','text',
       'list_dirs','list_dirs_v','list_data','list_data_v',
       'list_texts','list_texts_v','ls','ls_l'
      ].each do |method|
	eval <<-EOS
	  def #{method}(*args)
	    set_cwd
	    @@cwd.#{method}(*args)
	  end
	EOS
      end

      def add_text_pattern(*regexps)
	regexps.each{ |regexp|
	  raise TypeError,"Regexp expected" unless Regexp===regexp
	  @@text_pattern.push(regexp)
	}
	nil
      end

      def GDir.set_text_pattern(*regexps)
	regexps.each{ |regexp|
	  raise TypeError,"Regexp expected" unless Regexp===regexp
	}
	@@text_pattern = regexps
	nil
      end

    end

    ####### INSTANCE METHODS ######

    def close
      @dir.close if @dir
      @file.close if @file
    end

    def path
      @path
    end
    def name
      @path=='/' ? @path : File.basename( @path.sub(/\/$/,'') )
    end

    def inspect
      path
    end

    def [](path)
      begin
	begin
	  dir(path)
	rescue
	  begin
	    data(path)
	  rescue
	    text(path)
	  end
	end
      rescue
	pt = path || ''
	raise @path+pt+': no such data, directory or text (or is outside the tree)'
      end
    end

    def dir(path)
      case path
      when /^\//
	# absolute path
	GDir.new(path)
      else
	# relative path
	GDir.new(@path+path)
      end
    end

    alias cd dir

    def data(path)
      dirname = File.dirname(path)
      if dirname != '.'
	self.dir(dirname).data( File.basename(path) )
      else
	# path is for the current directory.
	if @dir
	  raise "data #{path} is not found"   # cannot be directly under a Dir
	else
	  GPhys::IO::open(@file,path)
	end
      end
    end

    def text(path)
      dirname = File.dirname(path)
      if dirname != '.'
	self.dir(dirname).text( File.basename(path) )
      else
	# path is for the current directory.
	if @dir
	  if __ftype(@abspath+path) == "file"
	    case path
	    when *@@text_pattern
	      File.open(@abspath+path)
	    else
	      raise "#{path} does not match patterns to find text files"
	    end
	  else
	    raise "text #{path} is not a plain file"
	  end
	else
	  raise "text #{path} is not found"
	end
      end
    end

    def open_all_data
      hash = Hash.new
      if @file
	GPhys::IO::var_names(@file).each do |nm|
	  hash[nm.to_sym] = data(nm)
	end
      end
      hash
    end

    def find_dir( filt )
      # filt is a Regexp or String
      filt = Regexp.new( filt ) if filt.is_a?(String)
      if ( filt =~ name )
	result = [ path ]
      else
	result = []
      end

      if @dir
	dnames = []
	@dir.rewind
	@dir.each{|fnm|
	  if fnm != '.' && fnm != '..' && __can_be_a_gdir(@abspath+fnm)
	    dnames.push( @path+fnm )
	  end
	}
	dnames.each do |nm|
	  dir = GDir.new(nm)
	  result.push(*dir.find_dir(filt))
	  dir.close
	end
      end

      result
    end

    def find_data(name=nil,long_name=nil,units=nil)
#      GC.start
      # name (Regexp (or String; partial match))
      # long_name (Regexp (or String; partial match))
      # units (Units or String)

      if !(name || long_name || units)
	raise ArgumentError,
	  "You must specify at least one of name, long_name, and units"
      end

      name = Regexp.new( name ) if name.is_a?(String)
      long_name = Regexp.new( long_name ) if long_name.is_a?(String)
      units = Units.new( units ) if units.is_a?(String)

      result = []

      if @file
	#p @file.path
	GPhys::IO::var_names(@file).each do |nm|
	  if !name || name =~ nm
	    # name inspection passed
	    gph = GPhys::IO::open(@file,nm) if long_name || units
	    if !long_name || long_name =~ gph.long_name
	      # long_name inspection passed
	      if !units || units == gph.units
		# units inspection passed
		result.push( [path, nm] )
	      end
	    end
	  end

	end
      end

      if @dir
	dnames = []
	@dir.rewind
	@dir.each{|fnm|
	  if fnm != '.' && fnm != '..' && __can_be_a_gdir(@abspath+fnm)
	    dnames.push( @path+fnm )
	  end
	}
	dnames.each do |nm| 
	  dir = GDir.new(nm)
	  result.push(*dir.find_data(name,long_name,units))
	  dir.close
	end
      end

      result
    end

    def list_dirs(path = nil)
      if path
	self.dir(path).list_dirs
      else
	if @dir
	  gdir_names = []
	  @dir.rewind
	  @dir.each{|fnm|
	    if fnm != '.' && fnm != '..' && __can_be_a_gdir(@abspath+fnm)
	      gdir_names.push( fnm )
	    end
	  }
	  gdir_names.sort
	else
	  []
	end
      end
    end

    def list_dirs_v(path = nil)
      # verbose version
      if path
	self.dir(path).list_dirs_v
      else
	if @dir
	  if /^http:\/\// =~ @abspath
	    return self.list_dirs
	  end
	  list = []
	  @dir.rewind
	  @dir.collect{|x| x}.sort.each{|fnm|
	    if fnm != '.' && fnm != '..' && __can_be_a_gdir(@abspath+fnm)
	      gdir = GDir.new(@path+fnm)
	      list.push( sprintf("%10d  %s %s/",gdir.size.to_s,
                                 gdir.mtime_like_ls_l, fnm) )
	      gdir.close
	    end
	  }
	  list
	else
	  []
	end
      end
    end

    def list_data(path = nil)
      if path
	self.dir(path).list_data
      else
	if @file
	  GPhys::IO::var_names(@file)
	else
	  []
	end
      end
    end

    def list_data_v(path = nil)
      # verbose version
      if path
	self.dir(path).list_data_v
      else
	if @file
	  GPhys::IO::var_names(@file).collect do |nm|
	    gph = GPhys::IO::open(@file,nm)
	    axinfo = '['
	    (0...gph.rank).collect do |i| 
	      axinfo += gph.axis(i).name + '=' + gph.shape[i].to_s + ','
	    end
	    axinfo.sub!(/,$/,']')
	    "#{nm}\t#{axinfo}\t'#{gph.long_name}'\t(#{gph.units.to_s})"
	  end
	else
	  []
	end
      end
    end

    def list_texts(path = nil)
      if path
	self.dir(path).list_texts
      else
	if @dir
	  text_files = []
	  @dir.rewind
	  @dir.each{|fnm|
	    if __ftype(@abspath+fnm) == "file"
	      case fnm
	      when *@@text_pattern
		text_files.push( fnm )
	      end
	    end
	  }
	  text_files.sort
	else
	  []
	end
      end
    end

    def list_texts_v(path = nil)
      # verbose version
      if path
	self.dir(path).list_texts_v
      else
	if @dir
	  if /^http:\/\// =~ @abspath
	    return self.list_texts
	  end
	  list = []
	  @dir.rewind
	  @dir.collect{|x| x}.sort.each{|fnm|
	    if __ftype(@abspath+fnm) == "file"
	      case fnm
	      when *@@text_pattern
		path = @abspath + fnm
		list.push( sprintf("%10d  %s  %s",File.size(path),
                                   __fmt_like_ls_l(File.mtime(path)), fnm) )
	      end
	    end
	  }
	  list
	else
	  []
	end
      end
    end

    def each_dir
      if @dir
	@dir.rewind
	@dir.each do |fnm|
	  if fnm != '.' && fnm != '..' && __can_be_a_gdir(@abspath+fnm)
	    yield( self.dir(fnm) )
	  end
	end
	self
      end
    end

    def each_data
      if @file
	GPhys::IO::var_names(@file).each do |vnm|
	  gphys = GPhys::IO::open(@file,vnm)
	  yield(gphys)
	end
      end
    end

    def list_all(path = nil)
      result = ''
      dirs = list_dirs(path)
      if dirs.length > 0
	result << "Directories:\n"
	dirs.each{|s| result << "  '#{s}/'\n"}
      end
      texts = list_texts(path)
      if texts.length > 0
	result << "Text files?:\n"
	texts.each{|s| result << "  '#{s}'\n"}
      end
      data = list_data(path)
      if data.length > 0
	result << "Data:\n"
	data.each{|s| result << "  '#{s}'\n"}
      end
      result
    end

    def ls(path = nil)
      print list_all(path)
    end

    def list_all_v(path = nil)
      result = ''
      dirs = list_dirs_v(path)
      if dirs.length > 0
	result << "Directories:\n"
	dirs.each{|s| result << "  #{s}\n"}
      end
      texts = list_texts_v(path)
      if texts.length > 0
	result << "Text files?:\n"
	texts.each{|s| result << "  #{s}\n"}
      end
      data = list_data_v(path)
      if data.length > 0
	result << "Data:\n"
	data.each{|s| result << "  #{s}\n"}
      end
      result
    end

    def ls_l(path = nil)
      print list_all_v(path)
    end

    def mtime
      File.mtime(@abspath.sub(/\/$/,''))
    end
    def ctime
      File.ctime(@abspath.sub(/\/$/,''))
    end
    def atime
      File.ctime(@abspath.sub(/\/$/,''))
    end
    def size
      File.size(@abspath.sub(/\/$/,''))
    end

    def mtime_like_ls_l
      # format mtime like ls -l
      __fmt_like_ls_l( self.mtime )
    end

    def __fmt_like_ls_l(time)
      if ( (Time.now - time) < 15811200  ) # == 86400*183: a half year
        time.strftime('%b %d %H:%M')
      else
        time.strftime('%b %d  %Y')
      end
    end
    private :__fmt_like_ls_l

    #################################
    private

    def __ftype(path, _depth=0)
      # Same as File.ftype, but traces symbolic links

      if /^http/ =~ path
	if /\.(nc|ctl|ctrl|grib|cdf|hdf|dat|bin|gz|jg)$/i =~ path
	  ftype = 'file'
	else
	  ftype = 'directory'
	end
      else
	ftype = File.ftype(path)
	if ftype == "link"
	  if _depth < 10   # == max_depth
	    begin
	      lkpath = File.readlink(path)
	      unless /^\// === lkpath
		lkpath = File.dirname(path)+'/'+lkpath
	      end
	      ftype = __ftype( lkpath, _depth+1 )
	    rescue
	      nil    # possibly a link to non-existent file
	    end
	  else
	    nil    # Max depth exeeded: Link too long (possibly circular)
	  end
	end
      end
      ftype
    end

    def __can_be_a_gdir(path)
      ftype = __ftype(path)
      if ftype=="directory" || ftype=="file" && GPhys::IO::file2type(path)
	true
      else
	false
      end
    end

  end      # class GDir
end      # module NumRu


###############################################
# test program usage
# % ruby gdir.rb [topdir]
# EXAMPLE
# % ruby gdir.rb
# % ruby gdir.rb  ..

if __FILE__ == $0

  include NumRu

  def find_gphys(gdir)
    gphyses = []
    subdirs = gdir.list_dirs.collect{ |dnm| gdir[dnm] }
    subdirs.each{ |subdir|
      ary = find_gphys(subdir)
      gphyses +=  ary  if ary.length != 0
    }
    gdir.list_data.each{|var|
      gp = gdir.data(var)
      gphyses.push( gp ) 
    }
    gphyses
  end

  def find_txt(gdir)
    texts = []
    subdirs = gdir.list_dirs.collect{ |dnm| gdir[dnm] }
    subdirs.each{ |subdir|
      ary = find_txt(subdir)
      texts +=  ary  if ary.length != 0
    }
    gdir.list_texts.each{|var|
      gp = gdir.text(var)
      texts.push( gp ) 
    }
    texts
  end

  top = ARGV.shift || '.'
  GDir.top = top

  gdir = GDir.new('/')
  #gdir = GDir.new('.')   # same as above

  print "*(test)* Set the top directory to #{top}\n"

  p gdir.mtime
  p gdir.list_dirs
  gdir.list_dirs_v.each{|s| print s+"\n"}
  p gdir.list_texts
  gdir.list_texts_v.each{|s| print s+"\n"}
  p gdir.list_data
  gdir.list_data_v.each{|s| print s+"\n"}
  print gdir.path, ' ', gdir.name, "\n"
#  print gdir[gdir.list_dirs[0]].path, ' ', gdir[gdir.list_dirs[0]].name, "\n"
#  p gdir[gdir.list_dirs[0]]['.']['..']['..']

  print "*(test)* Searching all NetCDF&GrADS files under the top dir...\n"
  gphyses = find_gphys(gdir)
  gphyses.each{ |gp|
    print gp.name, gp.shape_current.inspect, '  ', gp.data.file.path,"\n"
  }

  print "*(test)* Searching all text files under the top dir...\n"
  find_txt(gdir).each{|txt| print txt.path,"\n"}

  print "\n***(test)*** DODS access \n"
  gdir = GDir.new('http://davis-dods.rish.kyoto-u.ac.jp/cgi-bin/nph-dods/jmadata/gpv/latest/gpv')
  p gdir.ls
  gd2 = gdir.dir('latest/')
  p gd2.ls_l
  gd3 = gd2.dir('MSM00S.nc/')
  p gd3.ls_l
  GDir.top = 'http://davis-dods.rish.kyoto-u.ac.jp/cgi-bin/nph-dods/jmadata/gpv/latest/gpv'
  gdir = GDir.new('.')
  g2 = GDir.new('latest')
  p gdir.ls,g2.ls
end
