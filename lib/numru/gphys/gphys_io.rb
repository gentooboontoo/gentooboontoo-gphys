require "numru/gphys/gphys_netcdf_io"
require "numru/gphys/gphys_grads_io"
require "numru/gphys/gphys_grib_io"
require "numru/gphys/gphys_nusdas_io"
require "numru/gphys/gphys_gtool3_io"
begin
  require "numru/gphys/gphys_hdfeos5_io"
rescue LoadError
end
require "numru/gphys/mdstorage"   # for regexp2files
  

=begin
=module NumRu::GPhys::IO

A module to handle file IO regarding GPhys. 

Many of the functionality of this module is implemented in the modules
for specific file types such as NumRu::GPhys::NetCDF_IO, to which this
module directs operations.

For example, (('GPhys::IO.open(file, name)')) simply calls
(('GPhys::*_IO.open(file, name)')), where '(('*'))' is
(('NetCDF')), (('GrADS')), or (('grib')).

==Module functions

---open(file, varname)
    Opens a GPhys in (({file})) having the name (({varname})).

    ARGUMENTS
    * file (String, NetCDF, GRIB,.. etc, or Array, NArray, Regexp) :
      Specifies the file. Path if String; a File pointer if NetCDF etc..
      The processing is forwarded to (('open_multi')), if this argument is
      an Array, NArray, or Regexp. 
    * varname (String) : name of the variable

    RETURN VALUE
    * a GPhys

---open_multi(files, varname)
    Opens a GPhys by combining a variable across multiple files.
    It initializes GPhys objects over the files by calling (('open')) and
    unites them into a single GPhys object by using (({GPhys.join})) or
    (({GPhys.join_md})).

    ARGUMENTS
    * files (Array, NArray (NArray.object), or Regexp) : Specifies the files.
      * when Array, it must consist of paths or file pointers 
        (that are accepted by (('open'))).
        All coordinates of the variable in the files are scanned, 
        and a joined object is constructed properly.
        Thus, you can simply put subsets of a 2D tiling in a simple
        non-nested 1D Array. (({GPhys.join})) is used in this case.
      * when NArray, it must consist of paths or file pointers 
        (that are accepted by (('open'))).
        Each dimension with multiple elements must correspond
        to a dimension along which joining is made. 
        For example, a 2D tiling can be specified as
           files = NArray.to_na([['f00.nc','f10.nc'],['f01.nc','f11.nc']])
           gp = GPhys::IO.open_multi( files, "f" )
        (({GPhys.join_md})) is used in this case.
      * When Regexp, similar to when NArray, but expresses the paths.
        The dimensions to join is specified by "captures"
        (parentheses). For example, the above 2D tiling can be specified as
           files = /f(\d)(\d).nc/
           gp = GPhys::IO.open_multi( files, "f" )
        The regexp can contain a directory path (e.g., /dir\/sub\/f(\d)(d).nc/),
        but the directory part must be unique (i.e., a simple string),
        so only a single directly can be specified. All captures must
        be in the part representing the file names (in the directory).
        (({GPhys.join_md})) is used in this case.
    * varname (String) : name of the variable

    RETURN VALUE
    * a GPhys

---write(file, gphys, name=nil)
    Writes a GPhys object in a file

    ARGUMENTS
    * file (NetCDF, GRIB,.. etc) : the file. Writing must be permitted.
      To close (finalize) it after writing is left to the user.
    * gphys (GPhys) : the GPhys object to write
    * name (String; optional) : if specified, this name is used in the file
      rather than the name of gphys

---write_grid(file, grid_or_gphys)
---each_along_dims_write(gphyses, files, *loopdims){...}  # a block is expected
---var_names(file)
---var_names_except_coordinates(file)
    See the manual of (('NumRu::GPhys::NetCDF_IO')) for the methods listed above.

---file2type(file)
    Figures out the file type supported in this module.

    ARGUMENTS
    * file (String, NetCDF, Grib, or GrADS_Gridded) :
      What to return is of course obvious if it is 
      NetCDF, Grib, or GrADS_Gridded. If it is a String,
      it is assumed to be a path of a file, and the file type      
      is determined by its suffix when 'nc', 'ctl', or 'grib';
      In other cases, the type is figured out by reading in 
      a few bytes from the beginning.

    RETURN VALUE
    * GPhys::IO::NETCDF, GPhys::IO::GRIB, or GPhys::IO::GRADS, 
      which are string constants.
      
