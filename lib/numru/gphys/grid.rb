require "numru/gphys/axis"
require "numru/gphys/assoccoords"

=begin
=class NumRU::Grid

A class to handle discretized grids of physical quantities.

==Class Methods
---Grid.new( *axes )
    Constructor.

    RETURN VALUE
    * a Grid

==Instance Methods
---axnames
    Returns the names of the axes

    RETURN VALUE
    * an Array of String

---lost_axes
    Returns info on axes eliminated during operations.

    Useful for annotation in plots, for example (See the code of GGraph
    for an application).

    RETURN VALUE
    * an Array of String

---axis(dim_or_dimname)
    Returns an Axis

    ARGUMENTS
    * dim_or_dimname (String or Integer) to specify an axis.

    RETURN VALUE
    * an Axis

---dim_index(dimname)
    Returns the integer id (count from zero) of the dimension

    ARGUMENT
    * dimname (String or Integer) : this method is trivial if is is an integer

    RETURN VALUE
    * an Integer

---coord_dim_indices(coordname)
    Coordinate name --> dimension indices.

    ARGUMENT
    * coordname (String) : Name of a coordinate

    RETURN VALUE
    * Array of Integer or nil --
      If the coordinate is present it is an Array 
      containing dimension indices (If the coordinate is 1D, 
      the lengthof the array is 1.)

---set_axis(dim_or_dimname,ax)

    Sets an axis.

    ARGUMENTS
    * dim_or_dimname (String or Integer) to specify an axis.
    * ax (Axis) the axis

    RETURN VALUE
    * self

---set_lost_axes( lost )

    Sets info on axes eliminated.

    RETURN VALUE
    * self

---add_lost_axes( lost )

    Adds info on axes eliminated to existing ones.

    RETURN VALUE
    * self

---delete_axes( at, deleted_by=nil )

    Delete an axis.

    ARGUMENTS
    * at (String or Integer) to specify an axis.
    * deleted_by (String or nil) if non-nil, it is written in
      the internal lost-axis info. Best if you put the name of the
      method, in which this method is called.

    RETURN VALUE
    * a Grid

---copy
    Makes a deep clone onto memory.

    RETURN VALUE
    * a Grid

---merge(other)
    merge two grids by basically using copies of self's axes but
    using the other's if the length in self is 1 and 
    the length in the other is longer

    ARGUMENTS
    * other (Grid)

    RETURN VALUE
    * a Grid

---shape
    Returns the shape of self.

    RETURN VALUE
    * an Array of Integer

---[] (*slicer)
    Returns a subset.

    ARGUMENTS
    * Same as those for NArray#[], NetCDFVar#[], etc.

    RETURN VALUE
    * a Grid

