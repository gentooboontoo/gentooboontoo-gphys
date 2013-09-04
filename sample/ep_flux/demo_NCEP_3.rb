=begin
=demo_NCEP_3.rb 

  a demo program for drawing EP-Flux vector and Residual mean circulation.

USAGE
  % ruby demo_NCEP_3.rb

Note
  This program requires testdata. The URL is written in demo_NCEP_1.rb

=end

require 'numru/gphys'
require 'numru/gphys/ep_flux'
require 'numru/ggraph_on_merdional_section'
include NumRu

epflx_fnm = './epflx_NCEP.nc'

if File::exist?(epflx_fnm)

  epflx_y =   GPhys::IO.open(epflx_fnm,  'epflx_y')
  epflx_z =   GPhys::IO.open(epflx_fnm,  'epflx_z')
  epflx_div = GPhys::IO.open(epflx_fnm,  'epflx_div')
  v_rmean =   GPhys::IO.open(epflx_fnm,  'v_rmean')
  w_rmean =   GPhys::IO.open(epflx_fnm,  'w_rmean')
  strm_rmean =   GPhys::IO.open(epflx_fnm,  'strm_rmean')

else

  datadir = "./testdata/"
  gp_u =     GPhys::IO.open( datadir+"UWND_NCEP.nc",  "uwnd")
  gp_v =     GPhys::IO.open( datadir+"VWND_NCEP.nc",  "vwnd")
  gp_omega = GPhys::IO.open( datadir+"OMEGA_NCEP.nc", "omega")
  gp_t =     GPhys::IO.open( datadir+"TEMP_NCEP.nc",  "temp")
  
  epflx_y, epflx_z, v_rmean, w_rmean= ary =
    GPhys::EP_Flux::ep_full_sphere(gp_u, gp_v, gp_omega, gp_t, true)

  ary.each{|gp|                                  #  This part will not
    gp.data.att_names.each{|nm|                  #  be needed in future.
      gp.data.del_att(nm) if /^valid_/ =~ nm     #  (Even now, it is not
    }                                            #  needed if the valid
  }                                              #  range is wide enough)

  epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)
  strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)
  
end
  

DCL.gropn(1)
DCL::sglset('LFULL', true)                       # use full area
DCL::slrat(1.0, 0.85)                            # set aspect ratio of drwable area
DCL.sgpset('lcntl', false)                       # don't rede control character.
DCL.sgpset('lfprop',true)                        # use prportional font
DCL.uzfact(0.6)                                  # set character size

## show vector (Fy, Fz)
fy = epflx_y.mean('time')                        
fz = epflx_z.mean('time')                        
epdiv = epflx_div.mean('time')                   

GGraph::set_fig('view'=>[0.15, 0.85, 0.25, 0.55])
GGraph::set_fig('itr'=>2)                        # contour && tone only
GGraph::tone(epdiv)                              # tone
GGraph::contour(epdiv,false)                           # contour
xfact, yfact = GGraph::vector_on_merdional_section(fy, fz, false,
   'fact'=>3.0,'xintv'=>1,'unit'=>true, 'annot'=>false
				    )

## show residual mean merdional circulation (cut nearly surface and Antarctica)
vrm =  v_rmean.cut('lat'=>-70..90, 'level'=>850..100).mean('time')
wrm =  w_rmean.cut('lat'=>-70..90, 'level'=>850..100).mean('time')
strm = strm_rmean.cut('lat'=>-70..90, 'level'=>850..100).mean('time')
GGraph::contour(strm, true, 'nlev'=>25)
GGraph::vector_on_merdional_section(vrm, wrm, false,
	  	        'fact'=>2.0,'xintv'=>1,'unit'=>true, 'annot'=>false
				    )
DCL.grcls