---file2specific_module(file)
    Same as ((<file2type>)), but returns GPhys::NetCDF_IO,
    GPhys::GrADS_IO, or GPhys::Grib_IO.

---file2file_class(file)
    Same as ((<file2type>)), but returns NetCDF,
    GrADS_Gridded, or Grib.

---parse_gturl(gturl)
    Parses GTOOL4-type URLs to specify path, variable name,
    and optionally subsets, whose format is 
    (('path[@|/]varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]'))

    ARGUMENTS
    * gturl (String) GTOOL4 URL, whose format is
      (('path[@|/]varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]'))

    RETURN VALUES
    * An Array consisting of [file, var, slice, cut_slice, thinning], where
      * file (String) : path
      * var (String) : variable name
      * slice (Array) : subset specifier by the grid numbers
        to be used as (('GPhys#[slice]')).
      * cut_slice (Array) : subset specifier in physical coordinate
        to be used as (('GPhys#cut[cut_slice]')).
      * thinning (Array) : additional subset specifier for thinning
        with uniform intervals if needed to be used (('GPhys#[thinning]'))
        after appling (('GPhys#cut')).

---open_gturl(gturl)
    a GPhys constructor from a Gtool4-type URL.
    See ((<parse_gturl>)) for its format.

    RETURN VALUE
    * a GPhys

---str2gphys(str)
    Open a GPhys from a slash("/")-separated String
    such as "U.nc/U" and "U.nc".
    * Aimed to help quick jobs with interactive sessions
      -- This method do not handle a GPhys across multiple files.
    * if the variable path is ommited such as "U.nc",
      try to find the variable in it -- read the file and if 
      only one variable is found, assume that is the 
      variable specified; otherwise, an exception is raised.
    * URL is accepted, but it's only thru NetCDF assuming OPeNDAP.

    ARGUMENTS
    * a String (file_path[/variable_path])
      e.g. "U.nc/U", "U.nc", "http://.../U.nc/U"

    RETURN VALUE
    * a GPhys

==Module constants

---GTURLfmt
    The format of Gtool4URL.

=end

