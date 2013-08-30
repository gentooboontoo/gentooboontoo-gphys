=begin
=demo_NCEP_1.rb 

  a demo program for GPhys::EP_Flux. show sample code to for calculating
  EP-Flux and other physical values, and save as a NetCDF file.

USAGE
  % ruby demo_NCEP_1.rb

Note
  This program requires testdata. The URL is 

    http://dennou-k.gfd-dennou.org/arch/ruby/products/ep_flux/testdata.tar.gz

=end

require 'numru/gphys'
require 'numru/gphys/ep_flux'
include NumRu

datadir = "./testdata/"
gp_u =     GPhys::IO.open( datadir+"UWND_NCEP.nc",  "uwnd")
gp_v =     GPhys::IO.open( datadir+"VWND_NCEP.nc",  "vwnd")
gp_omega = GPhys::IO.open( datadir+"OMEGA_NCEP.nc", "omega")
gp_t =     GPhys::IO.open( datadir+"TEMP_NCEP.nc",  "temp")

epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, = ary =
          GPhys::EP_Flux::ep_full_sphere(gp_u, gp_v, gp_omega, gp_t, true)
gp_lat.rename('phi')

ary.each{|gp|                                  #  This part will not
  gp.data.att_names.each{|nm|                  #  be needed in future.
    gp.data.del_att(nm) if /^valid_/ =~ nm     #  (Even now, it is not
  }                                            #  needed if the valid
}                                              #  range is wide enough)

epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)
strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)

ofile = NetCDF.create("epflx_NCEP.nc")

ary.each{|gp|
  GPhys::IO.write(ofile, gp)
}
GPhys::IO.write(ofile, epflx_div)
GPhys::IO.write(ofile, strm_rmean)

ofile.close
