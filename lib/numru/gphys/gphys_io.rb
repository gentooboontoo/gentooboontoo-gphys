require "numru/gphys/gphys_netcdf_io"
require "numru/gphys/gphys_grads_io"
require "numru/gphys/gphys_grib_io"
require "numru/gphys/gphys_nusdas_io"

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

---open(files, varname)
---write(file, gphys, name=nil)
---write_grid(file, grid_or_gphys)
---each_along_dims_write(gphyses, files, *loopdims){...}  # a block is expected
---var_names(file)
---var_names_except_coordinates(file)
    See the manual of (('NumRu::GPhys::NetCDF_IO')) for the methods listed above.

---file2type(file)
    Figures out the file type supported in this module.

    ARGUMENTS
    * file (String, Regexp, NetCDF, Grib, or GrADS_Gridded) :
      What to return is of course obvious if it is 
      NetCDF, Grib, or GrADS_Gridded. If it is a String,
      it is assumed to be a path of a file, and the file type      
      is determined by its suffix when 'nc', 'ctl', or 'grib';
      In other cases, the type is figured out by reading in 
      a few bytes from the beginning. If Regexp, currently,
      a NetCDF is assumed, since only NetCDF_IO.open supports
      Regexp.

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
    (('path@varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]'))

    ARGUMENTS
    * gturl (String) GTOOL4 URL, whose format is
      (('path@varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]'))

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

==Module constants

---GTURLfmt
    The format of Gtool4URL.

=end

module NumRu
  class GPhys
    module IO
      module_function

      ## // module functions to be defined in specific IO modules -->
      def open(file, varname)
	file2specific_module(file)::open(file, varname)
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
      @@iomdl =     {NETCDF => GPhys::NetCDF_IO,
                     GRADS => GPhys::GrADS_IO,
                     GRIB => GPhys::Grib_IO,
                     NUSDAS => GPhys::NuSDaS_IO}
      @@file_class = {NETCDF => NetCDF,
                     GRADS => GrADS_Gridded,
                     GRIB => Grib,
                     NUSDAS => NuSDaS}
      @@nc_pattern = [/\.nc$/]
      @@grad_pattern = [/\.ctl$/]
      @@grib_pattern = [/\.grib$/, /\.grb$/]
      @@nus_pattern = [/\.nus$/]

      def file2type(file)
 	case file
	when Array, NArray
	  return file2type(file[0])   # inspect the first element (ignoring the rest)
	when NetCDF
	  return NETCDF
	when GrADS_Gridded
	  return GRADS
	when Grib
	  return GRIB
        when NuSDaS
          return NUSDAS
	when Regexp
	  return NETCDF     # So far, only NetCDF_IO supports Regexp. 
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
          return nil unless File.exist?(file)
          return NETCDF if NetCDF_IO.is_a_NetCDF?(file)
          return GRADS if GrADS_IO.is_a_GrADS?(file)
          return GRIB if Grib_IO.is_a_Grib?(file)
          return NUSDAS if NuSDaS_IO.is_a_NuSDaS?(file)
	end
        return nil
      end

      def file2specific_module(file)
	@@iomdl[ file2type(file) ]
      end

      def file2file_class(file)
	@@file_class[ file2type(file) ]
      end

      types = ['nc','grad','grib','nus']
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

      GTURLfmt = "path@varname[,dimname=pos1[:pos2[:thinning_intv]][,dimname=...]]"

      def parse_gturl(gturl)
	if /(.*)@(.*)/ =~ gturl
	  file = $1
	  var = $2
	else
	  raise "invalid URL: '@' between path & variable is not found\n\n" + 
	         "URL format: " + GTURLfmt
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

    end      # module IO
  end      # class GPhys
end      # module NumRu

######################################################
if $0 == __FILE__
  include NumRu

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
  GPhys::IO.write(file2,temp_xmean)
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
  GPhys::IO.write(file2,temp_xmean)
  file3.close

end
