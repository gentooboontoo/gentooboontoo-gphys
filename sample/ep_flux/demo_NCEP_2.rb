=begin
=demo_NCEP_2.rb 

  a demo program with GPhys::NetCDF_IO::each_along_dims_write, which 
  is Iterator to process GPhys objects too big to read on memory at once.
  this program show same performance with demo_NCEP_1.rb.

USAGE
  % ruby demo_NCEP_2.rb

Note
  This program requires testdata. The URL is written in demo_NCEP_1.rb

=end

require 'numru/gphys'
require 'numru/gphys/ep_flux'
include NumRu

datadir = "./testdata/"
gp_u =     GPhys::IO.open( datadir+"UWND_NCEP.nc",  "uwnd")
gp_v =     GPhys::IO.open( datadir+"VWND_NCEP.nc",  "vwnd")
gp_omega = GPhys::IO.open( datadir+"OMEGA_NCEP.nc", "omega")
gp_t =     GPhys::IO.open( datadir+"TEMP_NCEP.nc",  "temp")

ofile = NetCDF.create("epflx_NCEP.nc")

nt = gp_u.shape[-1]
i = 0
GPhys::IO.each_along_dims_write([gp_u, gp_v, gp_omega, gp_t], ofile, -1){
  |u, v, omega, t|
  i += 1
  print "processing #{i} / #{nt} ..\n" if (i % (nt/20+1))==1

  epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, gp_z, u_mean, theta_mean,
        uv_dash, vt_dash, uw_dash, dtheta_dz = ary =
                GPhys::EP_Flux::ep_full_sphere(u, v, omega, t, true)

  ary.each{|gp|                                  #  This part will not
    gp.data.att_names.each{|nm|                  #  be needed in future.
      gp.data.del_att(nm) if /^valid_/ =~ nm     #  (Even now, it is not
    }                                            #  needed if the valid
  }                                              #  range is wide enough)

  epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)
  strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)

  if i==1    # time independent => write only once
    gp_lat.rename('phi')
    GPhys::IO.write(ofile, gp_lat)
    GPhys::IO.write(ofile, gp_z)
  end
  [ epflx_y, epflx_z, v_rmean, w_rmean, strm_rmean, epflx_div, u_mean, theta_mean,
    uv_dash, vt_dash, uw_dash, dtheta_dz ]
}

ofile.close
