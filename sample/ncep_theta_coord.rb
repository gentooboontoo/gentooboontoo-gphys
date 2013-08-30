# = Sample program to use GPhys#interpolation by using NCEP reanalysis data
#
# USAGE 
# 
#   % ruby ncep_theta_coord.rb [data_directory [varname [year [day_of_yr_from0]]]]
# 
# COMMAND-LINE OPTIONS
# 
# * data_directory : directory where the NCEP data situated -- by default
#   an existing OPeNDAP directory is specified -- so it should work, 
#   though it may be slow for network data transfer.
# * others : you can guess -- see the source code.
#
# DESCRIPTION
#
# Here are two samples: one is a simple interpolation along a coordinate
# and the other is a coordinate transformation from pressure to potential
# temperature (isentropic coordinate).
 
require "numru/ggraph"
include NumRu


dir = ARGV[0] || "http://db-dods.rish.kyoto-u.ac.jp/cgi-bin/nph-dods/ncep/ncep.reanalysis.dailyavgs/pressure"

vname = ARGV[1] || "uwnd"   # name of the variable to be interpolated

year = ARGV[2] || 2008
iday = ( ARGV[3] || 0 ).to_i  # day of the year


xsel = 0
temp = GPhys::IO.open(dir+"/air.#{year}.nc","air")[xsel,false,2..-1,iday]
gp = GPhys::IO.open(dir+"/#{vname}.#{year}.nc",vname)[xsel,false,2..-1,iday]

prs = temp.axis("level").to_gphys
p00 =  UNumeric[1000.0, "millibar"]
kappa = 2.0 / 7.0
pfact = (prs/p00)**(-kappa)

theta = temp * pfact
theta.name = "theta"
theta.long_name = "potential theta"

gp.set_assoc_coords([theta])

tht_crd = VArray.new( NArray[300.0,350.0, 400.0, 500.0, 700.0, 800.0] ).rename("theta")
gp_ontht = gp.interpolate("level"=>tht_crd)

p_crd = VArray.new( NArray[25.0, 15.0] ).rename("level")
p_crd.units = "hPa"
gp_onp = gp.interpolate(p_crd)   # 1D: same as interpolate("level"=>p_crd)

DCL.swpset('iwidth',800)
DCL.swpset('iheight',800)

DCL.gropn(1)
DCL.sgpset('isub', 96)      # control character of subscription: '_' --> '`'
DCL.glpset('lmiss',true)
DCL.sldiv('y',2,2)

GGraph::set_fig "itr"=>2

GGraph::tone_and_contour theta[false],true,"int"=>50
GGraph::color_bar

GGraph::tone_and_contour gp[false],true
GGraph::color_bar

GGraph::set_fig "itr"=>1

GGraph::tone_and_contour gp_onp[false],true,"keep"=>true
GGraph::color_bar

GGraph::tone_and_contour gp_ontht[false],true,"keep"=>true
GGraph::color_bar


DCL.grcls
