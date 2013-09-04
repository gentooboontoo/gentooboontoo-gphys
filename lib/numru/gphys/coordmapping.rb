require "narray"

=begin
= class CoordMapping

== Overview
Mapping of a coordinate to another. It supports analytic and 
grid-point-based mapping in subclasses. Here in this root
CoordMapping class only the invariant unity mapping (or no mapping)
is defined.

== Class methods
---CoordMapping.new
     Constructor. One or more arguments can be needed in subclasses

== Methods
---map(x,y,z,...)
     Maps data point(s)

     ARGUMENTS
     * x,y,z,... (one or more Numeric or NArray) : data points. 
       Mapping is made of [x,y,z,..] (if Numeric) or 
       [x[0],y[0],z[0],..], [x[1],y[1],z[1],..], ..(if NArray).
       Thus, the number of arguments must be equal to the rank of 
       the mapping. Also, their lengths must agree with each other.

     RETURN VALUE
     * Array of p,q,r,... (Numeric or NArray) : mapping result

---map_grid(x,y,z,...)
     Same as ((<map>)) but for a regular grid.
     
     ARGUMENTS
     * x,y,z,... (one or more 1D NArray) : coordinate values of
       a regular grid [x_i, y_j, z_k,..].  The shape of the grid is thus 
       [x.length, y.length, z.length,..]. This method needs no redefinition,
       since it calls ((<map>)) inside.

---inverse_map(p,q,r,...)
     Inversely maps data point(s).

     ARGUMENTS
     * p,q,r,... (one or more Numeric or NArray) : data points. 
       Inverse mapping is made of [p,q,r,..] (if Numeric) or 
       [p[0],q[0],r[0],..], [p[1],q[1],r[1],..], ..(if NArray).
       Thus, the number of arguments must be equal to the rank of 
       the mapping. Also, if NArray, their lengths must agree with each other.

     RETURN VALUE
     * Array of x,y,z,... (Numeric or NArray) : inverse mapping result

---inverse
     Returns the inverse mapping.

     RETURN VALUE
     * a CoordMapping

---inversion_rigorous?
     Whether the inversion is rigorous (analytical)

     RETURN VALUE
     * true or false

= class LinearCoordMapping < CoordMapping

== Overview
Linear coordinate mapping expressed as offset + factor*x,
where offset is a vector (NVect) and factor is a matrix (NMatrix).

Methods listed below are only those newly defined or those whose 
arguments are changed.

== Class methods
---LinearCoordMapping.new(offset=nil, factor=nil)
     Constructor. If one of offset and factor is not 
     specified (nil), a zero vector / a unit matrix is used (at least 
     one of them must be given).

     ARGUMENTS
     * offset (NVector or nil) : the offset. Its length represents the rank
       of mapping. (if nil a zero vector is assumed)
     * factor (NMatrix or nil) : the factor. For consistency, 
       ( offset.length == factor.shape[0] == factor.shape[1] ) is required.

== Methods
---offset
     Returns the internally stored offset.

---factor
     Returns the internally stored factor.

=end

