require "numru/netcdf"
require "numru/netcdf_miss"
require "numru/gphys/varray"   # for constants of VArray

=begin

==INDEX
* ((<module NumRu::NetCDF_Conventions>))
* ((<module NumRu::NetCDF_Convention_Users_Guide>))
  * ((<module NumRu::NetCDF_Convention_Users_Guide::Attribute_Mixin>))
  * ((<module NumRu::NetCDF_Convention_Users_Guide::VArray_Mixin>))
* ((<module NumRu::NetCDF_Convention_Wind_Profiler>))

=module NumRu::NetCDF_Conventions

NetCDF_Conventions is the general handler of NetCDF conventions for the 
GPhys library.

==Module Functions

---find( netcdf )

    Figures out what NetCDF convention a netcdf file is following.

    ARGUMENTS
    * ((|netcdf|)) (NetCDF): the file

    RETURN VALUE
    * a Module (NumRu::NetCDF_Convention_Users_Guide etc.)

    REMARK
    * The convention is figured out from the 'Conventions' global attribute.
      You can instead fix the convention by using ((<fix_to>)).

---fix_to( convention )

    Fix the convention to be returned by ((<find>)) regardless the value
    of the 'Conventions' attribute.

    ARGUMENTS
    * ((|convention|)) (Module): NumRu::NetCDF_Convention_Users_Guide etc.

    RETURN VALUE
    * convention

---add_history(netcdf, str=nil)

    Adds a line to the 'history' global convention of ((|netcdf|)).
    The line consists of date, time, user name, and ((|str|)) 
    if present (e.g., '2004-03-02 17:52:25 JST horinout> '+str).

    ARGUMENTS
    * ((|netcdf|)) (NetCDF): the file in which the history is updated
    * ((|str|)) (nil or String): if present, added to the end of the line.

=module NumRu::NetCDF_Convention_Users_Guide

The NetCDF Users Guide Convention 
(http://www.unidata.ucar.edu/packages/netcdf/docs.html).

==Constants

---Attribute_Mixin

See below: ((<module NumRu::NetCDF_Convention_Users_Guide::Attribute_Mixin>)).

---VArray_Mixin

See below: ((<module NumRu::NetCDF_Convention_Users_Guide::VArray_Mixin>)).


==Module Functions

---to_s
    Returns a string to be used as representing the convention.
    The Users Guide Convention does not have one, so a string 
    was tentatively assigned by Horinouchi.

---coord_var_names(ncvar)
    Returns the names of coordinate variables for all the dimensions
    of ((|ncvar|)).

    ARGUMENTS
    * ((|ncvar|)) (NetCDFVar)

    RETURN VALUE
    * Array of strings, whose length is the rank of ((|ncvar|)).

---cell_bounds?(coord_var)
    Document to be written. (returns false&nil in this convention.)
    Might be reorganized in future when the gtool4 convention is supported.

---cell_center?(coord_var)
    Document to be written. (returns false&nil in this convention.)
    Might be reorganized in future when the gtool4 convention is supported.

--------------------------------------------------
==module NumRu::NetCDF_Convention_Users_Guide::Attribute_Mixin

The module to be mixed in NumRu::AttributeNetCDF.

===Instance Methods 

Methods below will become sigular methods of NumRu::AttributeNetCDF.

---copy(to=nil)
    Same as (('super')) (the one overridden by this method), 
    but edits some standard attributes if (('to')) is nil (copy onto memory)):
    * scale_factor, add_offset: removed, since data copying includes 
      "unpaking" by interpreting them
    * valid_*, missing_value: unpacked if packed.
    * _FillValue, FORTRAN_format, C_format: eliminated

---------------------------------------------------
==module NumRu::NetCDF_Convention_Users_Guide::VArray_Mixin

The module to be mixed in NumRu::VArrayNetCDF.

===Instance Methods

Currently none, meaning is that no modification is made 
in VArrayNetCDF.

---------------------------------------------------------------------
=module NumRu::NetCDF_Convention_Wind_Profiler