---cut(*args)
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
    * an Array : [a Grid, slicer], where slicer is an array
      to be used to make a subset of an corresponding varray
      (to be used in GPhys#cut).
   
---cut_rank_conserving(*args)
    Similar to ((<cut>)), but the rank is conserved by not eliminating
    any dimension (whose length could be one).

---cut_assoccoord(hasharg)
    Cut with respect to the asscoated coordinates. Similar to cut,
    when the argeuemnt is a Hash, but hash keys are the names of the 
    asscoated coordinates.

#---exclude(dim_or_dimname)
#    Returns a Grid in which an axis is eliminated from self.
#
#    ARGUMENTS
#    * dim_or_dimname (String or Integer) to specify an axis.
#
#    RETURN VALUE
#    * a Grid
#
---change_axis(dim, axis)
    Replaces an axis. (Returns a new object)

    ARGUMENTS
    * dim_or_dimname (String or Integer) to specify an axis.
    * axis (Axis)

    RETURN VALUE
    * a Grid
#
#---change_axis!(dim_or_dimname, axis)
#    Replaces an axis. (overwrites self)
#
#    ARGUMENTS
#    * dim_or_dimname (String or Integer) to specify an axis.
#    * axis (Axis)
#
#    RETURN VALUE
#    * self
#
---insert_axis(dim, axis)
    Inserts an axis. (non destructive; returns a new object)

    ARGUMENTS
    * dim (Integer) to specify the position to insert
    * axis (Axis)

    RETURN VALUE
    * a Grid

#---insert_axis!(dim_or_dimname, axis)
#    Inserts an axis. (overwrites self)
#
#    ARGUMENTS
#    * dim_or_dimname (String or Integer) to specify an axis.
#    * axis (Axis)
#
#    RETURN VALUE
#    * self

---transpose( *dims )
    Transpose.

    ARGUMENTS
    * dims (integers) : for example, [1,0] to transpose a 2D object.
      For 3D objects, [1,0,2], [2,1,0], etc.etc.

    RETURN VALUE
    * a Grid

=end

module NumRu

   class Grid

      def initialize( *axes )
	 @axes = Array.new
	 axes.each{|ag|
            ### commented out for the duck typing:
            #if ag.is_a?(Axis)
            @axes.push(ag)
            #else
            #   raise ArgumentError, "each argument must be an Axis"
	    #end
	 }
	 @lost_axes = Array.new   # Array of String
	 @rank = @axes.length
	 @axnames = Array.new
	 __check_and_set_axnames
         @assoc_coords = nil
      end

      # * assoc_crds : an Array of GPhys
      # 
      def set_assoc_coords(assoc_crds)
        @assoc_coords = AssocCoords.new(assoc_crds, @axnames)
        @assoc_coords.axlens.each do |nm,l|
          if l && l != (l0 = shape[dim_index(nm)])
            raise ArgumentError, "Length mismatch in coord #{nm} (#{l0}) and assoc_crds (#{l}). You may need to regrid (use GPhys#regrid method) associated coordinate(s) in advance."
          end
        end
        self
      end

      # * assoc_coords : an AssocCoords
      # 
      def assoc_coords=(assoc_coords)
        @assoc_coords = assoc_coords 
      end

      def assoc_coords
        @assoc_coords
      end

      def inspect
        "<#{rank}D grid #{@axes.collect{|ax| ax.inspect}.join("\n\t")}#{@assoc_coords ? "\n"+@assoc_coords.inspect.gsub(/^/,"\t") : ''}>"
      end

      def __check_and_set_axnames
	 @axnames.clear
	 @axes.each{|ax| 
	    nm=ax.name
	    if @axnames.include?(nm)
	       raise "Two or more axes share a name: #{nm}"
	    end
	    @axnames.push(nm)
	 }
      end
      private :__check_and_set_axnames

      attr_reader :rank

      def axnames
	@axnames.dup
      end
      def lost_axes
	@lost_axes.dup
      end

      def coordnames
        ret = axnames
        ret.concat(@assoc_coords.coordnames) if @assoc_coords
        ret
      end

      def has_axis?(name)
	@axnames.include?(name)
      end

      def has_assoccoord?(*arg)
        if arg.length == 0
          !@assoc_coords.nil?   # if a grid has assoc coords
        else
          name = arg[0]
          if @assoc_coords
            @assoc_coords.has_coord?(name)
          else
            false
          end
        end
      end

      def has_coord?(name)
        has_axis?(name) || has_assoccoord?(name)
      end

      def assoccoordnames
	@assoc_coords && @assoc_coords.coordnames
      end

#      def axis(i)
#	 @axes[i]
#      end

      def axis(dim_or_dimname)
	 ax_dim(dim_or_dimname)[0]
      end

      alias get_axis axis

      def coord(i)
        if @assoc_coords && i.is_a?(String) && @assoc_coords.has_coord?(i)
          @assoc_coords.coord(i)
        else
          axis(i).pos
        end
      end

      def assoc_coord_gphys(name)
        @assoc_coords && @assoc_coords.coord_gphys(name)
      end

      def dim_index(dimname)
	 ax_dim(dimname)[1]
      end

      def coord_dim_indices(coordname)
        dim = @axnames.index(coordname)
        if dim
          [dim]
        elsif @assoc_coords && @assoc_coords.has_coord?(coordname)
          axnms = @assoc_coords.coord_gphys(coordname).axnames
          axnms.collect{|nm| @axnames.index(nm)}
        else
          nil
        end
      end

      def set_axis(dim_or_dimname,ax)
	 @axes[ i = dim_index(dim_or_dimname) ] = ax
         @axnames[ i ] = ax.name
	 self
      end

      def set_lost_axes( lost )
	 @lost_axes = lost   # Array of String
         self
      end
      def add_lost_axes( lost )
	 @lost_axes = @lost_axes + lost   # Array of String
         self
      end

      def delete_axes( at, deleted_by=nil )
	case at
        when String
          at = [dim_index(at)]
	when Numeric
	  at = [at]
	when Array
          at = at.collect{|x|
            case x
            when String
              dim_index(x)
            when Integer
              x
            else
              raise ArgumentError,"'at' must consist of Integer and/or String"
            end
          }
	else
	  raise TypeError, "1st arg not an Array"
	end

	at.collect!{|pos| 
	  if pos < 0
	    pos + a.length
	  else
	    pos
	  end
	}
	at.sort!
	newaxes = @axes.dup
	at.reverse.each{|pos| 
	  del = newaxes.delete_at(pos)
	  if !del
	    raise ArgumentError, "dimension #{pos} does not exist in a #{rank}D Grid"
	  end
	}

	newgrid = self.class.new( *newaxes )
	newgrid.set_lost_axes( @lost_axes.dup )
        if @assoc_coords
          newgrid.assoc_coords=@assoc_coords.subset_having_axnames(newgrid.axnames)
        end

	if !deleted_by 
	  msg = '(deleted) '
	else
	  raise TypeError, "2nd arg not a String" if !deleted_by.is_a?(String)
	  msg = '('+deleted_by+') '
	end
	lost = at.collect{|pos|
	  mn = sprintf("%g", ( UNumeric===(a=@axes[pos].pos.min) ? a.val : a) )
	  mx = sprintf("%g", ( UNumeric===(a=@axes[pos].pos.max) ? a.val : a) )
	  msg + 
	  "#{@axes[pos].name}:#{mn}..#{mx}"
	}

	newgrid.add_lost_axes( lost )
	newgrid
      end

      def copy
	 # deep clone onto memory
	 out = self.class.new( *@axes.collect{|ax| ax.copy} )
	 out.set_lost_axes( @lost_axes.dup )
         out.assoc_coords = @assoc_coords.copy if @assoc_coords
	 out
      end

      def merge(other)
	# merge two grids by basically using copies of self's axes but
	# using the other's if the length in self is 1 and 
        # the length in the other is longer
	if self.rank != other.rank
	  raise "ranks do not agree (self:#{self.rank} vs other:#{other.rank})"
	end
	axes = Array.new
	for i in 0...self.rank
	  if @axes[i].length == 1 and other.axis(i).length > 1
	    axes[i] = other.axis(i)
	  else
	    axes[i] = @axes[i]
	  end
	end
	out = self.class.new( *axes )
	out.set_lost_axes( (@lost_axes.dup + other.lost_axes).uniq )
        if (oac = other.assoc_coords) || (sac = self.assoc_coords)
          sac ? ac=sac.merge(oac) : ac=oac.merge(sac)
          out.assoc_coords = ac
        end
	out
      end

      def shape
	 @axes.collect{|ax| ax.length}
      end
      alias shape_current shape

      def [] (*slicer)
	 if slicer.length == 0
	    # make a clone
	    axes = Array.new
	    (0...rank).each{ |i| axes.push( @axes[i][0..-1] ) }
	    grid = self.class.new( *axes )
	 else
	    slicer = __rubber_expansion(slicer)
	    if slicer.length != rank
	       raise ArgumentError,"# of the args does not agree with the rank"
	    end
	    axes = Array.new
	    lost = self.lost_axes  #Array.new
	    for i in 0...rank
	       ax = @axes[i][slicer[i]]
	       if ax.is_a?(String)
                 lost.push( ax )
               else
                 axes.push( ax )
	       end
	    end
	    grid = self.class.new( *axes )
	    grid.set_lost_axes( lost ) if lost.length != 0
	    grid
	 end
         if @assoc_coords
           grid.assoc_coords = @assoc_coords[*slicer]
         end
         grid
      end

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
      private :__rubber_expansion

      def cut_assoccoord(hasharg)
        ac, acsl = @assoc_coords.cut(hasharg)
        sl = @axnames.collect{|nm| acsl[nm] || true}
        [ self[*sl], sl ]
      end

      def cut(*args)
	_cut_(false, *args)
      end
      def cut_rank_conserving(*args)
	_cut_(true, *args)
      end

      # cut along the regular coorinates.
      # assume that the coordinates are monotonic (without checking).
      def _cut_(conserve_rank, *args)

        hasharg = ( args.length==1 && args[0].is_a?(Hash) )

	if hasharg
	  # specification by axis names
	  spec = args[0]
	  if (spec.keys - axnames).length > 0
	    raise ArgumentError,"One or more of the hash keys "+
	      "(#{spec.keys.inspect}) are not found in the axis names "+
              "(#{axnames.inspect})."
	  end
	  args = axnames.collect{|ax| spec[ax] || true}
	end

	args = __rubber_expansion(args)

	if rank != args.length
	  raise ArgumentError, "# of dims doesn't agree with the rank(#{rank})"
	end

	slicer = Array.new

	for dim in 0...rank
	  ax = @axes[dim]
	  if conserve_rank
	    dummy, slicer[dim] = ax.cut_rank_conserving(args[dim])
	  else
	    dummy, slicer[dim] = ax.cut(args[dim])
	  end
	end

	[ self[*slicer], slicer ]
      end
      private :_cut_

#      def exclude(dim_or_dimname)
#	 dim = dim_index(dim_or_dimname)
#	 axes = @axes.dup
#	 axes.delete_at(dim)
#	 self.class.new( *axes )
#      end

      def change_axis(dim, axis)
	 axes = @axes.dup
	 lost = @lost_axes.dup
	 if axis.is_a?(Axis)
	    axes[dim] = axis
	 else
	    lost.push(axis) if axis.is_a?(String)
	    axes.delete_at(dim)
	 end
	 grid = self.class.new( *axes ).add_lost_axes( lost )
         if @assoc_coords
           grid.assoc_coords=@assoc_coords.subset_having_axnames(grid.axnames)
         end
         grid
      end

#      def change_axis!(dim_or_dimname, axis)
#	 if axis.is_a?(Axis)
#	    @axes[ dim_index(dim_or_dimname) ] = axis
#	 else
#	    @lost_axes.push(axis) if axis.is_a?(String)
#	    @axes.delete_at( dim_index(dim_or_dimname) )
#	 end
#	 @rank = @axes.length
#	 __check_and_set_axnames
#	 self
#      end

#      def insert_axis!(dim_or_dimname, axis)
#	 dim = dim_index(dim_or_dimname)
#	 if axis == nil
#	    # do nothing
#	 else
#	    @axes[dim+1,0] = axis    # @axes.insert(dim, axis) if ruby 1.7
#	    @rank = @axes.length
#	    __check_and_set_axnames
#	 end
#	 self
#      end

      def insert_axis(dim, axis)
        axes = @axes.dup
        ### commented out for the duck typing:
        #if axis.is_a?(Axis)
          axes.insert(dim, axis)
        #else
        #  raise ArgumentError, "2nd arg must be an Axis"
        #end
        grid = self.class.new( *axes )
	grid.set_lost_axes( lost_axes )
        grid.assoc_coords = @assoc_coords.dup if @assoc_coords
	grid
      end

      def transpose( *dims )
	if dims.sort != NArray.int(rank).indgen!.to_a
	  raise ArgumentError, 
            "Args must a permutation of 0..rank-1 (eg, if 3D 2,1,0; 1,0,2;etc)"
	end
	axes = Array.new
	for i in 0...rank
	  axes[i] = @axes[dims[i]]
	end
	grid = self.class.new(*axes)
	grid.set_lost_axes( lost_axes )
        grid.assoc_coords = @assoc_coords.dup if @assoc_coords
	grid
      end

      # Define operations along each axis --- The following defines
      # instance methods such as "average" and "integrate":

      Axis.defined_operations.each do |method|
      	 eval <<-EOS, nil, __FILE__, __LINE__+1
	 def #{method}(vary, dim_or_dimname, *extra_args)
	    ax, dim = self.ax_dim(dim_or_dimname)
	    va, new_ax = ax.#{method}(vary, dim, *extra_args)
            if va.is_a?(Numeric) || va.is_a?(UNumeric)
              va
	    else
              [va, self.change_axis(dim, new_ax)]
	    end
	 end
	 EOS
      end

      ######### < protected methods > ###########

      protected

      def ax_dim(dim_or_dimname)
	 if dim_or_dimname.is_a?(Integer)
	    dim = dim_or_dimname
	    if dim < -rank || dim >= rank
	       raise ArgumentError,"rank=#{rank}: #{dim}th grid does not exist"
	    end
	    dim += rank if dim < 0
	 else
	    dim = @axnames.index(dim_or_dimname)
	    if !dim
	       raise ArgumentError, "Axis #{dim_or_dimname} is not contained"
	    end
	 end
	 [@axes[dim], dim]
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
   p "average along x-axis:", grid.average(z,0)[0].val, 
     grid.average(z,"x")[0].val
   p "average along y-axis:", grid.average(z,1)[0].val, 
     grid.average(z,"y")[0].val
   p "grid set by an operation:", (g = grid.average(z,1)[1]).rank, g.shape

   p grid.shape, grid.axis(0).pos.val, grid.axis(1).pos.val
   subgrid = grid[1..3,1..2]
   p subgrid.shape, subgrid.axis(0).pos.val, subgrid.axis(1).pos.val
   p grid[3,2].lost_axes

   p grid

   gr,slice = grid.cut(1.0..4.0, 3.2)
   p "%%",gr.copy,slice,gr.lost_axes
   gr,slice = grid.cut_rank_conserving(-10,false)
   p "%%",gr.copy,slice,gr.lost_axes

   p grid[0,0]

   p Grid.new(xax).average(vx,0)  # --> scalar

   p "+++++"
   p grid.delete_axes(0).lost_axes
   p grid.delete_axes([0,1]).lost_axes
   p grid.delete_axes([0,1], 'mean').lost_axes

   p grid, grid.transpose(1,0)

   puts "Test insert_axis..."
   vz = VArray.new( NArray.float(3).indgen! + 10 ).rename("z")
   zax = Axis.new().set_pos(vz)
   grid3 = grid.insert_axis(-1,zax)
   p grid3
end

