=begin
=class NumRu::GPhys

==Class Methods

---GPhys.new(grid, data)
    Constructor.

    ARGUMENTS
    * grid (a Grid) : the grid
    * data (a VArray) : the data. (('grid')) and (('data')) must have
      the same shape.

    RETURN VALUE
    * a GPhys

    NOTE
    * the arguments are NOT duplicated to construct a GPhys.

---GPhys.each_along_dims(gphyses, *loopdims){...}  # a block is expected

    Iterator to process GPhys objects too big to read on memory at once.

    Makes a loop (loops) by dividing the GPhys object(s) (((|gphyses|)))
    with the dimension(s) specified by ((|loopdims|)).
    If the return value of the block is an Array, it is assumed to consist
    of GPhys objects, and the return value of this method is an Array
    in which the whole of the results are reconstructed as if no
    iteration is made, which is the same behavior as
    ((|GPhys::IO.each_along_dims_write|)). If the return value of 
    the block is not an Array, this methods returns nil.

    WARNING: Unlike ((|GPhys::IO.each_along_dims_write|)),
    the results of this method is NOT written in file(s),
    so be careful about memory usage if you put an Array of GPhys as the 
    return value of the block. You will probably need to have the size
    of them smaller than input data.

    ARGUMENTS
    * gphyses (GPhys or Array of GPhys): GPhys object(s) to be processed.
      All of them must have dimensions specified with ((|loopdims|)),
      and their lengths must not vary among files. Other dimensions
      are arbitrary, so, for example,  ((|gphyses|)) could be 
      [a(lon,lat,time), b(lat,time)] as long as loopdims==["time"].
    * loopdims (Array of String or Integer) : name (when String) or
      count starting from zero (when Integer) 
    * expected block : Number of arguments == number of GPhys objects in
      ((|gphyses|)).

    RETURN VALUE
    * If the return value of the block is an Array,
      GPhys objects in which the whole results are written in
      (the Array must consist of GPhys objects).
      If the return value of the block is NOT an Array,
      nil is returned.

    ERRORS

    The following raise exceptions (in addition to errors in arguments).

    * Dimensions specified by ((|loopdims|)) are not shared among
      GPhys objects in ((|gphyses|)).
    * Return value of the block is an Array, but it does not consist of 
      GPhys objects.
    * (Only when the return value of the block is an Array):
      Dimension(s) used for looping (((|loopdims|))) is(are) eliminated
      from the returned GPhys objects.
    
    USAGE

    See the manual of ((|GPhys::IO.each_along_dims_write|)).

---GPhys.join_md_nocheck(gpnary)
    Join multiple GPhys objects that are ordered perfectly in a NArray.

    LIMITATION (as of 2013-03-04)
    * joining assoc_coords is yet to be supported; Currently
      assoc_coords are ignored if any.

    ARGUMENT
    * gpnarray [NArray of GPhys] having the same rank with that of
      its component GPhys objects. multiple GPhys objects are joined
      along the dimension with multiple elements (the order is kept). 

    RETURN VALUE
    * a GPhys

---GPhys.join_md(gpnary)
    Join multiple GPhys objects (ordered in a NArray).
   
    Like GPhys.join_md_nocheck but it supports insersion
    of omitted 1-element dimensions and transpose for
    gpnary (the input NArray). It means that the rank of gpnary
    can be smaller than that of its compoent GPhys objects, and
    the order of dimensions can be arbitrary. Also,
    the order of coordinate values along each dimension does not 
    have to be monotonic; the method supports sorting and spliting
    along dimensions. For example, if gpnary == NArray.object(2):[gp0, gp1],
    where the first object gp0 has the 1st coordinate [0,1,7,8] and
    the second object gp1 has the 1st coordinate [3,4,5,6],
    gpnary is restructured as [ gp0[0..1,false], gp1, gp0[2..3,false] ],
    and join is made by using GPhys.join_md_nocheck.
    
    This method is generally faster than GPhys.join unless the split
    is one-dimensional.
    
    ARGUMENT
    * gpnarray [NArray of GPhys] 

    RETURN VALUE
    * a GPhys

---GPhys.join(gpary)
    Join multiple GPhys objects (no need for any pre-ordering).
   
    ARGUMENT
    * gpnarray [Array (or 1D NArray) of GPhys]

    RETURN VALUE
    * a GPhys

---GPhys.concat(gpary, axis_or_ary, name=nil, attr=nil)
    Concatenate an Array (or 1D NArray) of GPhys objects
    along the new dimension specified by the 2nd to 4th arguments.
    The rank of the result (a GPhys) is one plus the rank of 
    the GPhys objects.

    ARGUMENTS
    * gpary [1D NArray or Array of GPhys]
    * axis_or_ary [an Axis or a 1D NArray or Array of floats]
    * name [String; optional] name of the coordinate; 
      needed if axis_or_ary is not an Axis.
    * attr [Hash; optional] attributes of the coordinate;
      used if axis_or_ary is not an Axis.

    RETURN VALUE
    * a GPhys

==Instance Methods
---data
    Returns the data object

    RETURN VALUE
    * a VArray

    NOTE
    * the data object is NOT duplicated.

---grid_copy
    Returns a copy (deep  clone) of the grid object.
  
    RETURN VALUE
    * a Grid

    NOTE
    * (('grid')) does not make a copy.

---grid
    Returns the grid object without copying.
  
    RETURN VALUE
    * a Grid

    NOTE
    * Use (('grid_copy')) to avoid side effects

---copy
    Make a deep clone onto memory

    RETURN VALUE
    * a GPhys

---name
    Returns the name of the GPhys object, which is equal to the 
    name of the data object in the GPhys object.

    RETURN VALUE
    * a String

---name=(nm)

    Set the name of the GPhys object.

    ARGUMENTS
    * nm (String)

    RETURN VALUE
    * nm (the argument)

---rename(nm)

    Same as ((<name=>)), but (('self')) is returned.

    ARGUMENTS
    * nm (String)

    RETURN VALUE
    * self

---val
    Returns data values

    RETURN VALUE
    * a NArray or NArrayMiss. It is always a copy and to write in it
      will not affect self.

---val=(v)
    Writes in data values.

    ARGUMENTS
    * v (NArray, NArrayMiss, or Numeric) : data to be written in.

    RETURN VALUE
    * v (the argument)

    NOTE
    * the contents of (('v')) are copied in, unlike ((<replace_val>))

