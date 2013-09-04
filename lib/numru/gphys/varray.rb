require "numru/gphys/subsetmapping"
require "numru/gphys/attribute"
require "narray_miss"
require "numru/units"
require "numru/gphys/unumeric"
require "rational"    # for VArray#sqrt
require "numru/misc"

module NumRu

=begin
=class NumRu::VArray

VArray is a Virtual Array class, in which a multi-dimensional array data is 
stored on memory (NArray, NArrayMiss) or in file (NetCDFVar etc). 
The in-file data handling is left to subclasses such as VArrayNetCDF,
and this base class handles the following two cases:

(1) Data are stored on memory using NArray
(2) Subset of another VArray (possibly a subclass such as VArrayNetCDF).

Perhaps the latter case needs more explanation. Here, a VArray is defined 
as a subset of another VArray, so the current VArray has only the link
and info on how the subset is mapped to the other VArray.

A VArray behaves just like a NArray, i.e., a numeric multi-dimensional 
array. The important difference is that a VArray has a name and can 
have "attributes" like a NetCDF variable. Therefore, VArray can perfectly
represent a NetCDFVar, which is realized by a sub-class VArrayNetCDF.

NOMENCLATURE

* value(s): The multi-dimensional numeric array contained in the VArray,
  or its contents

* attribute(s): A combination of name and data that describes a VArray.
  Often realized by NumRu::Attribute class (or it is a NetCDFAttr in 
  VArrayNetCDF). The name must be a string, and the type of attribute
  values is restricted to a few classes for compatibility with
  NetCDFAttr (See NumRu::Attribute)

==Class Methods

---VArray.new(narray=nil, attr=nil, name=nil)

    A constructor

    ARGUMENTS
    * narray (NArray or NArrayMiss; default:nil) The array to be held.
      (nil is used to initialize a mapping to another VArray by a protected
      method).
    * attr (NumRu::Attribute; default:nil) Attributes. If nil, an empty 
     attribute object is created and stored.
    * name (String; default nil) Name of the VArray. If nil, it is named "noname".

    RETURN VALUE
    * a VArray

    EXAMPLE

        na = NArray.int(6,3).indgen!
        va1 = VArray.new( na, nil, "test" )

---VArray.new2(ntype, shape, attr=nil, name=nil)

    Another constructor. Uses parameters to initialize a NArray to hold.

    ARGUMENTS
    * ntype (String or NArray constants): Numeric type of the NArray to be
      held (e.g., "sfloat", "float", NArray::SFLOAT, NArray::FLOAT)
    * shape (Array of Integers): shape of the NArray
    * attr (Attribute; default:nil) Attributes. If nil, an empty attribute
      object is created and stored.
    * name (String; default nil) Name of the VArray.

    RETURN VALUE
    * a VArray


==Instance Methods

---val
    Returns the values as a NArray (or NArrayMiss).

    This is the case even when the VArray is a mapping to another. Also,
    this method is to be redefined in subclasses to do the same thing.

    ARGUMENTS -- none

    RETURN VALUE
    * a NArray (or NArrayMiss)

---val=(narray)

    Set values.

    The whole values are set. If you want to set partly, use ((<[]=>)).
    In this method, values are read from narray and set into the internal
    value holder. Thus, for exampled, the numeric type is not changed
    regardress the numeric type of narray. Use ((<replace_val>)) to
    replace entirely with narray.

    ARGUMENTS
    * narray (NArray or NArrayMiss or Numeric): If Numeric, the whole
      values are set to be equal to it. If NArray (or NArrayMiss), its
      shape must agree with the shape of the VArray.

---replace_val(narray)

    Replace the internal array data with the object narray.
    Use ((<val=>)) if you want to copy the values of narray.

    ARGUMENTS
    * narray (NArray or NArrayMiss): as pxlained above.
      Its shape must agree with the shape of the VArray (self).

    RETURN VALUE
    * if (self.class == VArray), self;
      otherwise (if self.class is a subclass of VArray), a new VArray.

---[]
    Get a subset. Its usage is the same as NArray#[]

---[]=
    Set a subset. Its usage is the same as NArray#[]=

---attr
    To be undefined.

---ntype

    Returns the numeric type.

    ARGUMENTS -- none

    RETURN VALUE
    * a String ("byte", "sint", "int", "sfloat", "float", "scomplex"
      "complex", or "obj"). It can be used in NArray.new to initialize
      another NArray.

