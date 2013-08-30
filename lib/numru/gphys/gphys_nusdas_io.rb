begin
  require "numru/nusdas"
rescue LoadError
  module NumRu
    class NuSDaS
      class << self
        def new(path)
          raise "nusdas library is not found"
        end
	alias :open :new
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

      def is_a_NuSDaS?(path)
        NuSDaS.is_a_NuSDaS?(path)
      end
      module_function :is_a_NuSDaS?

      def open(nusdas, varname)
        if String === nusdas
          nusdas = NuSDaS.new(nusdas)
        end
        unless NuSDaS === nusdas
          raise ArgumentError, "1st arg must be a NuSDaS of path name"
        end
        unless (meta = nusdas.instance_variable_get(:@meta)) && meta[:nbasetime] && meta[:nbasetime] > 0
          raise "NuSDaS directory is empty or nusdas_def is inconsistent with data: #{nusdas.path}"
        end

        var = nusdas.var(varname)
        var.nil? && raise("#{varname} is not found")
        data = VArrayNuSDaS.new(var)

        axes = Array.new
        dns = var.dim_names
        lonlat2d = dns.include?("lon") && var.dim("lon").val(:full).rank > 1
        dns.each{|dn|
          dim = var.dim(dn)
          attr = Hash.new
          dim.att_names.each{|an| attr[an] = dim.att(an)}
          dn << "_ref" if lonlat2d && /\A(lon|lat)\z/ =~ dn
          axpos = VArray.new(dim.val(:reference), attr, dn)
          axis = Axis.new(false, true)
          axis.set_pos(axpos)
          axes.push axis
        }
        grid = Grid.new(*axes)
        gphys = GPhys.new(grid, data)

        if lonlat2d
          puts "gphys_nusdas_io.rb: assoc_coords are introduced" if $DEBUG
          x = gphys.axis("lon_ref")
          y = gphys.axis("lat_ref")
          xy = Grid.new(x,y)
          vlon = VArray.new(var.dim("lon").val(:full), x.pos.attr_copy, "lon")
          vlat = VArray.new(var.dim("lat").val(:full), y.pos.attr_copy, "lat")
          glon = GPhys.new(xy, vlon)
          glat = GPhys.new(xy, vlat)
          tmp_assoc_coords = [glon,glat]
        end

        if var.dim_names.include?("z") && var.att("vertical_grid") =~ /[Zz]\*/ # Z* coordinate
          puts "gphys_nusdas_io.rb: assoc_coords are introduced" if $DEBUG
          if lonlat2d
            x = gphys.axis("lon_ref")
            y = gphys.axis("lat_ref")
          else
            x = gphys.axis("lon")
            y = gphys.axis("lat")
          end
          z = gphys.axis("z")
          xyz = Grid.new(x,y,z)
          zrp, zrw, vctrans_p, vctrans_w, dvtrans_p, dvtrans_w = var.dim("z").val(:full)
          zs = nusdas.var("ZSsrf") # terrain
          case zs.rank
          when 2
            na_zs = zs.get
          when 3
            na_zs = zs[true,true,0]
          else
            raise "BUG: rank of ZSsrf > 3"
          end
          na_zs = na_zs.newdim!(-1)
          z3d = na_zs + (1 + na_zs * dvtrans_p.newdim(0,0)) * zrp.newdim(0,0)
          vz3d = VArray.new(z3d, z.pos.attr_copy, "z3d")
          gz3d = GPhys.new(xyz, vz3d)
          tmp_assoc_coords ||= []
          tmp_assoc_coords.push(gz3d)
          gphys.set_att("zrp",zrp)
          gphys.set_att("zrw",zrw)
          gphys.set_att("vctrans_p",vctrans_p)
          gphys.set_att("vctrans_w",vctrans_w)
          gphys.set_att("dvtrans_p",dvtrans_p)
          gphys.set_att("dvtrans_w",dvtrans_w)
        end
        gphys.set_assoc_coords(tmp_assoc_coords) if tmp_assoc_coords

        return gphys
      end
      module_function :open

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
      module_function :var_names

      alias :var_names_except_coordinates :var_names
      module_function :var_names_except_coordinates

    end
  end
end

