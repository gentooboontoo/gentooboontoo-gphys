=begin
=gpcommon.rb

 This library provides common methods used in gp* command. 

==METHOD LIST

  * help                           : print help message

  * NumRu::Netcdf.copy_global_att  : Copy global attributes from a Gphys 
                                     variable. It operates only when a gphys 
                                     variable consist of a NetCDF file.

==HISTORY

  2005/08/23  S Takehiro (created)
  2008/02/14  S Takehiro (copy_global_att can deal with GPhys 
                          which consists of multiple files)

=end

#------------------------ print help message ------------------------
def help
  file = File.open($0)
  after_begin = false
  after_end = false
  while (line = file.gets)
    after_end = true if /^=end/ =~ line
    print line if after_begin && !after_end
    after_begin = true if /^=begin/ =~ line
  end
  file.close
end

#------------- Copy global attributes (only for NetCDF file) --------
class NumRu::NetCDF
  def copy_global_att(gp)
    ncfiles = gp.data.file 
    # for gphys consisting of multiple files 
    if /NArray/  =~ ncfiles.class.to_s  
      ncfile = ncfiles[0]
    else
      ncfile = ncfiles
    end
    # Check whether gphys is a NetCDF file or not
    if /NetCDF/  =~ ncfile.class.to_s
      ncfile.each_att{|att|
        att.copy(self)
      }
    end
  end
end