The Wind Profiler convention 
(http://www.kurasc.kyoto-u.ac.jp/radar-group/wind_profiler_conventions/).

Inherits NetCDF_Convention_Users_Guide and makes appropriate redefinitions.
See ((<module NumRu::NetCDF_Convention_Users_Guide>)) for the description 
of constants and module functions.

=end

module NumRu

  ## /// COMMON -->

  class NetCDFVar
    alias get get_with_miss_and_scaling
    alias put put_with_miss_and_scaling
  end

  # Other implicit convention
  #
  #  * to use the "units" attribute to indicate the physical units
  #    (which is assumed in VArray, the super class of VArrayNetCDF).

  module NetCDF_Conventions
    module_function

    @@fixed = nil
    def fix_to( convention )
      @@fixed == convention
    end

    def find( netcdf )
      # netcdf is assumed to be a NetCDF
      if @@fixed
	@@fixed
      else
	convention = (att=netcdf.att('Conventions')) && att.get
	case convention
	#when /gtool/
	#  raise "Sorry, the gtool convention is yet to be supported"
	when /^Wind Profiler/
	  NetCDF_Convention_Wind_Profiler
	else
	  #NetCDF_Convention_Users_Guide
          NetCDF_Convention_CF
	end
      end
    end

    def add_history(netcdf, str=nil)
      hstatt = netcdf.att('history')
      if hstatt
	history = hstatt.get.chomp + "\n"
      else
	history = ''
      end
      time = Time.now
      history += ( time.respond_to?(:strftime) ? 
                   time.strftime('%Y-%m-%d %H:%M:%S %Z ') : time.to_s ) +
                 ( ENV['USER'] || '' ) + '>'
      history += (' '+str) if str
      netcdf.put_att('history', history)
    end

  end

  ## <-- COMMON ///

  ######################################################
  ## Indivisual Conventions --- Can be figured out by
  ##  NetCDF_Conventions.find( netcdf )
  ######################################################


  module NetCDF_Convention_Users_Guide
    # NetCDF Convention of the NetCDF User's Guide
    # To be used by (not to be included in) NetCDF_IO.

    module Attribute_Mixin

      def _unpack_missing_specification(attr)
	# -- private method --
	# unpack missing data specification 
        # if the missing data type is in the external data type)

	ao = attr['add_offset']     # must be narray or nil
	sf = attr['scale_factor']   # must be narray or nil
        if ao || sf
	  raise "add_offset is not a numeric" if ao.is_a?(String)
	  raise "scale_factor is not a numeric" if sf.is_a?(String)
	  satyp = ( ao || sf ).typecode
	  extyp = @nv.typecode
	  sf = 1 if !sf
	  ao = 0 if !ao
	  if (x=attr['valid_range']) && (x.typecode==extyp ||x.typecode!=satyp)
	      attr['valid_range'] = x * sf + ao
	  end
	  if (x=attr['valid_min']) && (x.typecode==extyp || x.typecode!=satyp)
	      attr['valid_min'] = x * sf + ao
	  end
	  if (x=attr['valid_max']) && (x.typecode==extyp || x.typecode!=satyp)
	      attr['valid_max'] = x * sf + ao
	  end
	  if (x=attr['missing_value']) && (x.typecode==extyp || x.typecode!=satyp)
	      attr['missing_value'] = x * sf + ao
	  end
	  attr
	end
      end
      private :_unpack_missing_specification

      def _op_attr_edit( attr )
	# -- private method --

	attr.delete('C_format')
	attr.delete('FORTRAN_format')

	_unpack_missing_specification(attr)
	attr.delete('add_offset')
	attr.delete('scale_factor')
	attr.delete('_FillValue')
	##attr.delete('long_name')

	attr
      end
      private :_op_attr_edit

      def copy(to=nil)
	newattr = super
	newattr = _op_attr_edit(newattr) if !to
	newattr
      end

    end  # module Attribute_Mixin

    module VArray_Mixin
      # currently none
    end  # module VArray_Mixin

    ####################
    module_function

    def to_s
      "NetCDF User's Guide"
    end

    def coord_var_names(ncvar)
      # name of the coordinate variables (to be the "pos" object in Axis)
      ncvar.dim_names
    end

    def cell_bounds?(coord_var)
      # whether the coordinate variale represent grid cell bounds.
      # coordvar (VArray)
      # return value:
      result = false  # Always false, because User's guide does not define it
      cell_center_name = nil
      [result, cell_center_name]
    end

    def cell_center?(coord_var)
      # whether the coordinate variale represent grid cell centers.
      # coordvar (VArray)
      # return value:
      #    false if not
      #    true if true and the corresponding cell bounds are not identified.
      #    a VArray if true and the bounds are found (returns it)
      result = false  # Always false, because User's guide does not define it
      cell_bounds_name = nil
      [result, cell_bounds_name]
    end

    def aux_var_names(coord_var)
      nil   # no rule for that
    end

    def assoc_coord_names(data)
      nil   # no rule for that
    end

  end

  module NetCDF_Convention_CF
    # http://cf-pcmdi.llnl.gov/

    # < inherit the Users guide convention >

    module Attribute_Mixin
      include NetCDF_Convention_Users_Guide::Attribute_Mixin
    end    # module Attribute_Mixin
    module VArray_Mixin
      include NetCDF_Convention_Users_Guide::VArray_Mixin
    end    # module VArray_Mixin
    module_function
    extend NetCDF_Convention_Users_Guide
    public_class_method :aux_var_names, :coord_var_names, :cell_bounds?, :cell_center?

    ########### original part starts here #################

    def assoc_coord_names(data)
      if s = data.get_att("coordinates")
        nms = s.split(/ +/)
        case data.file
        when NArray
          fl = data.file[0]
        else
          fl = data.file
        end
        nms.delete_if{|nm| !fl.var(nm)}
        nms.delete_if{|nm| fl.dim_names.include?(nm)}
        nms
      else
        nil
      end
    end

  end


  module NetCDF_Convention_Wind_Profiler
    # Wind Profiler Convention
    # http://www.kurasc.kyoto-u.ac.jp/radar-group/wind_profiler_conventions/

    module Attribute_Mixin
      include NetCDF_Convention_Users_Guide::Attribute_Mixin
    end    # module Attribute_Mixin

    module VArray_Mixin
      include NetCDF_Convention_Users_Guide::VArray_Mixin
    end    # module VArray_Mixin

    ########################
    module_function
    extend NetCDF_Convention_Users_Guide
    public_class_method :cell_bounds?, :cell_center?, :assoc_coord_names
    
    def to_s
      "Wind Profiler (http://www.kurasc.kyoto-u.ac.jp/radar-group/wind_profiler_conventions/)"
    end

    def coord_var_names(ncvar)
      if (c=ncvar.att('coordinates'))
	coordinates = c.get.split(/ +/)
      elsif (ct=ncvar.att('t_coordinates')) || (cz=ncvar.att('z_coordinates'))
	coordinates = Array.new
	coordinates.push(ct.get) if ct
	coordinates.push(cz.get) if cz
      else
	coordinates = nil
      end
      dimnames = ncvar.dim_names 
      if coordinates
	cdvnames = []
	coordinates.each{ |varname|
	  var = ncvar.file.var(varname)
	  raise "#{var.inspect} is not 1D" unless var.rank==1
          dimnm = var.dim(0).name
	  idx = dimnames.index(dimnm)
	  if idx
	    cdvnames[idx] = varname
	  else
	    raise "#{varname} cannot be a coordinate variable -- "+
              "#{ncvar.file.path} not comply with the Wind Profiler convention"
	  end
	}
	for i in 0...dimnames.length
	  cdvnames[i] = dimnames[i] if !cdvnames[i]  #if not found, use dimname
	end
	cdvnames
      else
	# follow the users guide convention
	dimnames
      end
    end

    def aux_var_names(coord_var)
      Hash['coordinate', coord_var.dim_names[0] ]
    end

  end

end   # module NumRu