module NumRu

   class CoordMapping
      def initialize
	 @rank = nil   # nil means any (set a positive integer to specify)
         @inversion_rigorous = true
      end

      attr_reader :rank

      def inversion_rigorous?
	 @inversion_rigorous
      end

      def map(*args)
	 __check_args_m(*args)
	 args.collect{|v| v.dup}
      end
      def inverse_map
	 __check_args_m(*args)
	 args.collect{|v| v.dup}
      end

      def map_grid(*args)
	 args.each{|v| raise ArgumentError,"all args must be 1D" if v.rank!=1}
	 shape = args.collect{|v| v.length}
	 rank = shape.length
	 expanded=Array.new
	 (0...args.length).each{|i|
	    to_insert = (0...i).collect{|j| 0} + ((i+1)...rank).collect{|j| 1}
	    x = args[i]
	    if to_insert.length > 0
	       x = x.newdim(*to_insert) 
	       x += NArray.float(*shape)
	    end
	    expanded.push(x)
	 }
	 map(*expanded)
      end

      def inverse
	 self.clone
      end

      private
      def __check_args_m(*args)
	 if @rank
	    if args.length != @rank
	       raise ArgementError,
		  "# of the arguments must agree with the rank #{@rank}"
	    end
	 else
	    if args.length == 0
	       raise ArgementError,"# of the arguments must be 1 or greater"
	    end
	 end
	 if args[0].is_a?(Numeric)
	    for i in 1...args.length
	       if !args[i].is_a?(Numeric)
		  raise ArgumentError,
		     "If the first arg is a numeric, the remaing must be so."
	       end
	    end
	 else
	    for i in 1...args.length
	       if args[i-1].length != args[i].length
		  raise ArgumentError,"lengths of the args must be the same"
	       end
	    end
	 end
      end
   end

   ############################

   class LinearCoordMapping < CoordMapping

      def initialize(offset=nil, factor=nil)

	 #< argument check & set rank, offset, factor >

	 if !offset && !factor
	    raise ArgumentError,"One of offset and factor must be specified"
	 elsif !factor
	    raise ArgumentError,"offset is not a NVector" if !offset.is_a?(NVector)
	    @rank = offset.length
	    @factor = NMatrix.float(@rank,@rank)
	    @factor.diagonal!(1)
	 else
	    raise ArgumentError,"factor is not a NMAtrix" if !factor.is_a?(NMatrix)
	    nx,ny = factor.shape
	    raise ArgumentError,"factor must be a square matrix" if nx != ny
	    @rank = nx
	    if offset
	       raise ArgumentError,"offset is not a NVector" if !offset.is_a?(NVector)
	       if offset.length != @rank
		  raise ArgumentError,"inconsistent dimensionarity between "+
		     "offset #{offset.length} and factor #{factor.shape}"
	       end
	       @offset = offset
	    else
	       @offset = NVector.float(@rank)
	    end
	    @factor = factor
	 end

	 #< other parameters >

	 @inversion_rigorous = true
	 @inv_factor = nil   # deferred until needed (might not be invertible)

      end

      attr_reader :factor, :offset

      def map(*args)
	 __check_args_m(*args)
	 x = __to_NVector(*args)
	 p = @offset + @factor*x
	 (0...@rank).collect{|i| p[i,false]}
      end

      def inverse_map(*args)
	 __check_args_m(*args)
	 p = __to_NVector(*args)
	 __set_inv_factor if !@inv_factor
	 x = @inv_factor * ( p - @offset )
	 (0...@rank).collect{|i| x[i,false]}
      end

      def inverse
	 __set_inv_factor if !@inv_factor
	 LinearCoordMapping.new( -@inv_factor*@offset, @inv_factor )
	 # Here, LinearCoordMapping.new is better than class.new,
         # since the constructor may change in subclasses.
      end

      private 
      def __to_NVector(*args)
	 if args[0].is_a?(Numeric)
	    NVector[*args]
	 else
	    v = NVector.float(@rank,*args[0].shape)
	    for i in 0...@rank
	       v[i,false] = args[i]
	    end
	    v
	 end
      end

      def __set_inv_factor
	 begin
	    @inv_factor = @factor.inverse
	 rescue
	    raise $!,"mapping factor (which is a Matrix) is not invertible"
	 end
      end

   end

end

################################################################
if $0 == __FILE__
   include NumRu

   puts "\n** The default unity mapping class CoordMapping **\n\n"

   mp = CoordMapping.new
   x = y = z = NArray.float(10).indgen!
   p,q,r = mp.map(x,y,z)
   p p,q,r

   puts "\n** LinearCoordMapping **\n\n"
   include Math

   offset = NVector[ 100.0, 0.0, 100.0 ]
   theta = PI/6
   factor = NMatrix[ [cos(theta), -sin(theta), 0],
                     [sin(theta), cos(theta) , 0],
                     [0         , 0          , 1] ]
   mp = LinearCoordMapping.new(offset, factor)
   y = z = NArray.float(10)
   p,q,r = mp.map(x,y,z)
   puts "<<forward>>"
   p p,q,r
   puts "<<inverse>>"
   p *mp.inverse_map(p,q,r)
   puts "<<map grid>>"
   x = y = NArray[0.0, 1.0]
   z = NArray[0.0,1.0,2.0]
   p *mp.map_grid(x,y,z)
end