---rank
    Returns the rank (number of dimensions)

---shape
    Returns the shape

---shape_current
    aliased to ((<shape>)).

---length
    Returns the length of the VArray

---typecode
    Returns the NArray typecode

---name
    Returns the name

    RETURN VALUE
    * (String) name of the VArray

---name=(nm)
    Changes the name.

    ARGUMENTS
    * nm(String): the new name.

    RETURN VALUE
    * nm

---rename!(nm)
    Changes the name (Same as ((<name=>)), but returns self)

    ARGUMENTS
    * nm(String): the new name.

    RETURN VALUE
    * self

---rename(nm)
    Same as rename! but duplicate the VArray object and set its name.

    This method may not be supported in sub-classes, since it is sometimes
    problematic not to change the original.

---copy(to=nil)
    Copy a VArray. If to is nil, works as the deep cloning (duplication of the entire object).

    Both the values and the attributes are copied.

    ARGUMENTS
    * to (VArray (possibly a subclass) or nil): The VArray to which the 
      copying is made.

---reshape!( *shape )
    Changes the shape without changing the total size. May not be available in subclasses.

    ARGUMENTS
    * shape (Array of Integer): new shape

    RETURN VALUE
    * self

    EXAMPLE
       vary = VArray.new2( "float", [10,2])
       vary.reshape!(5,4)   # changes the vary 
       vary.copy.reshape!(2,2,5)  # make a deep clone and change it
             # This always works with a VArray subclass, since vary.copy
             # makes a deep clone to VArray with NArray.

---file
    Returns a file object if the data of the VArray is in a file, nil if it is on memory

    ARGUMENTS
    * none

    RETURN VALUE
    * an object representing the file in which data are stored. Its class
      depends on the file type. nil is returned if the data is not in a file.


---transpose(*dims)
    Transpose. Argument specification is as in NArray.

---reshape(*shape)
    Reshape. Argument specification is as in NArray.

---axis_draw_positive
    Returns the direction to plot the axis (meaningful only if self is a
    coordinate variable.) 
    
    The current implementation is based on NetCDF conventions, 
    so REDEFINE IT IN SUBCLASSES if it is not appropriate.
    
    RETURN VALUE
    * one of the following:
      * true: axis should be drawn in the increasing order (to right/upward)
      * false: axis should be drawn in the decreasing order
      * nil: not specified

---axis_cyclic?
    Returns whether the axis is cyclic (meaningful only if self is a
    coordinate variable.) 
    
    The current implementation is based on NetCDF conventions, 
    so REDEFINE IT IN SUBCLASSES if it is not appropriate.
    
    RETURN VALUE
    * one of the following:
      * true: cyclic
      * false: not cyclic
      * nil: not specified

---axis_modulo
    Returns the modulo of a cyclic axis (meaningful only if self is a
    coordinate variable and it is cyclic.) 
    
    The current implementation is based on NetCDF conventions, 
    so REDEFINE IT IN SUBCLASSES if it is not appropriate.
    
    RETURN VALUE
    * one of the following:
      * Float if the modulo is defined
      * nil if modulo is not found

---coerce(other)
    For Numeric operators. (If you do not know it, see a manual or book of Ruby)

==Methods compatible with NArray

VArray is a numeric multi-dimensional array, so it supports most of the
methods and operators in NArray. Here, the name of those methods are just 
quoted. See the documentation of NArray for their usage.

=== Math functions

====sqrt, exp, log, log10, log2, sin, cos, tan, sinh, cosh, tanh, asin, acos, atan, asinh, acosh, atanh, csc, sec, cot, csch, sech, coth, acsc, asec, acot, acsch, asech, acoth

=== Binary operators

====-, +, *, /, %, **, .add!, .sub!, .mul!, .div!, mod!, >, >=, <, <=, &, |, ^, .eq, .ne, .gt, .ge, .lt, .le, .and, .or, .xor, .not

=== Unary operators

====~ - +

=== Mean etc

====mean, sum, stddev, min, max, median

=== Other methods

These methods returns a NArray (not a VArray).

====all?, any?, none?, where, where2, floor, ceil, round, to_f, to_i, to_a

