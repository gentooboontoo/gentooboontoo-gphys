require "numru/hdfeos5"
require "numru/gphys/varray"
####require "numru/gphys/attributehdfeos5"

module NumRu

  class VArrayHE5SwField < VArray

    ## < initialization redefined > ##

    def initialize(aHE5SwField)
      @name = aHE5SwField.name
      @mapping = nil
      @varray = nil
      if ! aHE5SwField.is_a?(HE5SwField)
 	raise ArgumentError,"Not a HE5SwField" 
      end
      @ary = aHE5SwField
      @attr = Attribute.new
      aHE5SwField.att_names.each{|name|
           @attr[name.downcase] = aHE5SwField.get_att(name).to_s 
           @attr["long_name"] = aHE5SwField.get_att(name).to_s if  name == "Title"  # For SMILES /MLS 
      }
    end

    def inspect
      "<'#{@name}' in '#{@ary.swath.file.path}' #{@ary.ntype}#{shape_current.inspect}>"
    end

    class << self

      def new2(swath, name, ntype, dimensions, vary=nil)
        dimensions = dimensions.join(',') 
        va = new( swath.def_var(name, ntype, dimensions) )
        if vary
          vary.att_names.each{|name| va.set_att(name, vary.get_att(name))}
	end
        va
      end
      alias def_var new2

      def new3(swath, name, ntype, dimensions, vary=nil)
        dimensions = dimensions.join(',')
        va = new( swath.def_geo(name, ntype, dimensions) )
        if vary
	  vary.att_names.each{|name| va.set_att(name, vary.get_att(name))}
	end
        va
      end
      alias def_geo new3


      ## < additional class methods > ##

      def write(file, vary, rename=nil, dimnames=nil)
	raise ArgumentError, "1st arg: not a HE5Sw" if !file.is_a?(HE5Sw)
	raise ArgumentError, "2nd arg: not a VArray" if !vary.is_a?(VArray)
	rank=vary.rank
	if dimnames == nil
	  if vary.is_a?(VArrayHE5SwField)
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
	for i in 0...rank
	  nm = dimnames[i]
	  if fdimnms.include?(nm)
	    dims[i] = nm
	  else
	    dims[i] = file.defdim(nm.name,shape[i])
	  end
	end
	nm = ( rename || vary.name )
	val = vary.val
	newvary = new2(file, nm, vary.typecode, dims, vary)
	newvary.val = val
        return newvary
      end
    end

    ## < redefined instance methods > ##
    
    def val
      return @ary.get
    end

    def val=(narray)
      if narray.is_a?(Numeric)
        @ary.put( narray )
      else
        narray = __check_ary_class(narray)
        slicer = (0...rank).collect{|i|
          (shape_ul0[i] != 0) ? true : 0...narray.shape[i]
        }
        @ary[*slicer] = narray
        narray
      end
    end

    def shape
      raise "The shape method is not available. Use shape_ul0 or shape_current instead."
    end


    def ntype
      @ary.ntype
    end

    def shape_ul0
      @ary.shape_ul0
    end

    def shape_current
      @ary.shape_current
    end

    def total
      len = 1
      @ary.shape_current.each{|i| len *= i}
      len
    end
    alias length total

    def rank
      @ary.rank
    end

    undef reshape!

    def dim_names
      @ary.dim_names
    end
    
    def file
      @ary.swath
    end
  end     # class VArrayHE5Sw

  class VArrayHE5GdField < VArray

    ## < initialization redefined > ##

    def initialize(aHE5GdField)
      @name = aHE5GdField.name
      @mapping = nil
      @varray = nil
      if ! aHE5GdField.is_a?(HE5GdField)
 	raise ArgumentError,"Not a HE5GdField" 
      end
      @ary = aHE5GdField
      @attr = Attribute.new
      aHE5GdField.att_names.each{|name|
        @attr[name.downcase] = aHE5GdField.get_att(name).to_s 
        @attr["long_name"] = aHE5GdField.get_att(name).to_s if  name == "Title"  # For SMILES /MLS 
      }
    end

    def inspect
      "<'#{@name}' in '#{@ary.grid.file.path}' #{@ary.ntype}#{shape_current.inspect}>"
    end

    class << self

      def new2(grid, name, ntype, dimensions, vary=nil)
        dimensions = dimensions.join(',')

        va = new( grid.def_var(name, ntype, dimensions) )
        if vary
	  vary.att_names.each{|name| va.set_att(name, vary.get_att(name))}
	end
        va
      end
      alias def_var new2


      ## < additional class methods > ##

      def write(file, vary, rename=nil, dimnames=nil)
	raise ArgumentError, "1st arg: not a HE5Gd" if !file.is_a?(HE5Gd)
	raise ArgumentError, "2nd arg: not a VArray" if !vary.is_a?(VArray)
	rank=vary.rank
	if dimnames == nil
	  if vary.is_a?(VArrayHE5GdField)
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
	for i in 0...rank
	  nm = dimnames[i]
	  if fdimnms.include?(nm)
	    dims[i] = nm
	  else
	    dims[i] = file.defdim(nm.name,shape[i])
	  end
	end
	nm = ( rename || vary.name )
	val = vary.val
	newvary = new2(file, nm, vary.typecode, dims, vary)
	newvary.val = val
        return newvary
      end
    end

    ## < redefined instance methods > ##

    def val
      return @ary.get
    end

    def val=(narray)
      if narray.is_a?(Numeric)
        @ary.put( narray )
      else
        narray = __check_ary_class(narray)
        slicer = (0...rank).collect{|i|
          (shape_ul0[i] != 0) ? true : 0...narray.shape[i]
        }
        @ary[*slicer] = narray
        narray
      end
    end

    def shape
      raise "The shape method is not available. Use shape_ul0 or shape_current instead."
    end


    def ntype
      @ary.ntype
    end

    def shape_ul0
      @ary.shape_ul0
    end

    def shape_current
      @ary.shape_current
    end

    def total
      len = 1
      @ary.shape_current.each{|i| len *= i}
      len
    end
    alias length total

    def rank
      @ary.rank
    end

    undef reshape!

    def dim_names
      @ary.dim_names
    end
    
    def file
      @ary.grid
    end
  end     # class VArrayHE5Gd

  class VArrayHE5ZaField < VArray
    ## < initialization redefined > ##

    def initialize(aHE5ZaField)
      @name = aHE5ZaField.name
      @mapping = nil
      @varray = nil
      if ! aHE5ZaField.is_a?(HE5ZaField)
        raise ArgumentError,"Not a HE5ZaField" 
      end
      @ary = aHE5ZaField
      @attr = Attribute.new
      aHE5ZaField.att_names.each{|name|
        @attr[name.downcase] = aHE5ZaField.get_att(name).to_s 
        @attr["long_name"] = aHE5ZaField.get_att(name).to_s if  name == "Title"  # For SMILES /MLS 
      }
    end

    def inspect
      "<'#{@name}' in '#{@ary.za.file.path}' #{@ary.ntype}#{shape_current.inspect}>"
    end

    class << self

      def new2(za, name, ntype, dimensions, vary=nil)
        dimensions = dimensions.join(',') 
        va = new( za.def_var(name, ntype, dimensions) )
        if vary
          vary.att_names.each{|name| va.set_att(name, vary.get_att(name))}
        end
        va
      end
      alias def_var new2

      ## < additional class methods > ##

      def write(file, vary, rename=nil, dimnames=nil)
        raise ArgumentError, "1st arg: not a HE5Za" if !file.is_a?(HE5Za)
        raise ArgumentError, "2nd arg: not a VArray" if !vary.is_a?(VArray)
        rank=vary.rank
        if dimnames == nil
          if vary.is_a?(VArrayHE5ZaField)
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
        for i in 0...rank
          nm = dimnames[i]
          if fdimnms.include?(nm)
            dims[i] = nm
          else
            dims[i] = file.defdim(nm.name,shape[i])
          end
        end
        nm = ( rename || vary.name )
        val = vary.val
        newvary = new2(file, nm, vary.typecode, dims, vary)
        newvary.val = val
        return newvary
      end
    end

    ## < redefined instance methods > ##

    def val
      return @ary.get
    end

    def val=(narray)
      if narray.is_a?(Numeric)
        @ary.put( narray )
      else
        narray = __check_ary_class(narray)
        slicer = (0...rank).collect{|i|
          (shape_ul0[i] != 0) ? true : 0...narray.shape[i]
        }
        @ary[*slicer] = narray
        narray
      end
    end

    def shape
      raise "The shape method is not available. Use shape_ul0 or shape_current instead."
    end


    def ntype
      @ary.ntype
    end

    def shape_ul0
      @ary.shape_ul0
    end

    def shape_current
      @ary.shape_current
    end

    def total
      len = 1
      @ary.shape_current.each{|i| len *= i}
      len
    end
    alias length total

    def rank
      @ary.rank
    end

    undef reshape!

    def dim_names
      @ary.dim_names
    end
    
    def file
      @ary.grid
    end
  end     # class VArrayHE5Za

end     # module NumRu

###########################################################
### < test >

if $0 == __FILE__
 #  $DEBUG = true
   include NumRu
   file = HE5.open("tmp.he5","w")
   swath = file.create_swath("test2")
   dims = [ swath.defdim("x",10),  swath.defdim("t",2) ]
   x = VArrayHE5SwField.new2(swath,"x","H5T_NATIVE_FLOAT",dims[0..0])
   x.set_att("units", "km")
   x.val = 10

   y = VArrayHE5SwField.new3(swath,"time","H5T_NATIVE_DOUBLE",dims[0..0])
   y.set_att("units", "s")

   z = VArrayHE5SwField.def_geo(swath,"Latitude","H5T_NATIVE_FLOAT",dims[0..1])
   z.set_att("units", "deg")

   v = VArrayHE5SwField.new2(swath,"v","H5T_NATIVE_FLOAT",dims)
   v.set_att("units","m/s")
   v[0..-1,0] = 99.0
   v[0..-1,1] = 66.0
   v_ = VArrayHE5SwField.def_var(swath,"v_","H5T_NATIVE_FLOAT",["x","t"])
   w = VArrayHE5SwField.write(swath,v,"w")
end