module NumRu
  class GPhys
    module IO
      module_function

      ## switches for io libraries
      # switch grib library
      def use_gphys_grib
        VArrayGrib.use_gphys_grib
      end
      def use_rb_grib
        VArrayGrib.use_rb_grib
      end

      ## // module functions to be defined in specific IO modules -->
      def open(file, varname)
        case file
        when Array, NArray, Regexp
          open_multi(file, varname)
        else
          file2specific_module(file)::open(file, varname)
        end
      end

      def open_multi(files, varname)
        case files
        when Array
          GPhys.join( files.collect{|f| open(f,varname)} )
        when NArray
          GPhys.join_md( files.collect{|f| open(f,varname)} )
        when Regexp
          GPhys.join_md( regexp2files(files).collect{|f| open(f,varname)} )
        end
      end

      def regexp2files( pat )
        if  /^(.*)\\?\/(.*)$/ =~ (pat.source)
          d=$1
          f=$2
          dir = d.gsub(/\\/,'') + '/'
          pat = Regexp.new(f)
        else
          dir = './'
        end
        flstore = MDStorage.new(1)
        lbs = Array.new
        Dir.open(dir).each do |fn| 
          if pat =~ fn
            raise(ArgumentError,"has no capture; need one or more") if $1.nil?
            idx = Array.new
            Regexp.last_match.captures.each_with_index{|lb,i|
              flstore.add_dim if flstore.rank == i   # rank smaller by 1 -> add
              lbs[i] = Array.new if lbs[i].nil?
              idx.push( lbs[i].index(lb) || lbs[i].push(lb) && lbs[i].length-1 )
            }
            flstore[*idx] = NetCDF.open(dir+fn)
          end
        end
        flstore.to_na
      end

      def write(file, gphys, name=nil)
	file2specific_module(file)::write(file, gphys, name)
      end

      def write_grid(file, grid_or_gphys)
	# usually not needed (internally called by write)
	file2specific_module(file)::write_grid(file, grid_or_gphys)
      end

      def each_along_dims_write(gphyses, files, *loopdims, &block)

	files = [files] if !files.is_a?(Array)
	files.each do |fl|
	  if fl.is_a?(NetCDF)
	    NetCDF_Conventions.add_history(fl, "#{File.basename($0)}")
	  end
	end

	IO_Common::each_along_dims_write(gphyses, files, loopdims, 
					 file2specific_module(files), &block)
      end
      ## <-- module functions to be defined in specific IO modules //

      ## // file type selctor -->
      NETCDF = "NETCDF"
      GRADS = "GRADS"
      GRIB = "GRIB"
      NUSDAS = "NUSDAS"
      He5    = "He5"
      GTOOL3 = "GTOOL3"
      @@iomdl =     {NETCDF => GPhys::NetCDF_IO,
                     GRADS => GPhys::GrADS_IO,
                     GRIB => GPhys::Grib_IO,
                     NUSDAS => GPhys::NuSDaS_IO,
                     GTOOL3 => GPhys::Gtool3_IO}
      @@file_class = {NETCDF => NetCDF,
                     GRADS => GrADS_Gridded,
                     #GRIB => VArrayGrib.grib, # Hash is not dynamic: see below
                     NUSDAS => NuSDaS,
                     GTOOL3 => Gtool3}
      def @@file_class.[](key)
        if key == GRIB
          VArrayGrib.grib
        else
          super
        end
      end
      @@nc_pattern = [/\.nc$/]
      @@grad_pattern = [/\.ctl$/]
      @@grib_pattern = [/\.grib$/, /\.grb$/]
      @@nus_pattern = [/\.nus$/]

      @@has_he5 = defined?(HE5)
      if @@has_he5
        @@iomdl[He5] = GPhys::HE5_IO
        @@file_class [He5] = HE5
        @@he5_pattern = [/\.he5$/]
      end

      def file2type(file)
 	case file
	when Array, NArray
	  return file2type(file[0])   # inspect the first element (ignoring the rest)
	when NetCDF
	  return NETCDF
	when GrADS_Gridded
	  return GRADS
	when VArrayGrib.grib
	  return GRIB
        when NuSDaS
          return NUSDAS
        when Gtool3
          return GTOOL3
	when *@@nc_pattern
	  return NETCDF
	when *@@grad_pattern
	  return GRADS
	when *@@grib_pattern
          return GRIB
        when *@@nus_pattern
          return NUSDAS
	when String
	  return NETCDF if /^http:\/\// =~ file   # assume a DODS URL
          raise ArgumentError, "File not found: #{file}" unless File.exist?(file)
          return NETCDF if NetCDF_IO.is_a_NetCDF?(file)
          return GRADS if GrADS_IO.is_a_GrADS?(file)
          return GRIB if Grib_IO.is_a_Grib?(file)
          return NUSDAS if NuSDaS_IO.is_a_NuSDaS?(file)
          return GTOOL3 if Gtool3_IO.is_a_Gtool3?(file)
	end
        if @@has_he5
          case file
          when HE5, HE5Sw
            return He5
          when *@@he5_pattern
            return He5
          when String
            return He5   if HE5_IO.is_a_HE5?(file)
          end
        end
        return nil
      end

      def file2specific_module(file)
	@@iomdl[ file2type(file) ]
      end

      def file2file_class(file)
	@@file_class[ file2type(file) ]
      end

      types = ['nc','grad','grib','nus','he5']
      types.each{|c|
	eval <<-EOS
        def add_#{c}_pattern(*regexps)
          regexps.each{ |regexp|
            raise TypeError,"Regexp expected" unless Regexp===regexp
            @@#{c}_pattern.push(regexp)
          }
          nil
        end
	EOS
      }

      types.each{|c|
	eval <<-EOS
        def set_#{c}_pattern(*regexps)
          regexps.each{ |regexp|
            raise TypeError,"Regexp expected" unless Regexp===regexp
          }
          @@#{c}_pattern = regexps
          nil
        end
	EOS
      }
      ## <-- file type selctor //

      def var_names(file)
        file2specific_module(file).var_names(file)
      end
      def var_names_except_coordinates(file)
        file2specific_module(file).var_names_except_coordinates(file)
      end

      GTURLfmt = "path[@|/]varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]"

      def parse_gturl(gturl)
	if /(.*)@(.*)/ =~ gturl
	  file = $1
	  var = $2
        elsif /(.*)\/(.*)/ =~ gturl
          file = $1
          var = $2
	else
	  raise "invalid URL: '[@|/]' between path & variable is not found\n\n" + 
	         "URL format: " + GTURLfmt
	end
        if /[\*\?]/ =~ file
          file = Dir[file]
        end
	if /,/ =~ var
	  slice = Hash.new
	  cut_slice = Hash.new
	  thinning = Hash.new
	  var_descr = var.split(/,/)
	  var = var_descr.shift
	  var_descr.each do |s|
	    if /(.*)=(.*)/ =~ s
	      dimname = $1
	      subset = $2
	      case subset
	      when /\^(.*):(.*):(.*)/
		slice[dimname] = ($1.to_i)..($2.to_i)
		thinning[dimname] = {(0..-1) => $3.to_i}
	      when /\^(.*):(.*)/
		slice[dimname] = ($1.to_i)..($2.to_i)
	      when /\^(.*)/
		slice[dimname] = $1.to_i
	      when /(.*):(.*):(.*)/
		cut_slice[dimname] = ($1.to_f)..($2.to_f)
		thinning[dimname] = {(0..-1) => $3.to_i}
	      when /(.*):(.*)/
		cut_slice[dimname] = ($1.to_f)..($2.to_f)
	      else
		cut_slice[dimname] = subset.to_f
	      end
	    else
	      raise "invalid URL: variable subset specification error\n\n" + 
		"URL format: " + GTURLfmt
	    end
	  end
	  slice = nil if slice.length == 0
	  cut_slice = nil if cut_slice.length == 0
	  thinning = nil if thinning.length == 0
	else
	  slice = nil
	  cut_slice = nil
	  thinning = nil
	end
	[file, var, slice, cut_slice, thinning]
      end   # def parse_gturl

      def open_gturl(gturl)
	file, var, slice, cut_slice, thinning = GPhys::IO.parse_gturl(gturl)
	gp = GPhys::IO.open(file,var)
	gp = gp[slice] if slice
	gp = gp.cut(cut_slice) if cut_slice
	gp = gp[thinning] if thinning
	gp
      end   # def open_gturl

      def str2gphys(str)

        case str
        when /^https?:\/\//
          file_tester = Proc.new{|fname| NetCDF.open(fname) rescue false}
        when
          file_tester = Proc.new{|fname| File.exists?(fname)}
        end
        fname = str; vname = nil   # initial value
        while fname
          if file_tester.call(fname)
            break
          else
            if /(.*)\/([^\/]+)/ =~ fname
              fname = $1
              if vname.nil?
                vname = $2
              else
                vname = $2 + "/" + vname
              end
            else
              raise "Not found: #{str}"
            end
          end
        end
        if vname.nil?
          vns = var_names_except_coordinates(fname)
          if vns.length==1
            vname=vns.first 
          else
            raise "#{str} has multiple variables #{vns.inspect}. Specify one."
          end
        end
        open(fname,vname)
      end

    end      # module IO
  end      # class GPhys
