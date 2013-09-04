require "numru/gphys/varray"
require "numru/gphys/varraynetcdf"
require "numru/gphys/varraycomposite"
require "date"

=begin
=class NumRu::Axis

A class of to handle a descretized physical coordinate.

==Overview

An NumRu::Axis object is meant to represent a dimension in a NumRu::Grid 
object, which is used in NumRu::Grid (Hereafter, NumRu:: is omitted). 
An Axis has 1-dimensional data on grid-point posisions as a VArray.
In addition, it can have supplementary data (as VArray objects).

Three types of axes are supported in this class:

  1. Simple (mostly point-sampled) axes
  2. Cell-type axes. In this case, grid points are either
     at cell boundaries or within the cells (oftern at the center).
  3. Simple ("bare") indexing (without particular physical meaning)

In most applications, the 1st type would be enough, but
the 2nd type would be useful for some type of numerical 
simulation. The 3rd is not physical and may not be considered as
"axes", but this could be convenient for some practical applications.

==Class Methods
---Axis.new(cell=false,bare_index=false,name=nil)
    Constructor. The first two arguments are to specify one of the
    types explained above.

    ARGUMENTS
    * cell (true or false)
    * bare_index (true or false)
    * name (String or nil): the default name (when nil) is "noname"

    RETURN VALUE
    * an Axis

---Axis.defined_operations
    Returns the name of the methods defined in Axis to do
    some operation along the axis.

    RETURN VALUE
    * an Array of String. Current default value is ["integrate","average"].

---Axis.humane_messaging = t_or_f
    If false is given, the [] method is changed to return a naive 
    straightforward message if the axis is lost. -- By default,
    it returns a fancy but sometimes unwanted message if the 
    axis is the time with since field in the form of yyyy-mm-dd....    

==Instance Methods
---name=(nm)
    Set a name.

    ARGUMENTS
    * name (String)

    RETURN VALUE
    * name (the argument)
---name
    Returns the name.

    RETURN VALUE
    * a String

---cell?
    Whether or not self is a cell-type axis.

    RETURN VALUE
    * true or false

---cell_center?
    Whether or not self represents data points within the cells (which is
    often, but not necessarily, the centers of the cells).

    RETURN VALUE
    * true, false, or nil (when the axis is not cell-type)

---cell_bounds?
    Whether or not self represents data points at the cell bondaries.

    RETURN VALUE
    * true, false, or nil (when the axis is not cell-type)

---bare_index?
    Whether or not self is of the bare-index type.

    RETURN VALUE
    * true or false.

---flatten
    Returns the VArray objects in self as a flat Array. No cloning is made.

    RETURN VALUE
    * an Array of VArray objects.

