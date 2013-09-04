=begin
=ToDo list
* Support a temporay attribute (@tmp_attr = Attribute.new)
=end

require "numru/netcdf"
require "numru/gphys/varray"
require "numru/gphys/attributenetcdf"
require "numru/gphys/netcdf_convention"

module NumRu

   ###############################

   ### /// for write buffering -->

   class NetCDFVar
     alias current_put put
   end              # class NetCDFVar

   module NetCDFDeferred
      # To be "extend"ed in a NetCDF object to add simgular methods
      # to support deferred operations.
      # Used together with NetCDFVarDeferred.

      def add_deferred(proc,args,length)
	 defined?(@len_stored) ? @len_stored+=length : @len_stored=length
	 @deferred = Array.new if ! defined?(@deferred) || ! @deferred
	 @deferred.push( [proc, args] ) 
      end
      def flush
	 if @deferred
	    @deferred.each{|opr|
	       if ($DEBUG)
		  print "## flushing ## "; p opr
               end
	       opr[0].call(opr[1])
	    }
	    @deferred = nil
	    NetCDFVarDeferred.flushed_length(@len_stored)
	    @len_stored = 0
	 end
      end
      def enddef
	 super
	 flush
      end
      def sync
	 if define_mode?
	    enddef
	    super
	    redef
	 else
	    super
	 end
      end
      def close
	 enddef
	 super
      end
   end        # module NetCDFDeferred

   #######

   module NetCDFVarDeferred
      # To be "extend"ed in a NetCDFVar object to add simgular methods
      # to support deferred operations.
      # Used together with NetCDFDeferred.

      @@max_len_store = 1000000       # regardress sizeof(type)
      @@len_stored = 0

      class << self
	 def flushed_length(len)
	    @@len_stored -= len
	 end
	 def max_len_store; max_len_store; end
	 def max_len_store= (l)
	    @@max_len_store = l
	 end
      end

      def name=(*args)
	begin
	  super(*args)
	rescue
	  file.redef
	  retry
	end
      end

      def put_att(*args)
	begin
	  super(*args)
	rescue
	  file.redef
	  retry
	end
      end

      def put(*args)
	 if(self.file.define_mode?)
	    if (@@len_stored < @@max_len_store)
	       ## put operation is stored in self.file and deferred
	       print "## storing (put) ##\n" if ($DEBUG)
	       len = args[0].is_a?(Numeric) ? 1 : args[0].total
	       self.file.add_deferred( Proc.new{|args| current_put(*args)}, args, len)
	       @@len_stored += len
	    else
	       self.file.enddef
	       current_put(*args)
	       self.file.redef
	    end
	 else
	    self.file.flush
	    current_put(*args)
	 end
      end
   end

   ### <-- for write buffering ///

   ####################################################################

   class VArrayNetCDF < VArray

      ## < initialization redefined > ##

      def initialize(aNetCDFVar)
	 @name = aNetCDFVar.name
	 @mapping = nil
	 @varray = nil
	 raise ArgumentError,"Not a NetCDVAr" if ! aNetCDFVar.is_a?(NetCDFVar)
	 @ary = aNetCDFVar
	 @ary.extend(NetCDFVarDeferred)
	 @ary.file.extend(NetCDFDeferred)
	 @attr = AttributeNetCDF.new(aNetCDFVar)
	 @convention = NetCDF_Conventions.find(aNetCDFVar.file)
	 extend( @convention::VArray_Mixin )
      end

      def inspect
	 "<'#{@name}' in '#{@ary.file.path}'  #{@ary.ntype}#{shape_current.inspect}>"
      end

      class << self
	 ## < redefined class methods > ##

         def new2(file, name, ntype, dimensions, vary=nil)
	   dimensions = dimensions.collect{|dim| 
	     if dim.is_a?(String)
	       # specification by name is available for existing dimensions
	       file.dim(dim) || raise("dimension "+dim+" is not in "+file.path)
	     else
	       dim
	     end
	   }
	    va = new( file.def_var(name, ntype, dimensions) )
            if vary
	      vary.att_names.each{|name| va.set_att(name, vary.get_att(name))}
	    end 
            va
         end

	 alias def_var new2

	 ## < additional class methods > ##

	 def write(file, vary, rename=nil, dimnames=nil)
	    raise ArgumentError, "1st arg: not a NetCDF" if !file.is_a?(NetCDF)
	    raise ArgumentError, "2nd arg: not a VArray" if !vary.is_a?(VArray)
	    rank=vary.rank
	    if dimnames == nil
	       if vary.is_a?(VArrayNetCDF)
		  dimnames = vary.dim_names
	       else
		  dimnames=Array.new
		  for i in 0...rank
		     dimnames[i]='x'+i.to_s
		  end
	       end
	    elsif( rank != dimnames.length)
	       raise ArgumentError, 
                    "# of dim names does not agree with the rank of the VArray"
	    end
	    fdimnms = file.dim_names
	    begin
	       shape = vary.shape
	    rescue StandardError, NameError
	       shape = vary.shape_ul0
	    end
	    dims = Array.new
	    mode_switched = file.redef
	    for i in 0...rank
	       nm = dimnames[i]
	       if fdimnms.include?(nm)
		  dims[i] = dm = file.dim(nm)
		  if dm.length != shape[i] && shape[i] != 0 && dm.length != 0
		     raise "Length of the dimension #{nm} is #{dims[i].length}, while the #{i}-th dimension of the VArray #{vary.name} is #{shape[i]}"
                  end
	       else
		  dims[i] = file.def_dim(nm,shape[i])
	       end
	    end
	    nm = ( rename || vary.name )
	    val = vary.val
	    newvary = new2(file, nm, vary.typecode, dims, vary)
	    newvary.val = val
	    if  mode_switched; file.enddef; end
	    newvary
	 end
      end

      ## < redefined instance methods > ##

      def val
	 mode_switched = @ary.file.enddef
	 v = @ary.get
	 if mode_switched; @ary.file.redef; end
	 v
      end

      def val=(narray)
	if narray.is_a?(Numeric)
	  @ary.put( narray )
	else
	  if shape_ul0.include?(0)
	    # has unlimited dimension
	    narray = __check_ary_class(narray)
	    slicer = (0...rank).collect{|i|
	      (shape_ul0[i] != 0) ? true : 0...narray.shape[i]
	    }
	    @ary[*slicer] = narray
	  else
	    @ary.put( __check_ary_class(narray) )
	  end
	  narray
	end
      end

      # It is safer not to have the method "shape" to avoid misconfusion of 
      # shape_ul0 and shape_current:
      def shape
	 raise "The shape method is not available. Use shape_ul0 or shape_current instead."
      end

      def name=(nm)
	 @ary.name = nm
	 @name = nm
      end
      def rename!(nm)
	 @ary.name = nm
	 @name = nm
	 self
      end
      def rename_no_file_change(nm)
	 @name = nm
	 self
      end
      def rename(nm)
	self.dup.rename_no_file_change(nm)
      end

      def ntype
	@ary.ntype
      end

      def total
	 len = 1
	 @ary.shape_current.each{|i| len *= i}
	 len
      end
      alias length total

      def rank
	shape_current.length
      end