end      # module NumRu

######################################################
if $0 == __FILE__
  include NumRu

  puts "\n** test str2gphys **\n"
  p GPhys::IO.str2gphys("../../../testdata/T.jan.nc/T")
  p GPhys::IO.str2gphys("../../../testdata/T.jan.nc")

  puts "\n** test NETCDF **\n"

  file = "../../../testdata/T.jan.nc"
  temp = GPhys::IO.open(file,"T")
  p temp.name, temp.shape_current
  p temp.val.class
  temp2 = temp[true,true,2]
  p temp2.name, temp2.shape_current
  
  temp_xmean = temp.average(0)
  p temp.val

  temp_edy = ( temp - temp_xmean )
  p '###',temp_edy.name,temp_edy.val[0,true,true]
  p 'deleted attributes:', temp.data.att_names - temp_edy.data.att_names
  p '@@@',temp
  p '///',temp.copy
  p '+++',temp2

  puts "\n** test write (tmp.nc) **"
  file2 = NetCDF.create('tmp.nc')
  p v = temp_edy.axis(0).pos[0..-2].copy.rename('lonlon')
  temp_edy.axis(0).set_aux('test',v)
  temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon2'))
  temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon3')[0..-2])
  GPhys::IO.write(file2,temp_edy)
  file2.close
  file3 = NetCDF.create('tmp2.nc')
  GPhys::IO.write(file3,temp_xmean)
  file3.close

  p '** test each_along_dims* **'

  f=NetCDF.create('tmpE1.nc')
  GPhys::IO.each_along_dims_write( temp, f, 1, 2 ){|sub|
    [sub.mean(0)]
  }
  f.close
  f=NetCDF.create('tmpE2.nc')
  GPhys::IO.each_along_dims_write([temp,temp_edy], f, "level"){|s1,s2|
    [s1.mean(0),s2.mean(1).rename('T_edy')]
  }
  f.close
  f=NetCDF.create('tmpE0.nc')
  GPhys::IO.write( f, temp.mean(0) )
  f.close

  print `ncdump tmpE0.nc > tmpE0; ncdump tmpE1.nc > tmpE1 ; diff -u tmpE[01]`

  puts "\n** test GRADS (and write into NETCDF) **\n"

  file = "../../../testdata/T.jan.ctl"
  temp = GPhys::IO.open(file,"T")
  p temp.name, temp.shape_current
  temp2 = temp[true,true,2,0]
  p temp2.name, temp2.shape_current

  temp_xmean = temp.average(0)
  p temp.val

  temp_edy = ( temp - temp_xmean )
  p '$$$',temp_edy.name,temp_edy.val[0,true,true,0]
  p '@@@',temp
  p '///',temp.copy
  p '+++',temp2

  puts "\n** test write (tmp.nc) **"
  require "numru/gphys/gphys_netcdf_io"
  file2 = NetCDF.create('tmp.nc')
  p v = temp_edy.axis(0).pos[0..-2].copy.rename('lonlon')
  temp_edy.axis(0).set_aux('test',v)
  temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon2'))
  temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon3')[0..-2])
  GPhys::IO.write(file2,temp_edy)
  file2.close
  file3 = NetCDF.create('tmp2.nc')
  GPhys::IO.write(file3,temp_xmean)
  file3.close

  puts "\n** test open_multi (1) **"
  # preparation...
  gp = GPhys::IO.open("../../../testdata/T.jan.nc","T")
  GPhys::IO.write(f=NetCDF.create('tmp_z0.nc'),gp[false,0..4]);   f.close
  GPhys::IO.write(f=NetCDF.create('tmp_z1.nc'),gp[false,5..-1]);  f.close

  # test...
  gpm = GPhys::IO.open(['tmp_z1.nc','tmp_z0.nc'],"T")
  gp.val == gpm.val ? puts("Test OK") : raise("Test failed")

  gpm = GPhys::IO.open(/tmp_z(\d).nc/,"T")
  gp.val == gpm.val ? puts("Test OK") : raise("Test failed")

  puts "\n** test open_multi (2) **"
  # preparation...
  gp = GPhys::IO.open("../../../testdata/T.jan.nc","T")
  GPhys::IO.write(f=NetCDF.create('tmp00.nc'), gp[0..20, 0..8, true]); f.close
  GPhys::IO.write(f=NetCDF.create('tmp10.nc'), gp[21..-1,0..8, true]); f.close
  GPhys::IO.write(f=NetCDF.create('tmp01.nc'), gp[0..20, 9..-1,true]); f.close
  GPhys::IO.write(f=NetCDF.create('tmp11.nc'), gp[21..-1,9..-1,true]); f.close

  # test...
  files = NArray.to_na([['tmp00.nc','tmp10.nc'],['tmp01.nc','tmp11.nc']])
  gpm = GPhys::IO.open(files,"T")
  gp.val == gpm.val ? puts("Test OK") : raise("Test failed")

  gpm = GPhys::IO.open(files.transpose(1,0),"T")  # fine even if tranposed
  gp.val == gpm.val ? puts("Test OK") : raise("Test failed")

  files = /tmp(\d)(\d).nc/
  gpm = GPhys::IO.open(files,"T")
  gp.val == gpm.val ? puts("Test OK") : raise("Test failed")

end
