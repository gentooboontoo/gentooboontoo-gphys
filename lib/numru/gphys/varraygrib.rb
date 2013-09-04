=begin
=Status
* only reading
=end

require "numru/gphys/grib"
require "numru/gphys/varray"

module NumRu

=begin
=NumRu::VArrayGrib < VArray
==Class Methods
---new(GribVar)
==Methods
=end
  class VArrayGrib < VArray

    def initialize(aGribVar)
      if !GribVar===aGribVar && !GribDim===aGribVar
        raise ArgumentError,"Not a GribVar or GribDim"
      end
      @name = aGribVar.name
      @mapping = nil
      @varray = nil
      @ary = aGribVar
      @attr = Attribute.new
      aGribVar.att_names.each{|name|
        @attr[name] = aGribVar.att(name)
      }
      if GribDim===@ary
        class << @ary
          def rank
            return 1
          end
          def shape
            return [@length]
          end
        end
      end
    end

    def inspect
      if GribVar===@ary
        "<'#{@name}' in '#{@ary.file.path}'  [#{@ary.shape.join(", ")}]>"
      elsif GribDim===@ary
        "<'#{@name}' in '#{@ary.var.name}'  #{@ary.length}>"
      end
    end

    class << self
      ## < redefined class methods > ##

      def new2(file, name, dims, vary)
        v = file.def_var(name)
        dims.length.times{|n|
          d = dims[n]
          if GribDim===d
            gd = v.def_dim(d.name,n)
            gd.put(d.get)
            d.att_names.each{|name| gd.put_att(name,d.att(name)) }
          elsif VArray===d
            gd = v.def_dim(d.name,n)
            gd.put(d.val)
            d.att_names.each{|name| gd.put_att(name,d.get_att(name)) }
          elsif String===d
            gd = v.def_dim(d,n)
            gd.put(NArray.sfloat(vary.shape_ul0[n]).indgen)
          else
            raise "type is not correct"
          end
        }
        va = new(v)
        vary.att_names.each{|name| va.put_att(name,vary.get_att(name)) }
        return va
      end

      alias def_var new2

      ## < additional class methods > ##

      def write(file,vary,dims=nil)
        Grib===file || raise(ArgumentError,"1st arg: not a Grib")
        VArray===vary || raise(ArgumentError,"2st arg: not a VArray")
        rank = vary.rank
        if !dims
          dims = vary.dim_names
          if VArrayGrib===vary
            class << vary
              def dim(dn)
                @ary.dim(dn)
              end
            end
            dims = dims.collect{|dim| vary.dim(dim) }
          end
        end
        newvary = new2(file,vary.name,dims,vary)
        newvary.val = vary.val
        file.write
        return newvary
      end
    end

    ## < redefined instance methods > ##

    def val
      return @ary.val
    end

    def val=(narray)
      shape==narray.shape || raise("not same shape")
      @ary.put(narray)
    end

    def shape
      @ary.shape
    end

    def total
      @ary.total
    end
    alias length total

    def rank
      @ary.rank
    end

    undef reshape!

    ## < additional instance methods > ##

    def dim_names
      @ary.dim_names
    end
    def shape_ul0
      @ary.shape
    end
    def shape_current
      @ary.shape
    end
    def file
      @ary.file
    end

    def put_att(name,val)
      @ary.put_att(name,val)
    end

  end     # class VArrayGrib
end     # module NumRu

###########################################################
### < test >

if $0 == __FILE__
  $DEBUG = true

  include NumRu

  grib = Grib.open("../../../testdata/T.jan.grib")
  gv = grib.var("TMP")

  va = VArrayGrib.new(gv)
  p va.dim_names
  p va.shape_ul0
  va.att_names.each{|key|
    p [key, va.get_att(key)]
  } 

  p va.val


  va2 = va[3..9,5..15,0]
  p va2.shape
  p va2.val

end
