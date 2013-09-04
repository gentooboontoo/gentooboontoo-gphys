require "numru/gphys/gphys"
require "numru/gphys/varraygrads"

=begin
=module NumRu::GPhys::GrADS_IO

helps read/write GrADS-formatted data

==Module functions
---is_a_GrADS?(filename)
    test whether the file is a GrADS control file.

    ARGUMENTS
    * filename (String): filename to test.

    RETURN VALUE
    * true/false

---open(file, varname)
    GPhys constructor from GrADS.

    ARGUMENTS
    * file (GrADS_Gridded or String): file to read. If string,
      it must be the name (path) of a GrADS control file. 
    * varname (String): name of the varible in the file, for which
      a GPhys object is constructed.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * Suppose that you have a file T.jan.ctl in the currentdirectly,
      and it contains a variable "T". The following creates a GPhys
      object representing the variable in the file.

        require "numru/gphys"
        include GPhys
        temp = GPhys::GrADS_IO.open("T.jan.ctl","T")

---write(file, gphys, name=nil)

    writes a GPhys object into a GrADS file. -- !!only 4D data is supported!!

---var_names(file)
    ARGUMENTS
    * file (GrADS_Gridded or String): if string,
      it must be the name (path) of a GrADS control file.

    RETURN VALUE
    * names of variables (Array): this return the names of variables
      which the file has.

---var_names_except_coordinates(file)
    same as var_names

=end

module NumRu
  class GPhys

    module GrADS_IO

      module_function

      def is_a_GrADS?(filename)
        file = nil
        begin
          file = File.open(filename)
          str = file.read(4)
        ensure
          file.close if file
        end
        return str=="DSET"
      end

      def open(file, varname)
        if file.is_a?(String)
          file = GrADS_Gridded.open(file)
        elsif ! file.is_a?(GrADS_Gridded)
          raise ArgumentError, "1st arg must be a GrADS_Gridded or a file name"
        end

        grvar = file.var(varname)
        data = VArrayGrADS.new(grvar)

#        axposnames = [ "lon", "lat", "lev", "time" ]
        axposnames = [ "x", "y", "z", "t" ]
        rank = 4
        bare_index = [ false ] * rank # will be true if coord var is not found

        axes = Array.new
        for i in 0...rank
          axpos = VArrayGrADS.new( file.var(axposnames[i]) )[0...data.shape_current[i]]

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
          
          #p "yet-to-be-defined: method to define aux coord vars"
          
          axes[i] = axis
        end

        grid = Grid.new( *axes )

        GPhys.new(grid,data)
      end

      def write(file, gphys, name=nil)
        if file.is_a?(String)
          file = GrADS_Gridded.open(file,"w")
        elsif ! file.is_a?(GrADS_Gridded)
          raise ArgumentError, "1st arg must be a GrADS_Gridded or a file name"
        end
        if( ! file.dset )
          bfname = file.path.gsub(/\.ctl/,"")+".dat"
          while( File.exist?(bfname) )
            bfname = bfname + "_"
          end
          file.dset = bfname
        end
        VArrayGrADS.write_control(file, gphys)
        VArrayGrADS.write_binary(file, gphys.data)
      end

      def var_names(file)
        opened = false
        case file
        when String
          file = GrADS_Gridded.open(file,"r")
        when GrADS_Gridded
          opened = true
        else
          raise ArgumentError, "arg must be a GrADS_Gridded or a file name"
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

   begin
     file = GrADS_Gridded.open("../../testdata/T.jan.ctl")
   rescue
     file = GrADS_Gridded.open("../../../testdata/T.jan.ctl")
   end
   temp = GPhys::GrADS_IO.open(file,"T")
   p temp.name, temp.shape_current
   temp2 = temp[true,true,2,0]
   p temp2.name, temp2.shape_current

   temp_xmean = temp.average(0)
   p temp.val

   temp_edy = ( temp - temp_xmean )
   p '$$$',temp_edy.name,temp_edy.val[0,true,true,0]
   p '@@@',temp
   p '///',temp.copy
   p '+++',temp2

   puts "\n** test write (tmp.nc) **"
   require "numru/gphys/gphys_netcdf_io"
   file2 = NetCDF.create('tmp.nc')
   p v = temp_edy.axis(0).pos[0..-2].copy.rename('lonlon')
   temp_edy.axis(0).set_aux('test',v)
   temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon2'))
   temp_edy.axis(0).set_aux('test2',(v/2).rename('lonlon3')[0..-2])
   GPhys::NetCDF_IO.write(file2,temp_edy)
   file2.close
   file3 = NetCDF.create('tmp2.nc')
   GPhys::NetCDF_IO.write(file3,temp_xmean)
   file3.close

   puts "\n** test write (tmp.ctl) **"
   file1 = GrADS_Gridded.create("tmp.ctl")
   file1.put_att("big_endian",true)
   file1.put_att("dset","tmp.dr")
   file1.put_att("title","test control file")
   file1.put_att("undef",-999.0)
   GPhys::GrADS_IO.write(file1,temp_edy)

end
