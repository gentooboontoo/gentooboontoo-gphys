require "numru/gphys/gphys"
require "numru/gphys/varraygrib"

=begin
=module NumRu::GPhys::Grib_IO

helps read Grib-formatted data

==Module functions
---is_a_Grib? filename)
    test whether the file is a Grib file.

    ARGUMENTS
    * filename (String): filename to test.

    RETURN VALUE
    * true/false

---open(file, varname)
    GPhys constructor from Grib.

    ARGUMENTS
    * file (Grib or String): file to read. If string,
      it must be the name (path) of a Grib file. 
    * varname (String): name of the varible in the file, for which
      a GPhys object is constructed.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * Suppose that you have a file temp in the currentdirectly,
      and it contains a variable "T". The following creates a GPhys
      object representing the variable in the file.

        require "numru/gphys"
        include GPhys
        temp = GPhys::Grib_IO.open("temp","T")

---write(file, gphys, name_dummy=nil)

    Write a GPhys into a Grib file. The whole data under the GPhys 
    (such as coordinate vars) are written self-descriptively.

    ARGUMENTS
    * file (Grib): the Grib file to write in. Must be writable of course.
    * gphys (GPhys): the GPhys to write.
    * name_dummy (nil) : Unused in this module; Just for consistency with others.

    RETURN VALUE
    * nil

---var_names(file)
    ARGUMENTS
    * file (Grib or String): if string,
      it must be the name (path) of a Grib file.

    RETURN VALUE
    * names of variables (Array): this return the names of variables
      which the file has.

---var_names_except_coordinates(file)
    * same as var_names

=end

module NumRu
  class GPhys

    module Grib_IO

      module_function

      def is_a_Grib?(filename)
        VArrayGrib.grib.is_a_Grib?(filename)
      end

      def open(file, varname)
        if file.is_a?(String)
          file = VArrayGrib.grib.open(file)
        elsif ! VArrayGrib.grib===file
          raise ArgumentError, "1st arg must be a Grib or a file name"
        end

        var = file.var(varname)
        var.nil? && raise("variable '#{varname}' not found in '#{file.path}'")
        data = VArrayGrib.new(var)

        rank = data.rank
        bare_index = [ false ] * rank # will be true if coord var is not found


        axes = Array.new
        var_names = file.var_names
        for i in 0...rank
          dim = var.dim(i)
          val = dim.get
          if Array===val && val.length!=1
            bare_index[i] = true
          end
          axpos = VArrayGrib.new( dim )
          cell_center = true
          cell = false

          axis = Axis.new(cell,bare_index[i])
          if !cell
            axis.set_pos( axpos )
          else
            if cell_center
              if varray_cell_bounds
                axis.set_cell(axpos, varray_cell_bounds).set_pos_to_center
              else
                p "cell bounds are guessed"
                axis.set_cell_guess_bounds(axpos).set_pos_to_center
              end
            else  # then it is cell_bounds
              if varray_cell_center
                axis.set_cell(varray_cell_center, axpos).set_pos_to_bounds
              else
                p "cell center is guessed"
                axis.set_cell_guess_center(axpos).set_pos_to_bounds
              end
            end
          end
          if Array===val && val.length!=1
            val[1..-1].each{|hash|
              va = 
	      va = VArray.new(hash["value"],nil,hash["name"])
	      hash.each{|k,v|
		next if k=="value"||k=="name"
		va.put_att(k,v)
              }
              axis.set_aux(hash["name"],va)
            }
          end
          
          #p "yet-to-be-defined: method to define aux coord vars"
          
          axes[i] = axis
        end

        grid = Grid.new( *axes )

        GPhys.new(grid,data)
      end

      def write(file, gphys, name_dummy=nil)
        dims = Array.new
        gphys.rank.times{|n|
          dims[n] = gphys.coord(n)
        }
        VArrayGrib.write(file,gphys.data,dims)
        nil
      end

      def var_names(file)
        opened = false
        case file
        when String
          file = VArrayGrib.grib.open(file)
        when VArrayGrib.grib
          opened = true
        else
          raise ArgumentError, "arg must be a Grib or a file name"
        end
        var_names = file.var_names
        file.close unless opened
        return var_names
      end
      def var_names_except_coordinates(file)
	var_names(file)
      end


    end
  end
end

######################################################
if $0 == __FILE__
  include NumRu
  require "numru/gphys/gphys_netcdf_io"

  temp = GPhys::Grib_IO.open("../../../testdata/T.jan.grib","TMP")
  p temp.name, temp.shape_current
  temp2 = temp[true,true,2]
  p temp2.name, temp2.shape_current

  temp_xmean = temp.average(0)
  p temp.val

  temp_edy = ( temp - temp_xmean )
  p '$$$',temp_edy.name,temp_edy.val[0,true,true]
  p '@@@',temp
  p '///',temp.copy
  p '+++',temp2

  puts "\n** test convert (T.jan.nc to tmp.grib) **"
  temp3 = GPhys::NetCDF_IO.open("../../../testdata/T.jan.nc","T")
  file = VArrayGrib.grib.create("tmp.grib")
  GPhys::Grib_IO.write(file,temp3)
  file.close

  puts "\n** test compare (T.jan.nc and tmp.grib) **"
  temp4 = GPhys::Grib_IO.open("tmp.grib","TMP")
  p temp3.val
  p temp4.val
  print "max    => #{temp3.max}, and #{temp4.max}\n"
  print "min    => #{temp3.min}, and #{temp4.min}\n"
  print "mean   => #{temp3.mean}, and #{temp4.mean}\n"
  print "stddev => #{temp3.stddev}, and #{temp4.stddev}\n"


end