---each_varray
    Iterator for each VArray object in self (dependent on ((<flatten>)).

    RETURN VALUE
    * an Array of VArray objects (same as ((<flatten>))).

---copy
    Make a deep clone onto memory.
    All the VArray objects in the return value will be
    of the root class of VArray.
 
    RETURN VALUE
    * an Axis

---collect

    This method is like ((<copy>)), but it is the 'collect' 
    iterator for each VArray in self (block required).

    RETURN VALUE
    * an Axis

---pos=(pos)
    Sets the grid-point positions (disretized coordinate values).

    ARGUMENTS
    * pos (a 1D VArray)

    RETURN VALUE
    * pos (the argument)

---set_pos(pos)
    Sets the grid-point positions (disretized coordinate values).

    ARGUMENTS
    * pos (a 1D VArray)

    RETURN VALUE
    * self

---pos
    Returns the grid-point positions (disretized coordinate values).

    RETURN VALUE
    * a VArray (no duplication is made)

---cell_center

    When cell-type, returns the positions of grid points at cell centers.

    RETURN VALUE
    * a VArray (no duplication is made)

---cell_bounds

    When cell-type, returns the positions of grid points at cell boundaries.

    RETURN VALUE
    * a VArray (no duplication is made)

---length
    Returns the length of the axis.

    RETURN VALUE
    * an Integer

---set_cell(center, bounds, name=nil)
    Set up cell-type axis, by giving both the cell centers and boundaries.
    Completion of the set up is deferred until one of ((<set_pos_to_center>))
    and ((<set_pos_to_bounds>)) is called.

    ARGUMENTS
    * center (a 1D VArray)
    * bounds (a 1D VArray)
    * name (String)

    RETURN VALUE
    * self

---set_cell_guess_bounds(center, name=nil)
    Set up cell-type axis, by specifing only the cell centers
    and deriving bounds with a naive assumption.

    ARGUMENTS
    * center (a 1D VArray)
    * name (String)

    RETURN VALUE
    * self

---set_pos_to_center
    Set the position of the current axis to the centers of the cells.
    This or ((<set_pos_to_bounds>)) is needed to complete the set up
    with set_cell_* methods.

---set_pos_to_bounds
    Set the position of the current axis to the cell bondaries.
    This or ((<set_pos_to_center>)) is needed to complete the set up
    with set_cell_* methods.

---set_aux(name,vary)
    Set auxiliary data

    ARGUMENTS
    * name (String) a tag to express the kind of the data
    * vary (a VArray) the data

    RETURN VALUE
    * vary (the 2nd argument)

---get_aux(name)

    Returns auxiliary data

    ARGUMENTS
    * name (String) a tag to express the kind of the data (see ((<set_aux>))).

    RETURN VALUE
    * a VArray

---aux_names
    Returns a list of the names of auxiliary data

    RETURN VALUE
    * an Array of String

---to_gphys(datavary1d=nil)
    To construct a GPhys object from an Axis.

    ARGUMENTS
    * datavary1d (nil or VArray) :
      If nil, the position object of self becomes the main data object.
      If a VArray, it is used as the main data object.

    RETURN VALUE
    * a GPhys

---[] (slicer)
    Returns a subset. Its specification is the same as in NArray.

    RETURN VALUE
    * an Axis

---cut(coord_cutter)
    Similar to ((<[]>)), but is based on the physical coordinate.

    RETURN VALUE
    * an Axis

---cut_rank_conserving(coord_cutter)
    Similar to ((<cut>)), but is always rank-conserving. That is,
    a subset specification like [i] is treated as [i..i]

    RETURN VALUE
    * an Axis

---integrate(ary,dim)
    Does integration along the axis

    ARGUMENTS
    * ary (NArray or NArray-like multi-dimensional data class) 
      the data, whose dim-th dimension must have the same length as the axis.
    * dim (Integer) : The dimension of ary, to which the operation is applied.

    RETURN VALUE
    * an obejct with the same class as ary, or of a Numeric 
      class if ary is 1D.

---integ_weight
    Returns the integration weight (whose default is nil).

---integ_weight=(wgt)
    Sets the integration weight (whose default is nil).

---average(ary,dim)
    Similar to ((<integrate>)), but does averaging

    ARGUMENTS
    * see ((<integrate>))

    RETURN VALUE
    * see ((<integrate>))

---average_weight
    Returns the integration weight (whose default is nil).

---average_weight=(wgt)
    Sets the integration weight (whose default is nil).

---draw_positive
    Returns the direction to plot the axis, which relies on the 
    VArray#axis_draw_positive method.

    RETURN VALUE
    * one of the following:
      * true: axis should be drawn in the increasing order (to right/upward)
      * false: axis should be drawn in the decreasing order
      * nil: not specified

---cyclic?
    Returns whether the axis is cyclic.
    (Relies on the VArray#axis_cyclic? method.)
    
    RETURN VALUE
    * one of the following:
      * true: cyclic
      * false: not cyclic
      * nil: not specified

---modulo
    Returns the modulo of a cyclic axis 
    (Relies on the VArray#axis_modulo method.)
    
    RETURN VALUE
    * one of the following:
      * Float if the modulo is defined
      * nil if modulo is not found

=end

module NumRu

   class Axis

      @@humane_message = true  # if true, [] returns a humane message when the
                               # axis is lost. if false, it returns a naive one
      def self.humane_message=(t_or_f)
	@@humane_message = t_or_f
      end

      @@strftime_fmt = nil  # nil, or String to explicitly specify the format
                            # for strftime used in []
      def self.strftime_fmt=(fmt)
        @@strftime_fmt = fmt
      end
      def self.strftime_fmt
        @@strftime_fmt
      end

      def initialize(cell=false,bare_index=false,name=nil)
	 @init_fin = false         # true/false (true if initializatn finished)
	 @name = name              # String
	 @pos = nil                # VArray (to set it can be deferred if
                                   # @cell to support mother axes)
	 @cell = cell              # true/false
	 @cell_center = nil        # VArray (defined if @cell)
         @cell_bounds = nil        # VArray (defined if @cell)
         @bare_index = bare_index  # true/false(if true @cell is meaningless)
         @aux = nil                # Hash of VArray (auxiliary quantities)
      end

      def inspect
	 "<axis pos=#{@pos.inspect}>"
      end

      def name=(nm)
	 @name=nm
      end
      def name
	 @name || "noname"
      end

      def cell?
	 @cell
      end
      def cell_center?
	 @cell && @pos.equal?(@cell_center)
      end
      def cell_bounds?
	 @cell && @pos.equal?(@cell_bounds)
      end
      def bare_index?
	 @bare_index
      end

      def flatten
	 # return VArrays contained in a flat array
	 out = Array.new
	 out.push(@pos) if @pos
	 out.push(@cell_center) if @cell_center && !cell_center?
	 out.push(@cell_bounds) if @cell_bounds && !cell_bounds?
	 if @aux
	    @aux.each{|k,v|
	       out.push(v)
	    }
	 end
	 out
      end

      def each_varray
	self.flatten.each{|x| yield x}
      end

      def copy
	 # deep clone onto memory
	 out = Axis.new(cell?, bare_index?, name)
	 if cell?
	    out.set_cell( @cell_center.copy, @cell_bounds.copy )
	    if cell_center?
	       out.set_pos_to_center
	    elsif cell_bounds?
	       out.set_pos_to_bounds
	    end
	 else
	    out.set_pos( @pos.copy )
	 end
	 if @aux
	    @aux.each{|k,v|
	       out.set_aux(k, v.copy)
	    }
	 end
	 out
      end

      def collect
	 # This method is like ((<copy>)), but it is the 'collect' 
         # iterator for each VArray in self (block required).
	 out = Axis.new(cell?, bare_index?, name)
	 if cell?
	    out.set_cell( yield(@cell_center), yield(@cell_bounds) )
	    if cell_center?
	       out.set_pos_to_center
	    elsif cell_bounds?
	       out.set_pos_to_bounds
	    end
	 else
	    out.set_pos( yield(@pos) )
	 end
	 if @aux
	    @aux.each{|k,v|
	       out.set_aux(k, yield(v))
	    }
	 end
	 out
      end

      def pos=(pos)
	 if !@cell
	    if ! pos.is_a?(VArray)
	       raise ArgumentError,"arg not a VArray: #{pos.class}"  
	    end
	    if pos.rank != 1
	      raise ArgumentError,"rank of #{pos.name} (#{pos.rank}) is not 1" 
	    end

	    @pos=pos
	    @init_fin = true
	    if ! @name
	       @name = pos.name
	    end
	 else
	    raise "This method is not available for a cell axis. "+
	          "Use set_pos_to_center or set_pos_to_bounds instead."
	 end
	 pos
      end

      def set_pos(pos)
	 self.pos= pos
	 @name = pos.name
	 self
      end

      def pos
	 raise "pos has not been set" if !@pos
	 @pos
      end
      def cell_center
	 @cell_center
      end
      def cell_bounds
	 @cell_bounds
      end

      def length
	 if @pos
	    @pos.length
	 else
	    raise "length is not determined until pos is set"
	 end
      end

      def set_cell(center, bounds, name=nil)
	 # it is the user's obligation to ensure that center and bounds
         # have the same units etc.

	 # < error check >

	 if ! @cell; raise "method not available for a non-cell axis"; end

	 if ! center.is_a?(VArray)
	    raise ArgumentError,"1st arg not a VArray: #{center.class}"  
	 end
	 if center.rank != 1
	    raise ArgumentError,"center: rank of #{center.name} (#{center.rank}) is not 1" 
	 end

	 if ! bounds.is_a?(VArray)
	    raise ArgumentError,"2nd arg not a VArray: #{bounds.class}"  
	 end
	 if bounds.rank != 1
	    raise ArgumentError,"bounds: rank of #{bounds.name} (#{bounds.rank}) is not 1" 
	 end

	 if( center.length != bounds.length-1 )
	    raise "center.length != bounds.length-1"
	 end

	 # < do the job >

	 @cell_center = center
	 @cell_bounds = bounds
	 if name
	    @name=name
	 end
	 @init_fin = true       # To set @pos is deferred at this moment.
                                # use set_pos_to_(bounds|center) to make 
                                # the object fully available
         self
      end

      def set_aux(name,vary)
	 if !name.is_a?(String) 
	    raise ArgumentError,"1nd arg: not a String"
	 end

	 if ! vary.is_a?(VArray)
	    raise ArgumentError,"2nd arg not a VArray: #{vary.class}"  
	 end
	 if vary.rank != 1
	    raise ArgumentError,"rank of #{vary.name} (#{vary.rank}) is not 1" 
	 end

	 if !@aux; @aux = Hash.new; end

	 @aux[name] = vary
	 self
      end
      def get_aux(name)
	 @aux[name]
      end
      def aux_names
	 @aux ? @aux.keys : []
      end

      def to_gphys(datavary1d=nil)
	# To form a 1-dimensional GPhys
	# (Dependent on GPhys&Grid, unlike other methods Axis,
        # so the test program is in gphys.rb)
	# Arguments
	#   * datavary1d (nil or VArray): 1D VArray with the same
        #     size as the axis. If omitted, @pos (coordinate variable
        #     of the variable) is used.
	if !datavary1d
	  datavary1d = @pos.copy
	else
	  if datavary1d.rank != 1 || datavary1d.length != length
	      raise ArgumentError, "Must be 1D and same size"
	  end
	end
	GPhys.new( Grid.new(self), datavary1d )
      end

      def [] (slicer)
	 if ! @pos
	    raise "pos has not been set. Forgot set_pos_to_(center|bounds)?"
	 end

	 case slicer
	 when Fixnum
	    pos=@pos[slicer]
	    cval = ( pos.val.is_a?(Numeric) ? pos.val : pos.val[0] )
	    units = pos.get_att('units')
	    info_lost = false
	    if @@humane_message
	      if units && /(.*) *since *(.*)/ =~ units  
		stun = $1
		tun = Units[stun]
		since = DateTime.parse($2)
		if Units[units] =~ Units['days since 1-1-1'] # s,hour,day,..
		  sec = tun.convert( cval, Units['seconds'] ).round + 1e-1
			 # ^ take "round" to avoid round error in sec
			 # (Note that %S below takes floor of seconds).
		  datetime = since + (sec/86400.0)
		  info_lost = datetime.strftime(@@strftime_fmt || '%Y-%m-%d %H:%M:%S%z')
		  info_lost_set = true
		elsif Units[units] =~ Units['months since 1-1-1'] # year,month,pentad,..
		  monun = Units['months']
		  if /mon/ =~ stun || /year/ =~ stun
		    datetime = since >> tun.convert( cval, monun ).round
		    info_lost = datetime.strftime(@@strftime_fmt || '%Y-%m')
		  else  # maybe pentad
		    datetime = since >> tun.convert( cval, monun )
		    info_lost = datetime.strftime(@@strftime_fmt || '%Y-%m-%d')
		  end
		  info_lost_set = true
		end
	      end
	    end
	    if !info_lost_set
	      sval = sprintf("%g",cval)
	      info_lost = "#{self.name}=#{sval}"
	      if (units)   # substitution
		info_lost += " "+units
	      end
	    end
	    return info_lost
	 when Range, true
	    # re-organize the range to support slicing of variables
	    # with a 1 larger / smaller length.
	    if true===slicer
	       range=0..-1
	    else
	       range = slicer
	    end
	    first = range.first
	    last = range.exclude_end? ? range.last-1 : range.last
	    if first < 0
	       first += self.length  # first will be counted from the beginning
	    end
	    if last >= 0
	       last -= self.length   # last will be counted from the end
	    end
	    slicer = first..last
	    newax=Axis.new(@cell,@bare_index)
	 when Hash
	    range = slicer.keys[0]
	    step = slicer[range]
	    range = 0..-1 if range==true
	    first = range.first
	    last = range.exclude_end? ? range.last-1 : range.last
	    if first < 0
	       first += self.length  # first will be counted from the beginning
	    end
	    if last >= 0
	       last -= self.length   # last will be counted from the end
	    end
	    slicer = { (first..last) => step }
	    newax=Axis.new(false,@bare_index)  # always not a cell axis
         when NArray, Array
	    newax=Axis.new(false,@bare_index)  # always not a cell axis
	 else
	    raise ArgumentError, "Axis slicing with #{slicer.inspect} is not available"
	 end

	 if newax.bare_index? || !newax.cell?
	    pos=@pos[slicer]
	    newax.set_pos( pos )
	 elsif newax.cell?
	    center=@cell_center[slicer]
	    bounds=@cell_bounds[slicer]
	    newax.set_cell( center, bounds )
	    if self.cell_center?
	       newax.set_pos_to_center
	    elsif self.cell_bounds?
	       newax.set_pos_to_bounds
	    end
	 end
	 if @aux
	    @aux.each{ |name, vary|
#	       if (aux=vary[slicer]).rank != 0
		  newax.set_aux(name, vary[slicer])
#	       else
#		  print "WARNING #{__FILE__}:#{__LINE__} auxiliary VArray #{name} is eliminated\n"
#	       end
	    }
	 end
	 newax
      end

      def cut(coord_cutter)
	_cut_(false, coord_cutter)
      end
      def cut_rank_conserving(coord_cutter)
	_cut_(true, coord_cutter)
      end

      def _cut_(conserve_rank, coord_cutter)

	# assume that the coordinates are monotonic (without checking)

	slicer = Array.new
	ax = self.pos.val

        units = self.pos.get_att('units')

	case coord_cutter
	when true
	  slicer=true
	when Range
	  # find the grid points included in the range
	  range = coord_cutter
	  range_ary = [range.first, range.last]
	  xmin = range_ary.min
	  xmax = range_ary.max
          xmin = UNumeric.from_date(xmin,units).val if xmin.class <= Date
          xmax = UNumeric.from_date(xmax,units).val if xmax.class <= Date
	  wh = ( (ax >= xmin) & (ax <= xmax) ).where
	  if wh.length == 0
	    raise "Range #{range} does not include any grid point in the axis '#{name}'"
	  end
	  idmin = wh.min
	  idmax = wh.max
	  slicer=idmin..idmax
	when Numeric, Date, DateTime
	  # find the nearst point
	  pt = coord_cutter       
          pt = UNumeric.from_date(pt,units).val if pt.class <= Date
	  dx = (ax-pt).abs
	  minloc = _minloc_(dx)
	  if conserve_rank
	    slicer=minloc..minloc
	  else
	    slicer=minloc
	  end
	when Array, NArray
	  # find the nearst points
	  ary = coord_cutter
	  slicer = ary.collect{ |pt|
            pt = UNumeric.from_date(pt,units).val if pt.class <= Date
	    dx = (ax-pt).abs
	    minloc = _minloc_(dx)
	  }
	else
	  raise TypeError, "(#{coord_cutter.inspect}) is not accepted as a coordinate selector"
	end

	[ self[slicer], slicer ]
      end
      private :_cut_

      def _minloc_(a)  # private to be used in _cut_ 
        # Developper's MEMO: Such a method should be supported in NArray
        minloc = 0  # initialization
        for i in 0...(a.length-1)   # here, do not assume monotonic
	  minloc = i+1 if a[i+1]<a[i]
	end
	minloc
      end
      private :_minloc_

      def set_cell_guess_bounds(center, name=nil)
	 # derive bounds with a naive assumption (should be OK for
	 # an equally separated axis).
	 if ! center.is_a?(VArray) || center.rank != 1
	    raise ArgumentError, "1st arg: not a VArray, or its rank != 1" 
	 end
	 vc = center.val
	 vb = NArray.float( vc.length + 1 )
	 vb[0] = vc[0] - (vc[1]-vc[0])/2   # Assume this!!
	 for i in 1...vb.length
	    vb[i] = 2*vc[i-1] - vb[i-1]    # from vc[i-1] = (vb[i-1]+vb[i])/2
	 end
	 bounds = VArray.new(vb, center)  # borrow attributes from center
	 set_cell(center, bounds, name)
      end

      def set_pos_to_center
	 raise "The method is not available for a non-cell axis" if ! @cell
	 @pos = @cell_center
	 if !@name
	    @name = @cell_center.name
	 end
	 self
      end

      def set_pos_to_bounds
	 raise "The method is not available for a non-cell axis" if ! @cell
	 @pos = @cell_bounds
	 if !@name
	    @name = @cell_bounds.name
	 end
	 self
      end

      def Axis.defined_operations
	 @@operations
      end

      @@operations = ["integrate","average"]

      def integrate(ary,dim)
	 if !@integ_weight; _set_default_integ_weight; end
	 sh = (0...ary.rank).collect{|i| (i==dim) ? @integ_weight.length : 1 }
	 mn = sprintf("%g", ( UNumeric===(a=@pos.min) ? a.val : a) )
         mx = sprintf("%g", ( UNumeric===(a=@pos.max) ? a.val : a) )
	 return [ ( ary * @integ_weight.reshape(*sh) ).sum(dim), 
	          "integrated  "+@name+":#{mn}..#{mx}" ]
      end

      def integ_weight; @integ_weight; end
      def integ_weight=(wgt); @integ_weight=wgt; end

      def average(ary,dim)
	 if !@avg_weight; _set_default_avg_weight; end
	 sh = (0...ary.rank).collect{|i| (i==dim) ? @avg_weight.length : 1 }
	 mn = sprintf("%g", ( UNumeric===(a=@pos.min) ? a.val : a) )
         mx = sprintf("%g", ( UNumeric===(a=@pos.max) ? a.val : a) )
	 return [ ( ary * @avg_weight.reshape(*sh) ).sum(dim), 
	          "averaged  "+@name+":#{mn}..#{mx}" ]
      end

      def average_weight; @avg_weight; end
      def average_weight=(wgt); @avg_weight=wgt; end

      def draw_positive
	# Returns the direction to plot the axis
	# * true: axis should be drawn in the increasing order(to right/upward)
	# * false: axis should be drawn in the decreasing order
	# * nil: not specified (VArray's default if not overridden in 
        #   subclasses)
	@pos.axis_draw_positive
      end

      def cyclic?
	@pos.axis_cyclic?
      end

      def modulo
	@pos.axis_modulo
      end

      #########  private methods ####################################

      private

      def _set_default_integ_weight

	 raise "Initialization is not completed" if ! @init_fin
	 if ! @pos
	    raise "pos has not been set. Call set_pos_to_(center|bounds)." 
	 end

	 # < define numerical integration / averaging >

	 ## 2005/09/12 DEVLOPMENT MEMO by horinout
	 ## cyclic でちょうど１グリッド伸ばしたら modulo に達する場合
	 ## 点サンプルやセル中央タイプでもサイクリック用重みをつける
         ## ようにしたい．

	 if( @bare_index )
	    @integ_weight = NArray.int(@pos.length).fill!(1)
	    #dist = weight.length
	 elsif ( !@cell || (@cell && @pos.equal?(@cell_bounds)) )
	    # --- use trapezoidal formula ---
	    posv = @pos.val
	    if posv.length == 1
	       raise "cannot define the default integration when length==1 and non-cell"
	    end
	    #dist = (posv[-1]-posv[0]).abs
	    @integ_weight = posv.dup
	    @integ_weight[0] = (posv[1]-posv[0]).abs/2
	    @integ_weight[-1] = (posv[-1]-posv[-2]).abs/2
	    @integ_weight[1..-2] = (posv[2..-1] - posv[0..-3]).abs/2
	 else
	    # --- assume that the center values represents the averages ---
	    bd = @cell_bounds.val
	    @integ_weight = (bd[1..-1] - bd[0..-2]).abs
	    #dist = (bd[-1]-bd[0]).abs
	 end

      end

      def _set_default_avg_weight

	 raise "Initialization is not completed" if ! @init_fin
	 if ! @pos
	    raise "pos has not been set. Call set_pos_to_(center|bounds)." 
	 end

	 # < define numerical integration / averaging >

	 if( @bare_index )
	    @avg_weight = NArray.int(@pos.length).fill!(1)
	    dist = @avg_weight.length
	    @avg_weight /= dist
	 elsif ( !@cell || (@cell && @pos.equal?(@cell_bounds)) )
	    # --- use trapezoidal formula ---
	    posv = @pos.val
	    if posv.length == 1
	       @avg_weight = NArray[1]
            else
	       dist = (posv[-1]-posv[0]).abs
	       @avg_weight = posv.dup
	       @avg_weight[0] = (posv[1]-posv[0]).abs/2
	       @avg_weight[-1] = (posv[-1]-posv[-2]).abs/2
	       @avg_weight[1..-2] = (posv[2..-1] - posv[0..-3]).abs/2
	       @avg_weight /= dist
	    end
	 else
	    # --- assume that the center values represents the averages ---
	    bd = @cell_bounds.val
	    @avg_weight = (bd[1..-1] - bd[0..-2]).abs
	    dist = (bd[-1]-bd[0]).abs
	    @avg_weight /= dist
	 end

      end

      #######

   end
end

###################################################
## < test >

if $0 == __FILE__
   include NumRu
   xc = VArray.new( NArray.float(10).indgen! + 0.5 ).rename("x")
   xb = VArray.new( NArray.float(11).indgen! ).rename("xb")
   axpt = Axis.new().set_pos(xc)
   axcel = Axis.new(true).set_cell(xc,xb)
   axcel_c = axcel.dup.set_pos_to_center
   axcel_b = axcel.dup.set_pos_to_bounds
   axcel2 = Axis.new(true).set_cell_guess_bounds(xc)
   p "axcel",axcel, "axcel2",axcel2
   print "########\n"
   p axpt.pos.val
   p axcel_c.pos.val
   p axcel_b.pos.val
   z = VArray.new( NArray.float(xc.length, 2).random! )
   w = VArray.new( NArray.float(xc.length).indgen! )
   w2 = VArray.new( NArray.float(xb.length).indgen!-0.5 )
   p z.val
   p axpt.average(z,0), axcel_c.average(z,0)
   p z.sum(0)/10
   print "### avg/integ ###\n"
   p  axpt.average(w,0), axcel_c.average(w,0), 
      axpt.integrate(w,0), axcel_c.integrate(w,0), 
      axcel_b.integrate(w2,0)
   axpt.integ_weight = NArray.sfloat(axpt.length).fill!(0.5)
   p  'with artificial integ_weight:', axpt.integrate(w,0)
   # axcel.set_default_algorithms  # this is to fail
   print "////////\n"
   p axpt[1..3].pos.val
   p axcel_c[1..3].cell_center.val, axcel_c[1..3].cell_bounds.val
   p axcel_b[1..3].cell_center.val, axcel_b[1..3].cell_bounds.val
   p axpt[1]
   p axcel_b[5]
   p axcel_b.cut(4.3)
   axcut, slicer = axcel_c.cut(3.0..7.0)
   p axcut.copy, slicer
   p axcel_b.cut([3.2, 2.5, 6.9])
   p axpt
   axcel_c.set_aux('aux1',xc*4)
   p axcel_c.flatten
   p axcel_c.copy.flatten
   print "##\n"
   p axcel_c.each_varray{|va| p va}
   axcl = axcel_c.collect{|va| va*2}
   print "###\n"
   p axcl.class, axcl.each_varray{|va| p va}

   axpt.pos.set_att("units","days since 2001-01-01")
   p axpt.cut(DateTime.new(2001,1,4,12,0))
end
