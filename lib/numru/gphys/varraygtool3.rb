=begin
=ToDo list
* Support a temporay attribute (@tmp_attr = Attribute.new)
=end

require "numru/gphys/gtool3"
require "numru/gphys/varray"

module NumRu

  ATTR_CF_CONV = {
    "DSET" => "dataset",
    "TITLE" => "long_name",
    "UNIT" => "units",
    "MISS" => "missing_value"
#    "ITEM" => nil,       # identical to name
#    "TIME" => nil,       # treated in the time axis
#    "DATE" => nil,       # treated in the time axis
#    "UTIM" => nil,       # treated in the time axis
#    "TDUR" => nil,       # in Future, should be treaded with cell_* in CF
#    "CSIGN" => nil,      # will be in history in convination
#    "CDATE" => nil       # will be in history in convination
#    "MDATE" => nil,      # will be in history in convination
#    "MSIGN" =>  nil,     # will be in history in convination
  }

  class VArrayGtool3 < VArray

    ## < initialization redefined > ##

    def initialize(aGtool3Var)
      raise ArgumentError,"Not a Gtool3Var" if ! aGtool3Var.is_a?(Gtool3Var)
      @name = aGtool3Var.name
      @mapping = nil
      @varray = nil
      @ary = aGtool3Var
      @attr = _attr_conv_to_CF( aGtool3Var.attr )
    end

    def _attr_conv_to_CF(org)
      attr = Attribute.new
      ATTR_CF_CONV.each do |ik,ok|
        val = org[ik]
        val = NArray[val] if val.is_a?(Numeric)
        attr[ok] = val
      end
      hist = ""
      hist += "Created #{org["CDATE"]} by #{org["CSIGN"]}. " if org["CDATE"]
      hist += "Modifiled #{org["MDATE"]} by #{org["MSIGN"]}. "if org["MDATE"]
      attr["history"] = hist if hist.length > 0
      attr
    end
    private :_attr_conv_to_CF

    class << self
      ## < redefined class methods > ##

      #def new2(file, name, ntype, dimensions, attr=nil)
      #  va = new( file.def_var(name, ntype, dimensions) )
      #  if attr; attr.each{|key,val| va.attr[key]=val}; end 
      #  va
      #end
      undef new2

      # to make a varray from an axis (except for time)
      def make_coord(hash)
        nary = hash.delete(:val)
        name = hash.delete("ITEM")
        coord_att_conv!(hash)
        VArray.new(nary, hash, name)
      end

      def coord_att_conv!(hash)
        hash.keys.each do |k|
          v = hash.delete(k)
          if (ck=ATTR_CF_CONV[k])   # substitution, not ==
            v = NArray[v] if v.is_a?(Numeric)
            if k=="UNIT"
              case v
              when "deg"
                v = "degrees"
              end
            end
            hash[ck] = v
          elsif k=="STYP" && v
            if v >= 0
              hash["positive"] = "up"
            else
              hash["positive"] = "down"
            end
          end
        end
        hash
      end
    end

    ## < redefined instance methods > ##

    def val
      v = @ary.get
    end

    def val=(narray)
      @ary.put( __check_ary_class2(narray) )
      narray
    end

    # # It is safer not to have the method "shape" to avoid misconfusion of 
    # # shape_ul0 and shape_current:
    # def shape
    #   raise "The shape method is not available. Use shape_ul0 or shape_current instead."
    # end

    def inspect
      "<'#{@name}' in '#{@ary.file.path}' #{ntype}#{shape_current.inspect}>"
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

#    def reshape!( *args )
#      raise "cannot reshape a #{class}. Use copy first to make it a VArray with NArray"
#    end
    undef reshape!


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

  end

  class VArrayGtool3Time < VArray
    def initialize(hash, calendar=nil)
      @ary = hash.delete(:val)
      @name = hash.delete("ITEM")
      @attr = Attribute.new
      @attr.update( VArrayGtool3.coord_att_conv!(hash) )
      @attr["calendar"] = calendar if calendar
      @varray = nil
      @mapping = nil
    end

    def inspect
      "<'#{name}' in '#{@ary.file.path}' #{ntype}#{shape.inspect}>"
    end

    def val
      @ary.get
    end
  end


end

###########################################################
### < test >

if $0 == __FILE__
 #  $DEBUG = true
  include NumRu
  Gtool3.gtaxdir = File.expand_path("~/dennou/GTAXDIR")
  path = ARGV[0]
  varname = ARGV[1] or raise("Need two args")

  file = Gtool3.open(File.expand_path(path))
  var = file.var(varname)
  va = VArrayGtool3.new(var)

  p va, va.name
  p va.dim_names
  p va.shape_ul0
  p va.val

  va.att_names.each do |nm|
    print nm,"\t",va.get_att(nm).inspect,"\n"
  end

  p va.get_att("long_name")

  print "***************\n"
  va2 = va[3..9,5..15,0,0]
  p va2.shape
  p va2.val

  p va2.get_att("long_name")

  print "****** time *******\n"

  t = VArrayGtool3Time.new(var.axis(-1)["LOC"])
  p t, t[1..3].val
  t.att_names.each do |nm|
    print nm,"\t",va.get_att(nm).inspect,"\n"
  end

  print "****** lon *******\n"

  xg = var.axis(0)["LOC"]
  #nm = xg.delete("ITEM)"
  #na = xg.delete(:val)
  #x = VArray.new(na, xg, nm)
  x = VArrayGtool3.make_coord(xg)
  p x, x[1..3].val
  x.att_names.each do |nm|
    print nm,"\t",x.get_att(nm).inspect,"\n"
  end
end