=end

   class Units
      # for automatic operator generation in VArray
      def mul!(other); self*other; end
      def div!(other); self/other; end
   end    # class Units

   class VArray

      ### < basic parts to be redefined in subclasses > ###

      def initialize(narray=nil, attr=nil, name=nil)
	 # initialize with an actual array --- initialization by subset
	 # mapping is made with VArray.new.initialize_mapping(...)
	 @name = ( name || "noname" )
	 @mapping = nil
	 @varray = nil
	 @ary = __check_ary_class(narray)
	 case attr
	 when Attribute
	    @attr = attr
	 when VArray
	    vary = attr
	    @attr = vary.attr_copy
	 when Hash
	    @attr = NumRu::Attribute.new
	    attr.each{|key,val| @attr[key]=val}
	 when nil
	    @attr = NumRu::Attribute.new
	 else
	   raise TypeErroor, "#{attr.class} is unsupported for the 2nd arg"
	 end
      end

      attr_reader :mapping, :varray, :ary
      protected :mapping, :varray, :ary

      def inspect
	 if !@mapping
            "<'#{name}' #{ntype}#{shape.inspect} val=[#{(0...(4<length ? 4 : length)).collect do |i| @ary[i].to_s+',' end}#{'...' if 4<length}]>"
	 else
	    "<'#{name}' shape=#{shape.inspect}  subset of a #{@varray.class}>"
	 end
      end

      def VArray.new2(ntype, shape, attr=nil, name=nil)
	 ary = NArray.new(ntype, *shape)
	 VArray.new(ary, attr, name)
      end

      def val
	if @mapping
	  ary = @varray.ary
	  slicer = @mapping.slicer
	  if ary.is_a?(NArray) || ary.is_a?(NArrayMiss)
	    # interpret Hash slicers for NArray/NArrayMiss 
	    #   -- this part would not be needed if NArray supported it.
	    new_slicer = Array.new
	    for idx in 0...slicer.length
	      sl = slicer[idx]
	      if sl.is_a?(Hash)
		range, step = sl.to_a[0]
		dim_len = ary.shape[idx]
		first = range.first
		first += dim_len if first<0
		last = range.last
		last += dim_len if last<0
		if first<0 || first>=dim_len || last<0 || last>=dim_len || step==0
		  raise "slicer #{slicer.inspect} for dim #{idx} is invalid (dim_len=#{dim_len})"
		end
		step = -step if ( (last-first)*step < 0 )
		length = (last-first) / step + 1
		new_slicer[idx] = first + step * NArray.int(length).indgen!
	      else
		new_slicer[idx] = sl
	      end
	    end
	    slicer = new_slicer
	  end
	  ary[*slicer]
	else
	  @ary.dup
	end
      end

      def val=(narray)
	 if @mapping
	    @varray.ary[*@mapping.slicer] = __check_ary_class2(narray)
	 else
	    @ary[] = __check_ary_class2(narray)
	 end
	 narray
      end

      def replace_val(narray)
	narray = __check_ary_class(narray)
	if self.class != VArray
	  raise "replace_val to #{self.class} is disabled. Use val= instead"
	end
	if narray.shape != shape 
	  raise "shape of the argument (#{narray.shape.inspect}) !="+
	    " self.shape (#{shape.inspect})"
	end
	@ary = narray
	if @mapping
	  # to non subset
	  @name = @varray.name
	  @attr = @varray.attr_copy
	  @mapping = @varray = nil
	end
	self
      end

      def ntype
	 if !@mapping
	    __ntype(@ary)
	 else
	    __ntype(@varray.ary)
	 end
      end

      def name=(nm)
	 raise ArgumentError, "name should be a String" if ! nm.is_a?(String)
	 if @mapping
	    @varray.name = nm
	 else
	    @name = nm
	 end
	 nm
      end
      def rename!(nm)
	 self.name=nm
	 self
      end
      def rename(nm)
	self.dup.rename!(nm)
      end

      def reshape!( *shape )
	if @mapping
	  raise "Cannot reshape an VArray mapped to another. Use copy first to make it independent"
	else
	  @ary.reshape!( *shape )
	end
	self
      end

      def file
	if @mapping
	  @varray.file
	else
	  raise nil
	end
      end

      ### < basic parts invariant in subclasses > ###

      def copy(to=nil)
	 attr = self.attr_copy( (to ? to.attr : to) )
	 val = self.val
	 if self.class==VArray && !self.mapped? && (to==nil || to.class==VArray)
	    val = val.dup
	 end
	 if to
	    to.val = val
	    to
	 else
	    VArray.new(val, attr, self.name)
	 end
      end

      #def reshape( *shape )
      #	 # reshape method that returns a new entire copy (deep one).
      #	 # ToDo :: prepare another reshape method that does not make the
      #	 # entire copy (you could use NArray.refer, but be careful not 
      #	 # to make it public, because it's easily misused)
      #	 newobj = self.copy
      #	 newobj.ary.reshape!( *shape )
      #	 newobj
      #end

      def mapped?
	 @mapping ? true : false
      end

      def initialize_mapping(mapping, varray)
	 # protected method
	 raise ArgumentError if ! mapping.is_a?(SubsetMapping)
	 raise ArgumentError if ! varray.is_a?(VArray)
	 if ! varray.mapping
	    @mapping = mapping
	    @varray = varray
	 else
	    # To keep the mapping within one step
	    @mapping = varray.mapping.composite(mapping)
	    @varray = varray.varray
	 end
	 @attr = NumRu::Attribute.new
	 @ary = nil
	 self
      end
      protected :initialize_mapping

      def attr
	 if @mapping
	    @varray.attr
	 else
	    @attr
	 end
      end
      protected :attr

      def attr_copy(to=nil)
	attr.copy(to)
      end

      def att_names
	attr.keys
      end
      def get_att(name)
	attr[name]
      end
      def set_att(name, val)
	attr[name]=val
	self
      end
      def del_att(name)
	attr.delete(name)
      end
      alias put_att set_att

      def units
	str_units = attr['units']
	if !str_units || str_units==''
	  str_units = '1'              # represents non-dimension
	end
	Units.new( str_units )
      end

      def units=(units)
	attr['units'] = units.to_s
	units
      end

      def convert_units(to)
	if ! to.is_a?(Units)
	  to = Units.new(to)
	end
	myunits = self.units
	if myunits != to
	  gp = myunits.convert2(self, to)
	  gp.units = to
	  gp
	else
	  self   # returns self (no duplication)
	end
      end

      def long_name
	attr['long_name']
      end

      def long_name=(nm)
	attr['long_name'] = nm
      end

      def [](*slicer)
	 slicer = __rubber_expansion( slicer )
	 mapping = SubsetMapping.new(self.shape_current, slicer)
	 VArray.new.initialize_mapping(mapping, self)
      end

      def []=(*args)
	 val = args.pop
	 slicer = args
	 slicer = __rubber_expansion( slicer )
	 if val.is_a?(VArray)
	    val = val.val
	 else
	    val = __check_ary_class2(val)
	 end
	 if @mapping
	    sl= @mapping.composite(SubsetMapping.new(self.shape,slicer)).slicer
	    @varray[*sl]=val
	 else
	    @ary[*slicer]=val
	 end
	 val
      end

      def name
	 if @mapping
	    @varray.name
	 else
	    @name.dup
	 end
      end

      def transpose(*dims)
	VArray.new( val.transpose(*dims), attr_copy, name )
      end

      def reshape(*shape)
	VArray.new( val.reshape(*shape), attr_copy, name )
      end

      def axis_draw_positive
	# Default setting is taken from a widely used netcdf convention.
	# You can override it in a sub-class or using convention specific 
	# mixins.
	positive = attr['positive']
	case positive
	when /up/i
	  true
	when /down/i
	  false
	else
	  nil    # not defined, or if not 'up' or 'down'
	end  
      end

      def axis_cyclic?
	# Default setting is taken from a widely used netcdf convention.
	# You can override it in a sub-class or using convention specific 
	# mixins.
	topology = attr['topology']
	case topology
	when /circular/i
	  true
	when nil     # 'topology' not defined
	  if attr['units'] == 'degrees_east'
	    true     # special treatment a common convention for the earth
	  else
	    nil      # not defined --> nil
	  end
	else
	  false
	end  
      end

      def axis_modulo
	# Default setting is taken from a widely used netcdf convention.
	# You can override it in a sub-class or using convention specific 
	# mixins.
	if attval=attr['modulo']
	  if attval.is_a?(String)
	    attval.to_f
	  else
	    attval[0]
	  end
	else
	  if attr['units'] == 'degrees_east'
	    360.0     # special treatment a common convention for the earth
	  else
	    nil      # not defined --> nil
	  end
	end
      end

      ### < NArray methods > ###

      ## ToDo: implement units handling
      ## ToDo: coerce

      def coerce(other)
	oattr = self.attr_copy
	case other
	when UNumeric
	  oattr['units'] = other.units.to_s
	  na_other, = NArray.new(self.typecode, 1).coerce(other.val)   # scalar
	  c_other = VArray.new(na_other, oattr, self.name)
	else
	  oattr['units'] = self.get_att('units')     # Assume the same units
	  case other
	  when Numeric
	    na_other, = NArray.new(self.typecode, 1).coerce(other)   # scalar
	    c_other = VArray.new(na_other, oattr, self.name)
	  when Array
	    na = NArray.to_na(other)
	    c_other = VArray.new(na, oattr, self.name)
	  when NArray, NArrayMiss
	    c_other = VArray.new(other, oattr, self.name)
	  else
	    raise "Cannot coerse #{other.class}"
	  end
	end
	[c_other, self]
      end

      Math_funcs_nondim = ["exp","log","log10","log2","sin","cos","tan",
	    "sinh","cosh","tanh","asinh","acosh",
	    "atanh","csc","sec","cot","csch","sech","coth",
	    "acsch","asech","acoth"]
      Math_funcs_radian = ["asin","acos","atan","atan2","acsc","asec","acot"]
      Math_funcs = Math_funcs_nondim + Math_funcs_radian + ["sqrt"]

      Binary_operators_Uop   = ["*","/","**", ".mul!",".div!"]
      Binary_operators_Uconv = ["+","-",".add!",".sbt!"]
      Binary_operators_Unone = ["%",".mod!",".imag="]
      Binary_operators = Binary_operators_Uop + 
	                 Binary_operators_Uconv +
	                 Binary_operators_Unone

      Binary_operatorsL_comp = [">",">=","<","<=",
	                 ".eq",".ne",".gt",".ge",".lt",".le"]
      Binary_operatorsL_other = ["&","|","^",".and",".or",".xor",".not"]
      Binary_operatorsL = Binary_operatorsL_comp +
                          Binary_operatorsL_other

      Unary_operators = ["-@","~"]

      # type1 methods: returns a VArray with the same shape
      # type2 methods: returns the result directly
      NArray_type1_methods = ["sort", "sort_index", 
	    "floor","ceil","round","to_f","to_i","to_type","abs",
	    "real","im","imag","angle","arg","conj","conjugate","cumsum",
	    "indgen","random"]

      NArray_type2_methods1 = ["all?","any?","none?","where","where2",
            "to_a", "to_string"]
      NArray_type2_methods2 = ["rank", "shape", "total","length"]
      NArray_type2_methods3 = ["typecode"]
      NArray_type3_methods = ["mean","sum","stddev","min","max","median"]
      # remaining: "transpose"

      NArray_type2_methods = Array.new.push(*NArray_type2_methods1).
	                         push(*NArray_type2_methods2).
	                         push(*NArray_type2_methods3)

      for f in Math_funcs_nondim
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*arg)
            newattr = self.attr_copy
            newattr['units'] = '1'
	    case arg.length
	    when 0
	      VArray.new( Misc::EMath.#{f}(self.val), newattr, self.name )
	    #when 1  # for atan2
	    #  ar = arg[0].respond_to?(:val) ? arg[0].val : arg[0]
	    #  VArray.new( Misc::EMath.#{f}(self.val, ar), newattr, self.name )
	    else
	      raise ArgumentError, "# of args must be 0 or 1"
	    end
	 end
         EOS
      end
      for f in Math_funcs_radian
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*arg)
            newattr = self.attr_copy
            newattr['units'] = 'rad'
	    case arg.length
	    when 0
	      VArray.new( Misc::EMath.#{f}(self.val), newattr, self.name )
	    when 1  # for atan2
	      ar = arg[0].respond_to?(:val) ? arg[0].val : arg[0]
	      ## ar = ar.to_f   # NMath.atan2 does not work with NArray.int
	      VArray.new( Misc::EMath.#{f}(self.val, ar), newattr, self.name )
	    else
	      raise ArgumentError, "# of args must be 0 or 1"
	    end
	 end
         EOS
      end
      def sqrt
	va = VArray.new( Misc::EMath.sqrt(self.val), self.attr_copy, self.name )
	va.units = units**Rational(1,2)
	va
      end

      for f in Binary_operators_Uop
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
	    case other
            when VArray, UNumeric
	       vl = self.val
	       vr = other.val
	       if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
		 ary = vl#{f}(vr)
	       else
		 ary = NArrayMiss.to_nam(vl)#{f}(vr)
	       end
	       va = VArray.new( ary, self.attr_copy, self.name )
	       va.units= self.units#{f}(other.units)
               va
	    when Numeric, NArray, NArrayMiss, Array
	       vl = self.val
	       vr = other
	       if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
		 ary = vl#{f}(vr)
	       else
		 ary = NArrayMiss.to_nam(vl)#{f}(vr)
	       end
	       va = VArray.new( ary, self.attr_copy, self.name )
	       if "#{f}" == "**" 
		 va.units= self.units#{f}(other)
               end
               va
            else
               c_me, c_other = other.coerce(self)
               c_me#{f}(c_other)
            end
	 end
	 EOS
      end
      for f in Binary_operators_Uconv
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
	    case other
            when VArray, UNumeric
               if self.get_att('units')
		 # self have non nil units
		 oval = other.units.convert2(other.val,self.units)
		 uni = self.units
	       else
		 oval = other.val
		 uni = other.units
	       end
	       vl = self.val
	       vr = oval
               if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
                 ary = vl#{f}(vr)
               else
                 ary = NArrayMiss.to_nam(vl)#{f}(vr)
               end
	       va = VArray.new( ary, self.attr_copy, self.name )
	       va.units = uni
	       va
	    when Numeric, NArray, NArrayMiss, Array
	       vl = self.val
	       vr = other
	       if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
		 ary = vl#{f}(vr)
               else
		 ary = NArrayMiss.to_nam(vl)#{f}(vr)
	       end
	       VArray.new( ary, self.attr_copy, self.name )
            else
               c_me, c_other = other.coerce(self)
               c_me#{f}(c_other)
            end
	 end
	 EOS
      end
      for f in Binary_operators_Unone
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
	    case other
            when VArray, UNumeric
	       vl = self.val
	       vr = other.val
	       if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
		 ary = vl#{f}(vr)
	       else
		 ary = NArrayMiss.to_nam(vl)#{f}(vr)
	       end
	       VArray.new( ary, self.attr_copy, self.name )
	    when Numeric, NArray, NArrayMiss, Array
	       vl = self.val
	       vr = other
	       if !( vl.is_a?(NArray) and vr.is_a?(NArrayMiss) )
		 ary = vl#{f}(vr)
	       else
		 ary = NArrayMiss.to_nam(vl)#{f}(vr)
	       end
	       VArray.new( ary, self.attr_copy, self.name )
            else
               c_me, c_other = other.coerce(self)
               c_me#{f}(c_other)
            end
	 end
	 EOS
      end
      for f in Binary_operatorsL_comp
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
            # returns NArray
	    case other
            when VArray, UNumeric
               self.val#{f}( other.units.convert2(other.val,units) )
	    when Numeric, NArray, NArrayMiss, Array
               self.val#{f}(other)
            else
               c_me, c_other = other.coerce(self)
               self#{f}(other)
            end
	 end
	 EOS
      end
      for f in Binary_operatorsL_other
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
            # returns NArray
	    case other
            when VArray, UNumeric
               self.val#{f}(other.val)
	    when Numeric, NArray, NArrayMiss, Array
               self.val#{f}(other)
            else
               c_me, c_other = other.coerce(self)
               self#{f}(other)
            end
	 end
	 EOS
      end
      for f in Unary_operators
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}
            ary = #{f.delete("@")} self.val
	    VArray.new( ary, self.attr_copy, self.name )
	 end
	 EOS
      end
      def +@
	self
      end
      for f in NArray_type1_methods
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
            newattr = self.attr_copy
            newattr['units'] = '1' if "#{f}"=="angle" || "#{f}"=="arg"
	    VArray.new(self.val.#{f}(*args), newattr, self.name )
	 end
         EOS
      end
      for f in NArray_type2_methods1
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
	    self.val.#{f}(*args)
	 end
	 EOS
      end
      for f in NArray_type2_methods2
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}
            if @mapping
	       @mapping.#{f}
	    else
	       @ary.#{f}
            end
	 end
	 EOS
      end
      for f in NArray_type2_methods3
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}
            if @mapping
	       @varray.ary.#{f}
	    else
	       @ary.#{f}
            end
	 end
	 EOS
      end
      for f in NArray_type3_methods
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
            result = self.val.#{f}(*args)
            if result.is_a?(NArray) || result.is_a?(NArrayMiss)
	       VArray.new(result , self.attr_copy, self.name )
            elsif result.nil?
               result
            else
	       UNumeric[result, units]    # used to be 'result' (not UNumeric)
            end
	 end
         EOS
      end

      alias shape_current shape

      ## < private methods >
      private
      def __rubber_expansion( args )
	if (id = args.index(false))  # substitution into id
          # false is incuded
	  alen = args.length
	  if args.rindex(false) != id
	    raise ArguemntError,"only one rubber dimension is permitted"
	  elsif alen > rank+1
	    raise ArgumentError, "too many args"
	  end
	  ar = ( id!=0 ? args[0..id-1] : [] )
	  args = ar + [true]*(rank-alen+1) + args[id+1..-1]
	end
	args
      end
      def __check_ary_class(narray)
	 case narray
	 when NArray, NArrayMiss, nil
	 else
	    raise ArgumentError, "Invalid array class: #{narray.class}" 
	 end
	 narray
      end
      def __check_ary_class2(narray)
	 case narray
	 when NArray, NArrayMiss, nil, Numeric
	 else
	    raise ArgumentError, "Invalid array class: #{narray.class}" 
	 end
	 narray
      end
      def __ntype(na)
	 case na.typecode
	 when NArray::BYTE
	    "byte"
	 when NArray::SINT
	    "sint"
	 when NArray::LINT
	    "int"
	 when NArray::SFLOAT
	    "sfloat"
	 when NArray::DFLOAT
	    "float"
	 when NArray::SCOMPLEX
	    "scomplex"
	 when NArray::DCOMPLEX
	    "complex"
	 when NArray::ROBJ
	    "obj"
	 end
      end

   end    # class VArray

