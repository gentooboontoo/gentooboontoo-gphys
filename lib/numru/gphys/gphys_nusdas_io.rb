begin
  require "numru/nusdas"
rescue LoadError
  module NumRu
    class NuSDaS
      class << self
        def new(path)
          raise "nusdas library is not found"
        end
        def is_a_NuSDaS?(path)
          return false
        end
      end
    end
  end
end
require "numru/gphys/varraynusdas"

module NumRu
  class GPhys

    module NuSDaS_IO

      module_function

      def is_a_NuSDaS?(path)
        NuSDaS.is_a_NuSDaS?(path)
      end

      def open(nusdas, varname)
        if String === nusdas
          nusdas = NuSDaS.new(nusdas)
        end
        unless NuSDaS === nusdas
          raise ArgumentError, "1st arg must be a NuSDaS of path name"
        end

        var = nusdas.var(varname)
        var.nil? && raise("#{varname} is not found")
        data = VArrayNuSDaS.new(var)

        axes = Array.new
        var.dim_names.each{|dn|
          dim = var.dim(dn)
          dim.set_type(:reference)
          attr = Hash.new
          dim.att_names.each{|an| attr[an] = dim.att(an)}
          axpos = VArray.new(dim.val, attr, dn)
          axis = Axis.new(false, true)
          axis.set_pos(axpos)
          axes.push axis
        }

        grid = Grid.new(*axes)
        GPhys.new(grid, data)
      end

      def var_names(nusdas)
        opened = false
        case nusdas
        when String
          nusdas = NuSDaS.new(nusdas)
        when NuSDaS
          opened = true
        else
          raise ArgumentError, "arg must be NuSDaS or path name"
        end
        var_names = nusdas.var_names
        nusdas.close unless opened
        return var_names
      end
      alias :var_names_except_coordinates :var_names
      module_function :var_names_except_coordinates

    end
  end
end