---replace_val(v)
    Replace the data values.

    ARGUMENTS
    * v (NArray or NArrayMiss) : data to be written in.

    RETURN VALUE
    * self

    NOTE
    * This method is similar to ((<val=>)), but
      the whole numeric data object is replaced with (('v')).
      It is not very meaningful if the data is in a file:
      the file is not modified, but you just get an GPhys object on memory.

---att_names
    Returns attribute names of the data object.

    RETURN VALUE
    * Array of String

---get_att(name)
    Get the value of the attribute named (('name')).

    ARGUMENTS
    * name (String)

    RETURN VALUE
    * String, NArray, or nil

---set_att(name, val)
---put_att(name, val)

    Set an attribute of the data object

    ARGUMENTS
    * name (String)
    * val (String, NArray, or nil)

    RETURN VALUE
    * self

---del_att(name)
    Delete an attribute of the data object.

    ARGUMENTS
    * name (String)

    RETURN VALUE
    * self

---ntype
    Returns the numeric type of the data object.

    RETURN VALUE
    * String such as "float", and "sfloat"

    NOTE
    * See also ((<typecode>)).

---typecode
    Returns the numeric type of the data object.

    RETURN VALUE
    * NArray constants such as NArray::FLOAT and NArray::SFLOAT.

    NOTE
    * See also ((<ntype>)).

---units
    Returns the units of the data object

    RETURN VALUE
    * a Units

---units=(units)
    Changes the units of the data object

    ARGUMENTS
    * units (Units or String)

    RETURN VALUE
    * units (the argument)

---convert_units(to)
    Convert the units of the data object

    ARGUMENTS
    * to (a Units)

    RETURN VALUE
    * a GPhys

---long_name
    Returns the "long_name" attribute the data object

    RETURN VALUE
    * a String
---long_name=(to)

    Changes/sets the "long_name" attribute the data object

    ARGUMENTS
    * to (a String)

    RETURN VALUE
    * to (the argument)

---[]
    Returns a subset.

    ARGUMENTS
    * Same as those for NArray#[], NetCDFVar#[], etc.

    RETURN VALUE
    * a GPhys

---[]=
    Sets values of a subset

    RETURN VALUE
    * the data object on the rhs

---cut
    Similar to ((<[]>)), but the subset is specified by physical coordinate.

    ARGUMENTS
    * pattern 1: similar to those for ((<[]>)), where the first
      argument specifies a subset for the first dimension.
    * pattern 2: by a Hash, in which keys are axis names.

    EXAMPLES
    * Pattern 1
       gphys.cut(135.5,0..20.5,false)
    * Pattern 2
       gphys.cut({'lon'=>135.5,'lat'=>0..20})

    RETURN VALUE
    * a GPhys
   
---cut_rank_conserving
    Similar to ((<cut>)), but the rank is conserved by not eliminating
    any dimension (whose length could be one).

---axnames
    Returns the names of the axes

    RETURN VALUE
    * an Array of String

---rank
    Returns the rank

    RETURN VALUE
    * an Integer

---axis(dim)
    Returns the Axis object of a dimension.

    ARGEMENTS
    * dim (Integer or String)

    RETURN VALUE
    * an Axis

---coord(dim)
---coordinate(dim)

    Returns the coordinate variable

    ARGUMENTS
    * dim (Integer or String)

    RETURN VALUE
    * a VArray

    NOTE
    * (('coord(dim)')) is equivalent to (('axis(dim).pos'))

---lost_axes
    Returns info on axes eliminated during operations.

    Useful for annotation in plots, for example (See the code of GGraph
    for an application).

    RETURN VALUE
    * an Array of String

---dim_index( dimname )
    Returns the integer id (count from zero) of the dimension

    ARGUMENT
    * dimname (String or Integer) : this method is trivial if is is an integer

    RETURN VALUE
    * an Integer

---integrate(dim)
    Integration along a dimension.

    RETURN VALUE
    * a GPhys

    NOTE
    * Algorithm implementation is done in Axis class.

---average(dim)
    Averaging along a dimension.

    RETURN VALUE
    * a GPhys

    NOTE
    * Algorithm implementation is done in Axis class.


---eddy(*dim)
    Deviation from mean

    ARGUMENT
    * a list of dimensions (including none) [Integer or String] along which
      the mean is taken.

    RETURN VALUE
    * a GPhys

    NOTE
    * Simply defined as

        def eddy(*dim)
          self - self.mean(*dim)
        end

---first1D
    Returns a 1D subset selecting the first elements of 2nd, 3rd, ..
    dimensions, i.e., self[true, 0, 0, ...]. (For graphics)

    ARGUMENTS
    * (none)

    RETURN VALUE
    * a GPhys

---first2D
    Returns a 2D subset selecting the first elements of 3rd, 4th, ..
    dimensions, i.e., self[true, true, 0, 0, ...]. (For graphics)

    ARGUMENTS
    * (none)

    RETURN VALUE
    * a GPhys

---first3D
    Returns a 3D subset selecting the first elements of 4th, 5th, ..
    dimensions, i.e., self[true, true, true, 0, ...]. (For graphics)

    ARGUMENTS
    * (none)

    RETURN VALUE
    * a GPhys

---coerce(other)
    ((|You know what it is.|))

---shape_coerce(other)
    Like ((<coerce>)), but just changes shape without changing numeric type
    by possibly inserting dimensions whose lengths are one (i.e.,
    without changeing the total length of data).

---shape_coerce_full(other)
    Similar to ((<shape_coerce>)) but to return the gphyses having  
    really the same shape with possible expansion by replication.

---transpose(*dims)
    Transpose.

    ARGUMENTS
    * dims (integers) : for example, [1,0] to transpose a 2D object.
      For 3D objects, [1,0,2], [2,1,0], etc.etc.

    RETURN VALUE
    * a GPhys

---shape_current
    Returns the current shape of the GPhys object.

    RETURN VALUE
    * an Array of Integer

---shape
    Aliased to ((<shape_current>))