end

##################################
### < test > ###

if $0 == __FILE__
   include NumRu
   p va = VArray.new( NArray.int(6,2,3).indgen!, nil, 'va' )
   va.units="m"
   va.long_name="test data"
   vs = va[2..4,0,0..1]
   p "@@@",vs.rank,vs.shape,vs.total,vs.val,vs.get_att("name")
   p '@@@@',vs.long_name,vs.units.to_s
   vs.val=999
   p "*1*",va
   co,=va.coerce(UNumeric.new(1,Units.new("rad")))
   p '*coerce*',co, co.units
   p "*2*",vt = vs/9, vs + vt
   p "*3*",vt.log10
   p "*4*",(vt < vs)
   vt.name='vvvttt'
   p "*5*",(3+vt), vt.sin, vt.cos
   vc = vt.copy
   p 'atan2'
   vv = VArray.new( NArray.sfloat(5).indgen!, nil, 'vv' )
   p vv.atan2(vv).val
   p "eq",vc.eq(vt),vc.equal?(vt)

   vd = VArray.new( NArray.int(6).indgen!+10 )
   p "+++",vd[1],vd[1].rank,vd[1].val
   p va.val
   p vs
   p va.sort.val
   p vs.to_a, vs.to_string, vs.to_f, vs.to_type(NArray::SINT)
   p "@@@",va.max, va.max(0), va.max(0,1)

   vkg = VArray.new( NArray.float(4,3).indgen!, nil, 'vkg' )
   vkg.units = 'kg'
   vg = vkg.copy
   vg.units = 'g'
   vmul = vkg*vg
   p '##', vkg.val, vmul.get_att('units'), vmul.units
   p '##', (vkg + vg).val, (vg + vkg).val, vkg > vg

   p '*convert_units*'
   p vg.units,vg.val
   vkg = vg.convert_units('kg')
   p vkg.units,vkg.val

   p '*axis conventions*'
   p vx = VArray.new( NArray.int(6).indgen!, nil, 'x' )
   vx.set_att('topology','circular')
   vx.set_att('modulo',[360.0])
   vx.set_att('positive','down')
   p vx.axis_draw_positive, vx.axis_cyclic?, vx.axis_modulo
end