#      def reshape!( *args )
#	raise "cannot reshape a #{class}. Use copy first to make it a VArray with NArray"
#      end
      undef reshape!

      def file
	 @ary.file
      end

      ## < additional instance methods > ##

      def dim_names
	 @ary.dim_names
      end
      def shape_ul0
	 @ary.shape_ul0
      end
      def shape_current
	 @ary.shape_current
      end
      def file
	 @ary.file
      end

      ## Not needed, so far:
      #def convention
      #  @convention
      #end

   end     # class VArrayNetCDF
end     # module NumRu

###########################################################
### < test >

if $0 == __FILE__
 #  $DEBUG = true
   include NumRu
   file = NetCDF.create("tmp.nc")
   dims = [ file.def_dim("x",10),  file.def_dim("t",0) ]
   x = VArrayNetCDF.new2(file,"x","sfloat",dims[0..0])
   x.set_att("units", "km")
   x.val = 10
   v = VArrayNetCDF.new2(file,"v","sfloat",dims)
   v.set_att("units","m/s")
   v_ = VArrayNetCDF.new2(file,"v_","sfloat",["x","t"])
   # file.enddef  # (no need to call this)
   v[0..-1,0] = 99.0
   v[0..-1,1] = 66.0
   w = VArrayNetCDF.write(file,v,"w")
   wsub = w[0..-1,1]
   wsub.val = 22.0
   z = VArrayNetCDF.new2(file,"z","sfloat",dims)
   z.val = NArray.int(10,2).indgen!
   p w
   #exit

   file2 = NetCDF.create("tmp2.nc")
   vv = VArrayNetCDF.write(file2,v,"vv")
   vv2 = VArrayNetCDF.write(file2,v/3,"vv2")
   vv3 = VArrayNetCDF.write(file2,v/3,"vv3")
   v.copy(vv2)
   (2*v/3).copy(vv3)
   p "%%%%",(v + w).val,"#####"
   p v.length
   p v.file.path
   p v[0..2,0].file.path
   file.close
   file2.close
end