---cyclic_ext(dim_or_dimname, modulo)
    Extend a dimension cyclically.

    The extension is done only when adding one grid point makes a full circle.
    Thus, data at coordinate values [0,90,180,270] with modulo 360 are extended
    (to at [0,90,180,270,360]), but data at [0,90,180] are not extended with
    the same modulo: in this case, self is returned.

    ARGUMENTS
    * dim_or_dimname (String or Integer)
    * modulo (Numeric)

    RETURN VALUE
    * a GPhys (possibly self)


=== Math functions (instance methods)

====sqrt, exp, log, log10, log2, sin, cos, tan, sinh, cosh, tanh, asin, acos, atan, asinh, acosh, atanh, csc, sec, cot, csch, sech, coth, acsc, asec, acot, acsch, asech, acoth

=== Binary operators

====-, +, *, /, %, **, .add!, .sub!, .mul!, .div!, mod!, >, >=, <, <=, &, |, ^, .eq, .ne, .gt, .ge, .lt, .le, .and, .or, .xor, .not

=== Unary operators

====~ - +

=== Mean etc (instance methods)

====mean, sum, stddev, min, max, median

=== Other instance methods

These methods returns a NArray (not a GPhys).

====all?, any?, none?, where, where2, floor, ceil, round, to_f, to_i, to_a



=end

require "numru/gphys/grid"
require "numru/misc/md_iterators"
require "numru/gphys/narray_ext"
require "numru/gphys/mdstorage"   # for GPhys.join

