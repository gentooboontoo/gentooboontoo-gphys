begin
  require "numru/nusdas"
rescue LoadError
end
require "numru/gphys/varray"

module NumRu

  class VArrayNuSDaS < VArray

    def initialize(var)
      unless NuSDaSVar === var
        raise ArgumentError, "Not a NuSDaSVar"
      end
      @name = var.name
      @mapping = nil
      @varray = nil
      @ary = var
      @attr = Attribute.new
      var.att_names.each{|name|
        @attr[name] = var.att(name)
      }
    end

    def inspect
      "<'#{name}' in '#{@ary.nusdas.root}' [#{@ary.shape.join(", ")}]>"
    end

    def val
      @ary.get
    end

    def shape
      @ary.shape
    end
    alias shape_ul0 shape
    alias shape_current shape

    def total
      @ary.total
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
      @ary.nusdas
    end

  end
end
