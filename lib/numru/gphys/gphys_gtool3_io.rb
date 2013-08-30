require "numru/gphys/gphys"
require "numru/gphys/varraygtool3"

=begin
=module NumRu::GPhys::Gtool3_IO

helps read/write Gtool3-formatted data

==Module functions
---is_a_Gtool3?(filename)
    test whether the file is a Gtool3 control file.

    ARGUMENTS
    * filename (String): filename to test.

    RETURN VALUE
    * true/false

---open(file, varname)
    GPhys constructor from Gtool3.

    ARGUMENTS
    * file (Gtool3 or String): file to read. If string,
      it must be the name (path) of a Gtool3 control file. 
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
        temp = GPhys::Gtool3_IO.open("T.jan.ctl","T")

#---write(file, gphys, name=nil)
#
#    writes a GPhys object into a Gtool3 file. -- !!only 4D data is supported!!

---var_names(file)
    ARGUMENTS
    * file (Gtool3 or String): if string,
      it must be the name (path) of a Gtool3 control file.

    RETURN VALUE
    * names of variables (Array): this return the names of variables
      which the file has.

---var_names_except_coordinates(file)
    same as var_names

=end

module NumRu
  class GPhys

    module Gtool3_IO

      module_function

      @@default_calendar = nil  #  e.g., "360_day"
      def default_calendar=(cal)
        @@default_calendar = cal
      end
      def default_calendar
        @@default_calendar
      end

      def is_a_Gtool3?(filename)
        Gtool3.is_a_Gtool3?(filename)
      end

      def open(file, varname)
        if file.is_a?(String)
          file = Gtool3.open(file)
        elsif ! file.is_a?(Gtool3)
          raise ArgumentError, "1st arg must be a Gtool3 or a file name"
        end

        var = file.var(varname)
        data = VArrayGtool3.new(var)

        axes = Array.new
        for i in 0...var.rank
          gax = var.axis(i)
          gloc = gax["LOC"]
          if gloc["ITEM"]=="time"
            loc = VArrayGtool3Time.new(gloc, @@default_calendar)
          else
            loc = VArrayGtool3.make_coord(gloc)
          end
#          if (gwgt = gax("WGT"))
#            wgt = VArray.new(gwgt.delete(:val), gwgt, gwgt.delete("ITEM"))
#            cell_center = true
#            cell = true
#          else
            cell = false
#          end

          axis = Axis.new(cell,false)
          if !cell
            axis.set_pos( loc )
          end
          
          axes[i] = axis
        end

        grid = Grid.new( *axes )

        GPhys.new(grid,data)
      end

#      def write(file, gphys, name=nil)
#      end

      def var_names(file)
        opened = false
        case file
        when String
          file = Gtool3.open(file,"r")
        when Gtool3
          opened = true
        else
          raise ArgumentError, "arg must be a Gtool3 or a file name"
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
  Gtool3.gtaxdir = File.expand_path("~/dennou/GTAXDIR")
  file = ARGV[0]
  varname = ARGV[1] or raise("Need two args")

  gp = GPhys::Gtool3_IO.open(file,varname)
  GPhys::Gtool3_IO.default_calendar = "360_day"

  p gp 
  p gp[false,0].val
  p gp[false,0,0].copy
  print "\n****\n"
  gp.att_names.each{|k| print k,"   ",gp.get_att(k),"\n"}
  print "\n******\n"
  p gp.coord(0).name
  gp.coord(0).att_names.each{|k| print k,"   ",gp.get_att(k),"\n"}
  p gp.coord(-1).name
  gp.coord(-1).att_names.each{|k| print k,"   ",gp.get_att(k),"\n"}
end