module NumRu
   class GPhys

      include NumRu::Misc::MD_Iterators

      def initialize(grid, data)
	 #raise ArgumentError,"1st arg not a Grid" if ! grid.is_a?(Grid)
	 #raise ArgumentError,"2nd arg not a VArray" if ! data.is_a?(VArray)
	 if ( grid.shape_current != data.shape_current )
	    raise ArgumentError, "Shapes of grid and data do not agree. " +
	       "#{grid.shape_current.inspect} vs #{data.shape_current.inspect}"
	 end
	 @grid = grid
	 @data = data
      end

      attr_reader :grid, :data
      ###protected :grid      # protection is lifted

      def grid_copy
	# deep clone of the grid
	@grid.copy
      end

      def copy
	 # deep clone onto memory
	 self.class.new( @grid.copy, @data.copy )
      end

      def inspect
        "<#{self.class} grid=#{@grid.inspect}\n   data=#{@data.inspect}>"
      end

      def name
	 data.name
      end
      def name=(nm)
	 data.name=nm
      end
      def rename(nm)
	data.name=nm
	self
      end

      def val
	 @data.val
      end
      def val=(v)
	 @data.val= v
      end
      def replace_val(v)
	 raise(ArgumentError,"Shape miss-match") if @grid.shape != v.shape
	 @data.replace_val(v)
	 self
      end

      def att_names
	@data.att_names
      end
      def get_att(name)
	@data.get_att(name)
      end
      def set_att(name, val)
	@data.set_att(name, val)
	self
      end
      def del_att(name)
	@data.del_att(name)
	self
      end
      alias put_att set_att

      def ntype
	@data.ntype
      end

      def units
	@data.units
      end
      def units=(units)
	@data.units= units
      end

      def convert_units(to)
	# ==NOTE: 
	#    * VArray#convert_units does not copy data if to == @data.units
	#    * @grid is shared with self (no duplication)
        #    Thus, use GPhys#copy to separate all sub-objects (deep clone).
	data = @data.convert_units(to)  
	self.class.new(@grid, data)
      end

      def long_name
	@data.long_name
      end
      def long_name=(long_name)
	@data.long_name= long_name
      end

      def [](*slicer)
	 if slicer.length==1 && slicer[0].is_a?(Hash) && 
	    slicer[0].keys[0].is_a?(String)
	   slicer = __process_hash_slicer(slicer[0])
	 else
	   slicer = __rubber_expansion( slicer )
	 end
	 self.class.new( @grid[*slicer], @data[*slicer] )
      end

      def []=(*args)
	 val = args.pop
	 slicer = args
	 if slicer.length==1 && slicer[0].is_a?(Hash) && 
	    slicer[0].keys[0].is_a?(String)
	   slicer = __process_hash_slicer(slicer[0])
	 else
	   slicer = __rubber_expansion( slicer )
	 end
	 val = val.data if val.respond_to?(:grid) #.is_a?(GPhys)
	 @data[*slicer] = val
      end

      def __process_hash_slicer(hash)
	raise ArgumentError, "Expect a Hash" if !hash.is_a?(Hash)
	if (hash.keys - axnames).length > 0
	  raise ArgumentError,"One or more of the hash keys "+
	    "(#{hash.keys.inspect}) are not found in the axis names "+
            "(#{axnames.inspect})."
	end
	axnames.collect{|nm| hash[nm] || true}   # slicer for []/[]=
      end
      private :__process_hash_slicer

      def cut( *args )
        if has_assoccoord? && args.length==1 && ((spec=args[0]).is_a?(Hash)) &&
            ( acnms = (spec.keys & assoccoordnames ) ).length > 0
          acspec = Hash.new
          acnms.each{|nm| acspec[nm] = spec.delete(nm)}
          grid, sl = @grid.cut_assoccoord(acspec)
          gphys = self.class.new( grid, self.data[*sl] )
        else
          gphys = self
        end
	newgrid, slicer = gphys.grid.cut( *args )
	self.class.new( newgrid, gphys.data[ *slicer ] )
      end

      def cut_rank_conserving( *args )
	newgrid, slicer = @grid.cut_rank_conserving( *args )
	self.class.new( newgrid, @data[ *slicer ] )
      end

      Axis.defined_operations.each do |method|
         eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{method}(dim_or_dimname, *extra_args)
            vary, grid = @grid.#{method}(@data, dim_or_dimname, *extra_args)
	    if grid 
	      self.class.new( grid, vary )
	    else
	      vary    # scalar
	    end
	 end
	 EOS
      end

      def axnames
	 @grid.axnames
      end
      def rank
	@grid.rank
      end
      def axis(i)
	@grid.axis(i)
      end
      def coord(i)
	@grid.coord(i)
      end
      def assoc_coord_gphys(name)
	@grid.assoc_coord_gphys(name)
      end
      alias coordinate coord
      def lost_axes
	 @grid.lost_axes
      end
      def set_lost_axes( lost )
        @grid.set_lost_axes( lost )
        self
      end
      def add_lost_axes( lost )
        @grid.add_lost_axes( lost )
        self
      end
      def dim_index( dimname )
	 @grid.dim_index( dimname )
      end
      def coordnames
        @grid.coordnames
      end
      def has_axis?(name)
        @grid.has_axis?(name)
      end
      def has_assoccoord?(*arg)
        @grid.has_assoccoord?(*arg)
      end
      def has_coord?(name)
        @grid.has_coord?(name)
      end
      def assoccoordnames
        @grid.assoccoordnames
      end
      def set_assoc_coords(assoc_crds)
        @grid.set_assoc_coords(assoc_crds)
      end
      def assoc_coords=(assoc_coords)
        @grid.assoc_coords=assoc_coords
      end
      def assoc_coords
        @grid.assoc_coords
      end

      ## Basic numerical operations that are not defined on the VArray level

      def eddy(*dim)
        self - self.mean(*dim)
      end

      ## For graphics -->
      def first3D
	raise "rank less than 3" if rank < 3
	self[true,true,*([0]*(rank-3))]
      end
      def first2D
	raise "rank less than 2" if rank < 2
	self[true,true,*([0]*(rank-2))]
      end
      def first1D
	raise "rank less than 1" if rank < 1
	self[true,*([0]*(rank-1))]
      end
      ## <-- For graphics

      def coerce(other)
	case other
	when Numeric
	  ##na_other = self.data.val.fill(other)   # Not efficient!
	  va_other, = self.data.coerce(other)
	  c_other = self.class.new( @grid[ *([0..0]*self.rank) ], 
			       va_other.reshape!( *([1]*self.rank) ) )
	  c_other.put_att('units',nil)   # should be treated as such, not 1
	when Array, NArray
	  va_other, = self.data.coerce(other)
	  c_other = self.class.new( @grid, va_other )
	  c_other.put_att('units',nil)   # should be treated as such, not 1
	when VArray
	  c_other = self.class.new( @grid, other )
	else
	  raise "Cannot coerse #{other.class}"
	end
	[c_other, self]
      end

      def shape_coerce(other)
	 #
	 # for binary operations
	 #
	 if self.rank == other.rank
	    # nothing to do
	    [other, self]
	 else
	    if self.rank < other.rank
	       shorter = self
	       longer = other
	       i_am_the_shorter = true
	    else
	       shorter = other
	       longer = self 
	       i_am_the_shorter = false
	    end
	    reshape_args = 
	       __shape_matching( shorter.shape_current, longer.shape_current, 
				shorter.axnames, longer.axnames )
	    shorter = shorter.data.copy.reshape!(*reshape_args)
	    ##def shorter.data; self; end  # singular method!
	    if i_am_the_shorter
	       [longer, shorter]
	    else
	       [shorter, longer]
	    end
	 end
      end

      def shape_coerce_full(other)
        o, s = shape_coerce(other)
        if o.length < s.length
          o = self.class.new( s.grid, o + NArray.new(o.typecode,*s.shape) )
        elsif o.length > s.length
          s = self.class.new( o.grid, s + NArray.new(s.typecode,*o.shape) )
        end
        [o, s]
      end

      def transpose(*dims)
	grid = @grid.transpose(*dims)
	data = @data.transpose(*dims)
	self.class.new( grid, data )
      end

      for f in VArray::Math_funcs
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 #def GPhys.#{f}(gphys)
         #   raise ArgumentError, "Not a GPhys" if !gphys.is_a?(GPhys)
	 #   self.class.new( gphys.grid, VArray.#{f}(gphys.data) )
	 #end
	 def #{f}(*arg)
	    self.class.new( self.grid, self.data.#{f}(*arg) )
	 end
         EOS
      end
      for f in VArray::Binary_operators
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
            if other.respond_to?(:grid) #.is_a?(GPhys)
	       other, myself = self.shape_coerce(other)
               if myself.respond_to?(:grid) #.is_a?(GPhys)
		 if other.respond_to?(:grid) #.is_a?(GPhys)
		   vary = myself.data#{f} other.data
                   newgrid = myself.grid.merge(other.grid)
		 else
		   vary = myself.data#{f} other
                   newgrid = myself.grid_copy
		 end
		 self.class.new( newgrid, vary )
	       else
		 if other.respond_to?(:grid) #.is_a?(GPhys)
		   vary = myself#{f} other.data
		 else
		   vary = myself#{f} other
		 end
		 self.class.new( other.grid.copy, vary )
	       end
	    else
	       vary = self.data#{f} other
	       self.class.new( @grid.copy, vary )
	    end
	 end
	 EOS
      end
      for f in VArray::Binary_operatorsL
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f.delete(".")}(other)
            # returns NArray
            self.data#{f}(other.respond_to?(:grid) ? other.data : other)
	 end
	 EOS
      end
      for f in VArray::Unary_operators
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}
            vary = #{f.delete("@")} self.data
	    self.class.new( @grid.copy, vary )
	 end
	 EOS
      end
      for f in VArray::NArray_type1_methods
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
	    self.class.new( self.grid.copy, self.data.#{f}(*args) )
	 end
	 EOS
      end
      for f in VArray::NArray_type2_methods
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
	    self.data.#{f}(*args)
	 end
	 EOS
      end
      for f in VArray::NArray_type3_methods
	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{f}(*args)
            args = args.collect{|i| @grid.dim_index(i)}
	    result = self.data.#{f}(*args)
            if Numeric===result || UNumeric===result
	      result
	    else
	      self.class.new( self.grid.delete_axes(args, "#{f}"), result )
	    end
	 end
	 EOS
      end

      def shape_current
	 @data.shape_current
      end
      alias shape shape_current

      def cyclic_ext(dim_or_dimname, modulo)
	# Cyclic extention to push the first element after the last element
        # if appropriate.

	# <<developper's memo by horinout, 2005/01>> 
	# in future modulo should be read based on conventions if nil

	vx = coord(dim_or_dimname)
	return self if vx.length <= 1

	vvx = vx.val
	width = (vvx[-1] - vvx[0]).abs
	dx = width / (vx.length-1)
	eps = 1e-4
	modulo = modulo.abs
	extendible = ( ((width+dx) - modulo).abs < eps*modulo )

	if extendible
	  dim = @grid.dim_index(dim_or_dimname)
	  newgp = self.copy[false, [0...vx.length, 0], *([true]*(rank-1-dim))]
	  vx = newgp.coord(dim).copy
	  vx[-1] = vx[-1].val + modulo
	  newgp.axis(dim).set_pos(vx)
	  return newgp
	else
	  return self
	end
      end

      def self.each_along_dims(gphyses, loopdims)
	if !gphyses.is_a?(Array)
	  gphyses = [gphyses]     # put in an Array (if a single GPhys)
	end
	gp = gphyses[0]

	if !loopdims.is_a?(Array)
	  loopdims = [loopdims]  # put in an Array (if a single Integer/String)
	end
	if loopdims.length == 0
	  #raise ArgumentError, "No loop dimension is specified "+
	  #  " -- In that case, you don't need this iterator."

	  return yield(*gphyses)  # trivial case supported just for generality
	end

	#if loopdims.min<0 || loopdims.max>=gp.rank
	#  raise ArguemntError,"Invalid dims #{loopdims.inspect} for #{gp.rank}D array"
	#end

	loopdimids = Array.new
	loopdimnames = Array.new
	loopdims.each{|d|
	  case d
	  when Integer
	    if d < 0
	      d += gp.rank
	    end
	    loopdimids.push( d )
	    loopdimnames.push( gp.axis(d).name )
	  when String
	    loopdimids.push( gp.dim_index(d) )
	    loopdimnames.push( d )
	  else
	    raise ArgumentError,"loopdims must consist of Integer and/or String"
	  end
	}

	sh = Array.new
	len = 1
	loopdimids.each{|i|
	  sh.push(gp.shape[i])
	  len *= gp.shape[i]
	}

	gphyses.each do |g|
	  for i in 1...gphyses.length
	    loopdimnames.each_with_index do |nm,i|
	      if !g.axnames.include?( nm )
		raise ArgumentError,"#{i+1}-th GPhys do not have dim '#{nm}'"
	      end
	      if g.coord(nm).length != sh[i]
		raise ArgumentError,"loop dimensions must have the same lengths(#{nm}; #{sh[i]} vs #{g.coord(nm).length})"
	      end
	    end
	  end
	end

	to_return = nil

	cs = [1]
	(1...sh.length).each{|i| cs[i] = sh[i-1]*cs[i-1]}
	idx_hash = Hash.new
	for i in 0...len do
	  loopdimnames.each_with_index{|d,j| 
	    idx_hash[d] = ((i/cs[j])%sh[j])..((i/cs[j])%sh[j]) # rank preserved
	  }
	  subs = gphyses.collect{|g| g[idx_hash] }
	  results = yield(*subs)
	  if results.is_a?(Array)  # then it must consist of GPhys objects
	    if i == 0
	      to_return = results_whole = Array.new
	      for j in 0...results.length
		rs = results[j]
		grid = rs.grid_copy
		loopdimnames.each{|nm|
		  # replaces with original axes (full length)
		  if !grid.axnames.include?( nm )
		    raise "Dimension '#{nm}' has been eliminated. "+
                          "You must keep all loop dimensions." 
		  end
		  grid.set_axis(nm,gphyses[0].axis(nm))
		}
		if ( (vtst=rs.data[0..0,false].val).respond_to?(:set_mask) )
                   # DEVELOPPER'S NOTE (2006/08/15 horinout). 
                   # Here, [0..0,false] is to take the minimum subset,
                   # and respond_to?(:set_mask) is used to check whether
                   # the data array is compatible to NArrayMiss
		  vary = VArray.new(NArrayMiss.new(vtst.typecode, *grid.shape), 
				    rs.data)
		else
		  vary = VArray.new(NArray.new(vtst.typecode, *grid.shape), rs.data)
		end
		results_whole.push( self.new( grid, vary ) )
	      end
	    end
	    for j in 0...results.length
	      rs = results[j]
	      results_whole[j][idx_hash] = rs.data
	    end
	  else
	    to_return = nil
	  end
	end
	return to_return

      end

      def marshal_dump
        [@data.copy, @grid.copy]
      end

      def marshal_load(ary)
        @data = ary[0]
        @grid = ary[1]
      end

      ####### join multiple GPhys objects #######

      def GPhys.join_md_nocheck(gpnary)
        #< check >
        if !gpnary.is_a?(NArray)
          raise(ArgumentError,"Input must be an NArray of GPhys") 
        end
        rank = gpnary.rank

        #< axes >
        gp0 = gpnary[0]

        axes = Array.new
        for d in 0...rank
          if gpnary.shape[d] > 1  # --> join axes
            sel = [0]*d + [true] + [0]*(rank-d-1)   # [0,..0,true,0,...0]
            axs = gpnary[*sel].collect{|gp| gp.axis(d)}   # axes along d-th dim
            ax = Axis.join(axs)
          else
            ax = gp0.axis(d)
          end
          axes.push(ax)
        end

        #< grid >
        grid = Grid.new(*axes)
        # ** Develpment Note (2013-03-02, horinout)**  joining assoc_coords
        # is yet to be supported; not difficult but cumbersome

        #< data >
        data = VArrayComposite.new( gpnary.collect{|gp| gp.data} )

        #< new gphys >
        GPhys.new(grid, data)
      end

      def GPhys.join_md(gpnary)
        #< Check >

        if !gpnary.is_a?(NArray)
          raise(ArgumentError,"Input must be an NArray of GPhys") 
        end
        arank = gpnary.rank      # rank of the input NArray
        ashape = gpnary.shape
        rank = gpnary[0].rank    

        #< Reshape and transpose gpnary if needed >

        #  / find dimmensions to join /
        dimmap = Array.new
        for i in 0...arank
          if ashape[i] > 1   # join needed
            sel = Array.new(arank, 0)   # [0,0,...,0]
            gp0 = gpnary[ *sel ]
            sel[i] = 1
            gp1 = gpnary[ *sel ]   # [0,..,0,1,0,...,0]
            for d in 0...rank
              c0 = gp0.coord(d)
              c1 = gp1.coord(d)
              if UNumeric[c0.val[0], c0.units] != UNumeric[c1.val[0], c0.units]
                dimmap[i] = d   # dimension to join (found)
                break
              end
              raise("Corresponding dim is not found for #{i}") if d==rank-1
            end
          else
            dimmap[i] = nil   # no need to join this dimension
          end
        end
        if (x=dimmap-[nil]).length != x.uniq.length
          raise "Dimensions to join cannot be determined uniquely"
        end

        #  / "solo" dimensions (dimensions no need to join) /
        sdims = (0...rank).collect{|d| d} - dimmap
        for i in 0...arank
          if dimmap[i].nil?
            dimmap[i] = sdims.shift    # assign dimensions orderly to 
                                       # minimize the need to transpose
          end
        end
        sdims.each do |d|
          dimmap.insert(d,d)           # assign dimensions orderly to 
          gpnary = gpnary.newdim(d)    # minimize the need to transpose
        end
        #   now, gpnary.rank == rank

        #  / transpose gpnary if needed /
        if dimmap != (0...rank).collect{|d| d}
          imap = Array.new
          dimmap.each_with_index do |d,j|
            imap[j] = d
          end
          gpnary = gpnary.transpose(*imap)
        end

        #< Sort along dimensions to join >
        gpnary = __sort_gpnary(gpnary)

        #< Join! >
        self.join_md_nocheck(gpnary)
      end

      # Join multiple GPhys objects (not need for any pre-ordering).
      #
      # ARGUMENT
      # * gpnarray [Array (or 1D NArray) of GPhys]
      # 
      def GPhys.join(gpary)

        #< initialization with the first GPhys object >

        gp = gpary[0]
        rank = gp.rank
        gpstore = MDStorage.new(rank)
        gpstore[ *Array.new(rank, 0) ] = gp     # first element
        x0s = (0...rank).collect{|d| 
          pos = gp.axis(d).pos
          x0 = UNumeric[ pos.val[0], pos.units ]
          [ x0 ]   # first values of each coordinate
        }

        #< scan the coordiantes of the remaining GPhys objects >
        for k in 1...gpary.length
          gp = gpary[k]
          idx = Array.new
          for d in 0...rank
            pos = gp.axis(d).pos
            x0 = UNumeric[ pos.val[0], pos.units ]
            i = x0s[d].index(x0)  
            if i.nil?
              x0s[d].push(x0)
              i = x0s[d].length-1
            end
            idx.push(i)
          end
          gpstore[*idx] = gp
        end

        gpnary = gpstore.to_na

        #< Sort along dimensions to join >
        gpnary = __sort_gpnary(gpnary)

        #< Join! >
        self.join_md_nocheck(gpnary)
      end

      def GPhys.concat(gpary, axis_or_ary, name=nil, attr=nil)
        #< interpret gpary (1st arg) >
        gpary = NArray.to_na(gpary) if gpary.is_a?(Array)
        if !gpary.is_a?(NArray) || gpary.rank != 1
          raise(ArgumentError,"1st arg must be a 1D NArray or Array of GPhys")
        end
        len = gpary.length

        #< interpret axis_or_ary (2nd arg) and make an Axis if not >
        case axis_or_ary
        when Axis
          ax = axis_or_ary
          if ax.length != len
            raise(ArgumentError,"length mismatch #{len} vs #{ax.length}")
          end
        else
          ary = axis_or_ary   # must be an NArray or Array
          ary = NArray.to_na(ary).to_f if ary.is_a?(Array)
          if !ary.is_a?(NArray) || ary.rank != 1
            raise(ArgumentError,
              "If not an Axis, 2nd arg must be 1D NArray or Array of float")
          end
          if ary.length != len
            raise(ArgumentError,"length mismatch #{len} vs #{ary.length}")
          end
          if name.nil?
            raise(ArgumentError,
               "3rd arg (name) is needed if the 2nd arg is not an Axis") 
          end
          va = VArray.new(ary, attr, name)
          ax = Axis.new().set_pos(va)
        end

        #< new grid >
        p "#",gpary[0].grid.shape
        grid = gpary[0].grid.insert_axis(-1,ax)  # insert_axis: non-destructive

        #< join VArrays >
        ds = gpary.collect{|gp| gp.data}
        gpary[0].rank.times{ds.newdim!(0)}   # for VArrayComposite.new
        data = VArrayComposite.new(ds)

        #< result >
        GPhys.new(grid, data)
      end

      ############## < private class methods > ##############
      def GPhys::__sort_gpnary(gpnary)
        #< Sort along dimensions to join >

        shape = gpnary.shape
        rank = shape.length
        for d in 0...rank
          n = shape[d]
          if n > 1   # --> d is a dimesnion to join; possibly need to sort
            sel = Array.new(rank, 0)   # [0,0,...,0]
            xs = Array.new   # will be [ [pos, k-th obj, j-th elem], ... ]
            xunits = gpnary[0].axis(d).pos.units
            for k in 0...n
              sel[d] = k
              axis = gpnary[*sel].axis(d)
              if axis.pos.units != xunits
                pos = axis.pos.convert_units(xunits)
                if !axis.cell?
                  axis.set_pos(pos)
                else
                  if axis.cell_center?
                    bds = axis.cell_bounds.convert_units(xunits)
                    axis.set_cell(pos,bds)
                  else
                    ctrs = axis.cell_center.convert_units(xunits)
                    axis.set_cell(ctr,pos)
                  end
                end
              end
              x = axis.pos.val
              for i in 0...x.length
                xs.push( {:pos=>x[i], :kobj=>k, :idx=>i} )
              end
            end

            if ( gpnary[0].axis(d).length == 1 or   # -> cannot determine order
                 xs[0][:pos] <= xs[1][:pos] )       # -> increasing 
              xs.sort!{|a,b| a[:pos] <=> b[:pos]}     # increasing order
            else
              xs.sort!{|a,b| b[:pos] <=> a[:pos]}     # decreasing order
            end

            x0 = xs.shift
            xconf = [ { :kobj=>x0[:kobj], :ids=>[x0[:idx]] } ]
            ic = 0
            xs.each do |x|
              if x[:kobj] == xconf[ic][:kobj]    # same obj
                xconf[ic][:ids].push(x[:idx])
              else    # -> new obj
                ic += 1 
                xconf[ic] = {:kobj=>x[:kobj], :ids=>[x[:idx]] } 
              end
            end
            if xconf.length == n
              # At most, only reodering is needed
              gpnary2 = gpnary.clone       # to replace gpnary
              selj = Array.new(rank, true)   # [true, true,...]
              selk = Array.new(rank, true)   # [true, true,...]
              for j in 0...xconf.length
                if j != (k=xconf[j][:kobj])    # need to reorder the dimension d
                  selj[d] = j
                  selk[d] = k
                  gpnary2[*selj] = gpnary[*selk]
                end
              end
              gpnary = gpnary2  
            else
              # Need to divide some object(s)
              shape2 = shape.clone
              n2 = xconf.length
              shape2[d] = n2
              gpnary2 = NArray.object(*shape2)       # to replace gpnary
              selj = Array.new(rank, true)   # [true, true,...]
              selk = Array.new(rank, true)   # [true, true,...]
              for j in 0...xconf.length
                selj[d] = j
                selk[d] = xconf[j][:kobj]
                ids = xconf[j][:ids] # indices to subset d-th D of gpnary elem
                regular = true
                for b in 0...ids.length-1
                  if ids[b+1] - ids[b+1] != 1
                    regular = false
                    break
                  end
                end
                if regular
                  ids = ids[0]..ids[-1] 
                else
                  #ids = NArray.to_na(ids)
                end
                seld = Array.new(rank, true)   # [true, true,...]
                seld[d] = ids
                gpnary2[*selj] = gpnary[*selk].collect{|g| g[*seld]}
              end
              gpnary = gpnary2
            end
          end

        end
        gpnary
      end
      private_class_method :__sort_gpnary

      ############## < private methods > ##############

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

      def __shape_matching( shs, shl, axnms, axnml )
	 # shs : shape of the shorter
	 # shl : shape of the longer
	 # axnms : axis names of the shorter
	 # axnml : axis names of the longer
	 #
	 # Return value is reshape_args, which is to be used 
	 # as shorter.reshape( *reshape_args )

	 # < matching from the first element >
	 shlc = shl.dup
	 table = Array.new
	 last_idx=-1
	 shs.each do |len|
	    i = shlc.index(len)
	    if !i
	       raise "cannot match shapes #{shs.inspect} and #{shl.inspect}"
	    end
	    idx = i+last_idx+1
	    table.push(idx)
	    (i+1).times{ shlc.shift }
	    last_idx = idx
	 end

	 # < matching from the last element >
	 shlc = shl.dup
	 rtable = Array.new
	 shs.reverse_each do |len|
	    i = shlc.rindex(len)
	    if !i
	       raise "cannot match shapes #{shs.inspect} and #{shl.inspect}"
	    end
	    idx = i
	    rtable.push(idx)
	    (shlc.length-idx).times{ shlc.pop }
	 end
	 rtable.reverse!

	 if table != rtable
	    # < matching ambiguous => try to match by name >

	    real_table = table.dup  # just to start with.
                                    # rtable will be merged in the following

	    shs.each_index do |i|
	       #print axnms[i]," ",axnml[ table[i] ]," ",axnml[ rtable[i] ],"\n"
	       if axnms[i] == axnml[ rtable[i] ]
		  real_table[i] = rtable[i]
	       elsif  axnms[i] != axnml[ table[i] ]
		  raise "Both matchings by orders and by names failed for the #{i}-th axis #{axnms[i]}."
	       end
	    end
	    
	    table = real_table

	 end

	 # < derive the argument for the reshape method >

	 reshape_args = Array.new
	 shl.length.times{ reshape_args.push(1) }
	 for i in 0...table.length
	    reshape_args[ table[i] ] = shs[i]
	 end

	 reshape_args
      end

   end
end


######################################################
## < test >
if $0 == __FILE__
   include NumRu
   vx = VArray.new( NArray.float(10).indgen! + 0.5 ).rename("x")
   vy = VArray.new( NArray.float(6).indgen! ).rename("y")
   xax = Axis.new().set_pos(vx)
   yax = Axis.new(true).set_cell_guess_bounds(vy).set_pos_to_center
   grid = Grid.new(xax, yax)

   z = VArray.new( NArray.float(vx.length, vy.length).indgen! )
   p z.val
   w = VArray.new( NArray.float(vx.length, vy.length).indgen!/10 ) # .random!

   gpz = GPhys.new(grid,z)
   gg = gpz[true,[0,2,1]]
   p '###',gg.val
   p gg[true,1].val
   p gg['y'=>1].val
   gg['y'=>1] = 999
   p gg.val
   p gg.coord(0).val, gg.coord(1).val
   p gg.cut([1.2,3.8],1.1).val

   gpw = GPhys.new(grid,w)
   p '@@@',gpw.average(1).val
   p ( (gpz + gpw).val )

   vz = VArray.new( NArray.float(6).indgen! ).rename("z")
   zax = Axis.new().set_pos(vz)

   grid3 = Grid.new(xax,yax,zax)
   gridz = Grid.new(zax)
   z3 = VArray.new( NArray.float(vx.length, vy.length, vz.length).indgen! )
   q = VArray.new( NArray.float(vz.length).indgen!*100 )
   gpz3 = GPhys.new(grid3,z3)
   gpq = GPhys.new(gridz,q)
   p ( (gpz3 + gpq).val )
   p ( (gpz + gpq).val )
   p ( (gpz3 + gpz).val )

   print "#######\n"
   p gpz.val, gpz[2..5,2..3].val
   gpz[2..5,2..3]=999
   p gpz.val
   p gpz
   p gpz.sort.val

   print "*****\n"
   gpz.each_subary_at_dims(1){|sub|
     p sub.val
   }
   print "===\n"
   gpz_m0=gpz.mean(0)
   p gpz.val, gpz_m0.val, gpz_m0.lost_axes
   p gpz.mean, gpz.max
   p gpz.mean("x").val

   print "transpose\n"
   p gpz3.axnames, gpz3.val, 
     gpz3.transpose(2,0,1).axnames, gpz3.transpose(2,0,1).val

   print "manual cyclic extention\n"
   p(sp=gpz3.shape)
   gpz3_cext = gpz3[ [0...sp[0],0], false ]
   p gpz3_cext.coord(0).val, gpz3_cext.val

   print "cyclic extention if appropriate\n"
   gpz3_cext = gpz3.cyclic_ext(0,10.0)
   p gpz3_cext.coord(0).val, gpz3_cext.val

   print "axis to gphys\n"
   ax = gpz3.axis(1)
   p ax.to_gphys
   p ax.to_gphys( ax.cell_bounds[0..-2].copy )

   print "convert units\n"
   gpz3.units = 'm'
   p gpz3.units
   gpz3k = gpz3.convert_units('km')
   p gpz3k.units, gpz3.val, gpz3k.val

   print "each_along_dims\n"
   p gpz3.mean(0,1).val
   x = GPhys.each_along_dims(gpz3,-1) do |sub|
     p sub.mean       # non-Array return obj of the block --> nil returned
   end
   p x   # must be nil
   gpz3mn, = GPhys.each_along_dims(gpz3,-1) do |sub|
     [ sub.mean(0) ]  # return obj of block is Array -> concat sub GPhys objs
   end
   p gpz3mn.val, gpz3mn.mean(0).val

   # trivial case (with no loop)
   gpz3mn, = GPhys.each_along_dims(gpz3, []) do |sub|
     [ sub.mean(0) ]
   end
   p( (gpz3mn - gpz3.mean(0)).abs.max )

   # test marshaling
   p gpz
   mar = Marshal.dump(gpz)
   p mar.class, mar.length
   g = Marshal.load(mar)
   p g

   # test join
   p "## testing join_md_nocheck..."
   nx = 4
   ny = 3
   nz = 2
   vx0 = VArray.new( NArray.float(nx).indgen! ).rename("x")
   vy0 = VArray.new( NArray.float(ny).indgen! + 0.5 ).rename("y")
   vyb0 = VArray.new( NArray.float(ny+1).indgen! ).rename("yb")
   vx1 = VArray.new( NArray.float(nx).indgen! + nx ).rename("x")
   vy1 = VArray.new( NArray.float(ny).indgen! + (ny+0.5) ).rename("y")
   vyb1 = VArray.new( NArray.float(ny+1).indgen! + ny ).rename("yb")
   xax0 = Axis.new().set_pos(vx0)
   yax0 = Axis.new(true).set_cell(vy0,vyb0).set_pos_to_center
   xax1 = Axis.new().set_pos(vx1)
   yax1 = Axis.new(true).set_cell(vy1,vyb1).set_pos_to_center
   vz = VArray.new( NArray.float(nz).indgen! ).rename("z")
   zax = Axis.new().set_pos(vz)
   v = VArray.new( NArray.float(nx,ny,nz).indgen!, nil, "V" )
   gp00 = GPhys.new( Grid.new(xax0, yax0, zax), v )
   gp10 = GPhys.new( Grid.new(xax1, yax0, zax), v+100 )
   gp01 = GPhys.new( Grid.new(xax0, yax1, zax), v+200 )
   gp11 = GPhys.new( Grid.new(xax1, yax1, zax), v+300 )
   x = NArray.float(nx,ny).random!
=begin
   gp00.set_assoc_coords([GPhys.new(Grid.new(xax0,yax0),VArray.new(x,nil,"A"))])
   gp10.set_assoc_coords([GPhys.new(Grid.new(xax1,yax0),VArray.new(x,nil,"A"))])
   gp01.set_assoc_coords([GPhys.new(Grid.new(xax0,yax1),VArray.new(x,nil,"A"))])
   gp11.set_assoc_coords([GPhys.new(Grid.new(xax1,yax1),VArray.new(x,nil,"A"))])
=end
   gpnary = NArray.to_na( [[ [gp00,gp10], [gp01,gp11] ]] )
   gpu = GPhys.join_md_nocheck(gpnary)
   p "#",gpu, gpu.coord(0).val, gpu.coord(1).val, gpu.axis(1).cell_bounds.val
   p "#",gpu.val

   p "## testing join_md..."
   gpnary = NArray.to_na( [ [gp00,gp01], [gp10,gp11] ] )
   gpu = GPhys.join_md(gpnary)
   p gpu.copy, gpu.val

   gpnary = NArray.to_na( [gp00,gp01] )
   gpu = GPhys.join_md(gpnary)
   p gpu.copy, gpu.val

   gpnary = NArray.to_na( [gp10,gp00] )
   gpu = GPhys.join_md(gpnary)
   p gpu.copy, gpu.val

   gp00.coord(0)[0..1] = NArray.to_na([1, 2])
   gp00.coord(0)[2..3] = NArray.to_na([7, 8])
   gp10.coord(0)[0..3] = NArray.to_na([3,4,5,6])
   gpnary = NArray.to_na( [gp00,gp10] )
   gpu = GPhys.join_md(gpnary)
   p gpu.copy, gpu.val

   ans = NArray.to_na( 
      [ [ [ 0.0, 1.0, 100.0, 101.0, 102.0, 103.0, 2.0, 3.0 ], 
          [ 4.0, 5.0, 104.0, 105.0, 106.0, 107.0, 6.0, 7.0 ], 
          [ 8.0, 9.0, 108.0, 109.0, 110.0, 111.0, 10.0, 11.0 ] ], 
        [ [ 12.0, 13.0, 112.0, 113.0, 114.0, 115.0, 14.0, 15.0 ], 
          [ 16.0, 17.0, 116.0, 117.0, 118.0, 119.0, 18.0, 19.0 ], 
          [ 20.0, 21.0, 120.0, 121.0, 122.0, 123.0, 22.0, 23.0 ] ] ] )
   if gpu.val == ans
     p "test ok" 
   else
     raise "test failed" 
   end 

   p "## testing join..."
   gpu = GPhys.join( [gp11,gp10,gp01,gp00] )
   p gpu.copy, gpu.val
   if gpu.val[true,0..2,true] == ans and gpu.val[true,3..5,true] == ans+200
     p "test ok" 
   else
     raise "test failed" 
   end 

   p "## testing concat..."
   gpary = [gp00[0..2,0..1,0], gp00[0..2,0..1,0]+100]
   gpu = GPhys.concat( gpary, [0.0, 1.0], "time", {"units"=>"days"} )
   ans = NArray.to_na( [ [ [ 0.0, 1.0, 2.0 ],
                           [ 4.0, 5.0, 6.0 ] ],
                         [ [ 100.0, 101.0, 102.0 ],
                           [ 104.0, 105.0, 106.0 ] ] ] )
   if gpu.coord(2).name == "time" && gpu.val == ans
     p "test ok" 
   else
     raise "test failed" 
   end 

end

