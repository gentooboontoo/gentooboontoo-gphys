=begin
=test.rb for module NumRu::GPhys::EP_Flux in ep_flux.rb

==todo
  * add draw code. 
=end

require 'narray'
require 'numru/gphys'
require 'numru/gphys/ep_flux'
require 'getopts'    # to use option

include NumRu
include NMath

########################################################
########          Define Test Methods           ########

## -----------------------------------------------------
#  preparation GPhys objects for test

def gen_gphys__W_and_Temp_in_z_coordinate(na_u,na_v,na_w,na_t,
                                                            na_lon,na_lat,na_z)
  ## make GPhys
  grid = make_grid_in_z(na_lon, na_lat, na_z)
  gp_u = GPhys.new(grid, make_va_u( na_u ))
  gp_v = GPhys.new(grid, make_va_v( na_v ))
  gp_w = GPhys.new(grid, make_va_w( na_w ))
  gp_t = GPhys.new(grid, make_va_t( na_t ))
  return gp_u, gp_v, gp_w, gp_t
end

def gen_gphys__W_and_Temp_in_p_coordinate(na_u,na_v,na_w,na_t,
                                                            na_lon,na_lat,na_p)
  ## make GPhys
  grid = make_grid_in_p(na_lon, na_lat, na_p)
  gp_u = GPhys.new(grid, make_va_u( na_u ))
  gp_v = GPhys.new(grid, make_va_v( na_v ))
  gp_w = GPhys.new(grid, make_va_w( na_w ))
  gp_t = GPhys.new(grid, make_va_t( na_t ))
  return gp_u, gp_v, gp_w, gp_t
end

def gen_gphys__Omega_and_Theta_in_z_coordinate(na_u,na_v,na_omega,na_theta,
                                                            na_lon,na_lat,na_z)
  ## make GPhys
  grid = make_grid_in_z(na_lon, na_lat, na_z)
  gp_u = GPhys.new(grid, make_va_u( na_u ))
  gp_v = GPhys.new(grid, make_va_v( na_v ))
  gp_omega = GPhys.new(grid, make_va_omega( na_omega ))
  gp_theta = GPhys.new(grid, make_va_theta( na_theta ))
  return gp_u, gp_v, gp_omega, gp_theta
end


def make_grid_in_z(na_lon, na_lat, na_z)
  va_lon = VArray.new( na_lon,
		   {"long_name"=>"longitude","units"=>"degrees"},
		     "lon" )
  va_lat = VArray.new( na_lat,
		   {"long_name"=>"latitude","units"=>"degrees"},
		     "lat" )
  va_z   = VArray.new( na_z,
		   {"long_name"=>"altitude","units"=>"m"},
		     "alt" )
  lon = Axis.new.set_pos(va_lon)
  lat = Axis.new.set_pos(va_lat)
  z = Axis.new.set_pos(va_z)
  return Grid.new(lon, lat, z)
end

def make_grid_in_p(na_lon, na_lat, na_p)
  va_lon = VArray.new( na_lon,
		   {"long_name"=>"longitude","units"=>"degrees"},
		     "lon" )
  va_lat = VArray.new( na_lat,
		   {"long_name"=>"latitude","units"=>"degrees"},
		     "lat" )
  va_p = VArray.new( na_p,
		   {"long_name"=>"pressure","units"=>"mb"},
		     "p" )
  lon = Axis.new.set_pos(va_lon)
  lat = Axis.new.set_pos(va_lat)
  pres = Axis.new.set_pos(va_p)
  return Grid.new(lon, lat, pres)
end

def make_va_u( na_u )
  VArray.new( na_u, {"long_name"=>"U","units"=>"m/s"}, "u" )
end
def make_va_v( na_v )
  VArray.new( na_v, {"long_name"=>"V","units"=>"m/s"}, "v" )
end
def make_va_w( na_w )
  VArray.new( na_w, {"long_name"=>"W","units"=>"m/s"}, "w" )
end
def make_va_omega( na_omega )
  VArray.new( na_omega, 
                    {"long_name"=>"Omega","units"=>"mb/s"}, "Omega" )
end
def make_va_t( na_t )
  VArray.new( na_t, {"long_name"=>"T","units"=>"K"},   "t" )
end
def make_va_theta( na_theta )
  VArray.new( na_theta, 
                    {"long_name"=>"Theta","units"=>"K"},   "theta" )
end

def gen_na_lon(nlon)
  NArray.float(nlon).indgen! / (nlon) * 360.0  # [0, ..., (360 - 1/nlon)]
end
def gen_na_lat(nlat)
  NArray.float(nlat).indgen! / (nlat - 1) * 180.0 - 90.0   # [90, .., -90]
end
def gen_na_z1(nz)
  NArray.sfloat(nz).indgen!/(nz-1)
end
def gen_na_z2(nz)
  1000 * 10 ** (-NArray.float(nz).indgen!/(nz-1))       # [1000, .., 100]
end

## -----------------------------------------------------
#  output method for error check

def print_error_ratio_max_and_mean(numerical_na, analytical_na)
  error_ratio = ((numerical_na - analytical_na).abs / ( analytical_na.abs ).max)
  print  "  error_ratio max,mean (for each alt):\n"
  for k in 0...error_ratio.shape[1]
    printf("%4s%10.5e%4s%10.5e%s", "", error_ratio[true,k,false].max(0),
                                   "", error_ratio[true,k,false].mean(0), "\n")
  end
end


## -----------------------------------------------------
#  output method for attribute check

def show_attr(gp)
  case gp.data.rank
  when 1
    fm = "%-15s%-20s%-10s%s"
    printf(fm, "  <attr_name>", "<data>", "<axis>", "\n")
    printf(fm, "    name", gp.data.name, gp.axis(0).pos.name, "\n")
    gp.data.att_names.each{|nm| 
      printf(fm, "    "+nm, gp.data.get_att(nm).to_s, 
                     gp.axis(0).pos.get_att(nm).to_s, "\n")
    }
  when 2
    fm = "%-15s%-20s%-10s%-10s%s"
    printf(fm, "  <attr_name>", "<data>", "<axis_y>", "<axis_z>", "\n")
    printf(fm, "    name", gp.data.name, 
	   gp.axis(0).pos.name,
	   gp.axis(1).pos.name,"\n")
    gp.data.att_names.each{|nm| 
      printf(fm, "    "+nm, gp.data.get_att(nm).to_s, 
	     gp.axis(0).pos.get_att(nm).to_s, 
	     gp.axis(1).pos.get_att(nm).to_s, "\n")
    }
  when 3
    fm = "%-15s%-20s%-10s%-10s%-10s%s"
    printf(fm, "  <attr_name>","<data>","<axis_x>","<axis_y>","<axis_z>", "\n")
    printf(fm, "    name", gp.data.name, 
	   gp.axis(0).pos.name,
	   gp.axis(1).pos.name,
	   gp.axis(2).pos.name,"\n")
    gp.data.att_names.each{|nm| 
      printf(fm, "    "+nm, gp.data.get_att(nm).to_s, 
	     gp.axis(0).pos.get_att(nm).to_s, 
	     gp.axis(1).pos.get_att(nm).to_s, 
	     gp.axis(2).pos.get_att(nm).to_s, "\n")
    }
  end
end

########################################################
########              Main Routine              ########


#############
## check netCDF output flag

unless getopts('n')
  print "#{$0}:illegal options. \n"
  exit 1
end
if $OPT_n
  nc_output_flag = true   # output test variable as NetCDF. 
else
  nc_output_flag = false  # not output NetCDF.
end


p "##############################################################"
p "####         << Section 1 -- test accesor method >>       ####"

# get DEFAULT constants
default_h         = GPhys::EP_Flux::scale_height
default_radius    = GPhys::EP_Flux::radius
default_rot       = GPhys::EP_Flux::rot_period
default_g         = GPhys::EP_Flux::g_forces
default_p00       = GPhys::EP_Flux::p00
default_cp        = GPhys::EP_Flux::cp
default_gas_const = GPhys::EP_Flux::gas_const

# set module constants
GPhys::EP_Flux::scale_height = UNumeric.new(1, "m")
GPhys::EP_Flux::radius       = UNumeric.new(1, "")
GPhys::EP_Flux::rot_period   = UNumeric.new(10, "rad/s")
GPhys::EP_Flux::g_forces     = UNumeric.new(1, "m.s-2")
GPhys::EP_Flux::p00          = UNumeric.new(1, "Pa")
GPhys::EP_Flux::cp           = UNumeric.new(1, "")
GPhys::EP_Flux::gas_const    = UNumeric.new(1, "")

# get GIVEN constants
h         = GPhys::EP_Flux::scale_height
radius    = GPhys::EP_Flux::radius
rot       = GPhys::EP_Flux::rot_period
g         = GPhys::EP_Flux::g_forces
p00       = GPhys::EP_Flux::p00
cp        = GPhys::EP_Flux::cp
gas_const = GPhys::EP_Flux::gas_const

# compare default and given values.
fm = "%-15s%15s%17s%s"   # format of output 

p "*********** compare default and given values ***********"
printf(fm, "  <name>",      "<default value>",    "<given value>","\n")
printf(fm, "  scale_height",  default_h.to_s,         h.to_s,         "\n")
printf(fm, "  radius",        default_radius.to_s,    radius.to_s,    "\n")
printf(fm, "  rot_period",    default_rot.to_s,       rot.to_s,       "\n")
printf(fm, "  g_forces",      default_g.to_s,         g.to_s,         "\n")
printf(fm, "  p00",           default_p00.to_s,       p00.to_s,       "\n")
printf(fm, "  cp",            default_cp.to_s,        cp.to_s,        "\n")
printf(fm, "  gas_const",     default_gas_const.to_s, gas_const.to_s, "\n")

# test ((<set_constants>)) and ((<get_constants>))
GPhys::EP_Flux::set_constants(default_h, default_radius, default_rot, 
                              default_g, default_p00, default_cp, 
                                                      default_gas_const)
                                # clean up after tests (backto default values)
h, radius, rot, g, p00, cp, gas_const = GPhys::EP_Flux::get_constants
p "*** test ((<set_constants>)) and ((<get_constants>)) ***"
printf(fm, "  <name>",     "<set_constants>",  "<get_constants>", "\n")
printf(fm, "  scale_height",  default_h.to_s,       h.to_s,         "\n")
printf(fm, "  radius",        default_radius.to_s,  radius.to_s,    "\n")
printf(fm, "  rot_period",    default_rot.to_s,     rot.to_s,       "\n")
printf(fm, "  g_forces",      default_g.to_s,       g.to_s,       "\n")
printf(fm, "  p00",           default_p00.to_s,     p00.to_s,     "\n")
printf(fm, "  cp",            default_cp.to_s,        cp.to_s,        "\n")
printf(fm, "  gas_const",     default_gas_const.to_s, gas_const.to_s, "\n")


p "##############################################################"
p "####         << Section 2 -- test deriv method >>         ####"

# preparate for testdata
n =  21
x =  exp(-NArray.sfloat(n).indgen!/(n-1))  # un-uniform grid
f =  NArray.sfloat(n).indgen!
ax = Axis.new.set_pos( VArray.new( x , 
                      {"long_name"=>"longitude", "units"=>"rad"},
		      "lon" ))
data = VArray.new( f,
      	         {"long_name"=>"temperature", "units"=>"K"},
	         "t" )
gp = GPhys.new(Grid.new(ax), data)

# threepoint_O2nd_deriv
dgp_dx =  GPhys::EP_Flux::deriv(gp, 0)    
dgp_dx2 = GPhys::Derivative::threepoint_O2nd_deriv(gp, 0)    
show_attr(dgp_dx)
err = ( dgp_dx.data.val - dgp_dx2.data.val )
p err.abs.max

# cderiv
GPhys::EP_Flux::set_deriv_method('cderiv')
dgp_dx =  GPhys::EP_Flux::deriv(gp, 0)
dgp_dx2 = GPhys::Derivative::cderiv(gp, 0)    
show_attr(dgp_dx)
err = ( dgp_dx.data.val - dgp_dx2.data.val )
p err.abs.max

GPhys::EP_Flux::set_deriv_method('cderiv') # backto default method

p "##############################################################"
p "####       << Section 3 -- test calculate method >>       ####"

############
## setup for making testdata 

### constants
GPhys::EP_Flux::scale_height = UNumeric.new(1, "m")
GPhys::EP_Flux::radius       = UNumeric.new(1, "m")
h, radius, rot, g, = GPhys::EP_Flux::get_constants
h = h.val; radius = radius.val; rot = rot.val
p00_Pa = GPhys::EP_Flux::p00.val
p00    = GPhys::EP_Flux::p00.convert( Units.new("mb") ).val
kappa = (GPhys::EP_Flux::gas_const / GPhys::EP_Flux::cp).val

### make NArray of axis
nlon = 100; nlat = 50; nz = 10
na_lon = gen_na_lon(nlon)
na_lat = gen_na_lat(nlat)
na_z = gen_na_z1(nz)
na_p = gen_na_z2(nz)
na_lambda = PI/180.0*na_lon              # convert deg => rad
na_phi = PI/180.0*na_lat                 # convert deg => rad
### make NArray of data  
# make axis term
to_3D = NArray.sfloat(nlon, nlat, nz).fill!(1.0)

sin_lambda = sin(na_lambda).reshape(nlon, 1, 1)
cos_phi    = cos(na_phi).reshape(1, nlat, 1)
sin_phi    = sin(na_phi).reshape(1, nlat, 1)
tan_phi    = sin_phi/cos_phi
z          = na_z.reshape(1, 1, nz)
p          = na_p.reshape(1, 1, nz)
eddy       = ( sin_lambda * cos_phi * to_3D)      # common eddy term

# make each data na in z
na_u = 1.0 * eddy + 10 + z
na_v = 2.0 * eddy + 20
na_w = 3.0 * eddy + 30
na_t = 4.0 * eddy + 40
na_omega = ( 3.0 * eddy + 30 ) * -p00/h * exp(-z/h)
na_theta = ( 4.0 * eddy + 40 ) * exp(kappa*z/h)

# make each data na in p
na_u_p = 1.0 * eddy + 10 + p
na_v_p = na_v
na_w_p = na_w
na_t_p = na_t


p "--------------------------------------------------------------"
p "====            pattern 1: W, T in z-coordinate           ===="
p "--------------------------------------------------------------"

# generate test GPhys objects.
gp_u, gp_v, gp_w, gp_t = \
      gen_gphys__W_and_Temp_in_z_coordinate(na_u, na_v, na_w, na_t, 
                                                  na_lon, na_lat, na_z)

# calculate EP Flux, etc.
( epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, gp_z, 
    u_mean, theta_mean, 
    uv_dash, vt_dash, uw_dash, dtheta_dz) = \
                   GPhys::EP_Flux::ep_full_sphere(gp_u,gp_v,gp_w,gp_t,true)

# calculate EP Flux divergence
epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)

# calculate Residual merdional mean circulation
strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)

# analytical functions. (these are not smart code.)
f = 2*2*PI/rot*sin_phi
sig_cos3 = exp( -z/h )*cos_phi**3
avort = ( f + (10 + z)/radius*tan_phi )
epflx_y_ana = (sig_cos3 * ( h/(10.0*kappa) - 1 )).reshape(nlat,nz)
epflx_z_ana = (sig_cos3 * ( avort* h/(10.0*kappa) - 1.5 )).reshape(nlat,nz)
u_mean_ana     = 10 + na_z.reshape(1,nz)
theta_mean_ana = 40 * exp(kappa*na_z.reshape(1,nz)/h)
uv_dash_ana    = cos(na_phi.reshape(nlat, 1))**2
vt_dash_ana    = 4* cos(na_phi.reshape(nlat, 1))**2 * exp(kappa*na_z.reshape(1,nz)/h)
uw_dash_ana    = 1.5 * cos(na_phi.reshape(nlat, 1))**2
dtheta_dz_ana  = 40 * kappa/h * exp(kappa*na_z.reshape(1,nz)/h)
epflx_div_ana  = ( exp( -z/h )*(-4)*(cos_phi**2)*sin_phi/radius * ( h/(10.0*kappa) - 1 )).reshape(nlat,nz) \
             - epflx_z_ana/h + (( exp( -z/h )*( cos_phi**2 *sin_phi) ) / radius  * h/(10.0*kappa)).reshape(nlat,nz)
v_rmean_ana =    20 + cos(na_phi.reshape(nlat, 1))**2/10/kappa
w_rmean_ana =    30 + 3*h*cos(na_phi.reshape(nlat, 1))*sin(na_phi.reshape(nlat, 1))/10/radius/kappa
na_zp = p00_Pa*exp(-z/h).reshape(1, nz)
strm_rmean_ana   = v_rmean_ana * 2 * PI * radius * cos(na_phi.reshape(nlat, 1))  * (na_zp - na_zp[-1])/g.val + v_rmean_ana[-1] * PI * radius * cos(na_phi.reshape(nlat, 1))  * na_zp[-1]/g.val


### check_precision_and_attribute
["epflx_y", "epflx_z", "v_rmean", "w_rmean", "u_mean", "theta_mean", 
  "uv_dash", "vt_dash", "uw_dash", "dtheta_dz", "epflx_div", "strm_rmean"].each { |gp_nm|
  gp = eval(gp_nm)              # ex. "epflx_y" => epflx_y
  gp_ana = eval(gp_nm+"_ana")   # ex. "epflx_y" => epflx_y_na
  title = gp.data.get_att("long_name").to_s
  p "***************** #{title} *****************"
  show_attr(gp)
  print_error_ratio_max_and_mean(gp.data.val, gp_ana)
}  

p "--------------------------------------------------------------"
p "====       pattern 2: Omega, Theta in z-coordinate        ===="
p "--------------------------------------------------------------"

gp_u, gp_v, gp_omega, gp_theta = \
    gen_gphys__Omega_and_Theta_in_z_coordinate(na_u, na_v, na_omega, na_theta,
                                                          na_lon, na_lat, na_z)
( epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, gp_z, 
    u_mean, theta_mean, 
    uv_dash, vt_dash, uw_dash, dtheta_dz) = \
              GPhys::EP_Flux::ep_full_sphere(gp_u,gp_v,gp_omega,gp_theta,false)

epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)

# calculate Residual merdional mean circulation
strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)

## analytical functions
f = 2*2*PI/rot*sin_phi
sig_cos3 = exp( -z/h )*cos_phi**3
avort = ( f + (10 + z)/radius*tan_phi )
epflx_y_ana = (sig_cos3 * ( h/(10.0*kappa) - 1 )).reshape(nlat,nz)
epflx_z_ana = (sig_cos3 * ( avort* h/(10.0*kappa) - 1.5 )).reshape(nlat,nz)
u_mean_ana     = 10 + na_z.reshape(1,nz)
theta_mean_ana = 40 * exp(kappa*na_z.reshape(1,nz)/h)
uv_dash_ana    = cos(na_phi.reshape(nlat, 1))**2
vt_dash_ana    = 4* cos(na_phi.reshape(nlat, 1))**2 * exp(kappa*na_z.reshape(1,nz)/h)
uw_dash_ana    = 1.5 * cos(na_phi.reshape(nlat, 1))**2
dtheta_dz_ana  = 40 * kappa/h * exp(kappa*na_z.reshape(1,nz)/h)
epflx_div_ana = ( exp( -z/h )*-4*cos_phi**2*sin_phi/radius * ( h/(10.0*kappa) - 1 )).reshape(nlat,nz) \
                - epflx_z_ana/h + \
                (( exp( -z/h )*(cos_phi**2 * sin_phi) ) /radius  * h/(10.0*kappa)).reshape(nlat,nz)
v_rmean_ana =    20 + cos(na_phi.reshape(nlat, 1))**2/10/kappa
w_rmean_ana =    30 + 3*h*cos(na_phi.reshape(nlat, 1))*sin(na_phi.reshape(nlat, 1))/10/radius/kappa
na_zp = p00_Pa*exp(-z/h).reshape(1, nz)
#strm_rmean_ana = v_rmean_ana * 2 * PI * radius * cos(na_phi.reshape(nlat, 1))  * na_zp/g.val 
strm_rmean_ana   = v_rmean_ana * 2 * PI * radius * cos(na_phi.reshape(nlat, 1))  * (na_zp - na_zp[-1])/g.val + v_rmean_ana[-1] * PI * radius * cos(na_phi.reshape(nlat, 1))  * na_zp[-1]/g.val

### check_precision_and_attribute
["epflx_y", "epflx_z", "v_rmean", "w_rmean", "u_mean", "theta_mean", 
  "uv_dash", "vt_dash", "uw_dash", "dtheta_dz", "epflx_div", "strm_rmean"].each { |gp_nm|
  gp = eval(gp_nm)              # ex. "epflx_y" => epflx_y
  gp_ana = eval(gp_nm+"_ana")   # ex. "epflx_y" => epflx_y_na
  title = gp.data.get_att("long_name").to_s
  p "***************** #{title} *****************"
  show_attr(gp)
  print_error_ratio_max_and_mean(gp.data.val, gp_ana)
}  

p "--------------------------------------------------------------"
p "====            pattern 3: W, T in p-coordinate           ===="
p "--------------------------------------------------------------"

gp_u, gp_v, gp_w, gp_t = \
    gen_gphys__W_and_Temp_in_p_coordinate(na_u_p, na_v_p, na_w_p, na_t_p,
                                                          na_lon, na_lat, na_p)
( epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, gp_z, 
    u_mean, theta_mean, 
    uv_dash, vt_dash, uw_dash, dtheta_dz) = \
              GPhys::EP_Flux::ep_full_sphere(gp_u,gp_v,gp_w,gp_t,true)

epflx_div = GPhys::EP_Flux::div_sphere(epflx_y, epflx_z)
# calculate Residual merdional mean circulation
strm_rmean = GPhys::EP_Flux::strm_rmean(v_rmean)

## analytical functions
f = 2*2*PI/rot*sin_phi
avort = ( f + (10 + p)/radius*tan_phi )
epflx_y_ana = (( p/p00 * cos_phi**3 ) * ( -p/(10.0*kappa) - 1 )).reshape(nlat,nz)
epflx_z_ana = (( p/p00 * cos_phi**3 ) * ( avort * h/(10.0*kappa) - 1.5 )).reshape(nlat,nz)
u_mean_ana     = 10 + na_p.reshape(1,nz)
theta_mean_ana = ( 40 * (p00/na_p.reshape(1,nz))**kappa )
uv_dash_ana    = cos(na_phi.reshape(nlat, 1))**2
vt_dash_ana    = ( 4* cos(na_phi.reshape(nlat, 1))**2 * (p00/na_p.reshape(1,nz))**kappa ).reshape(nlat,nz)
uw_dash_ana    = 1.5 * cos(na_phi.reshape(nlat, 1))**2
dtheta_dz_ana  = theta_mean_ana / h * kappa
epflx_div_ana = ( p/p00*-4*cos_phi**2*sin_phi/radius * ( -p/(10.0*kappa) - 1 )).reshape(nlat,nz) - epflx_z_ana/h + \
               ((-p**2/p00/h*cos_phi**2 ) * ( sin_phi/radius ) * h/(10.0*kappa)).reshape(nlat,nz)
v_rmean_ana =    20 + cos(na_phi.reshape(nlat, 1))**2/10/kappa
w_rmean_ana =    30 + 3*h*cos(na_phi.reshape(nlat, 1))*sin(na_phi.reshape(nlat, 1))/10/radius/kappa
strm_rmean_ana   = v_rmean_ana * 2 * PI * radius * cos(na_phi.reshape(nlat, 1))  * (na_p.reshape(1, nz) - na_p[-1])*100/g.val + v_rmean_ana[-1] * PI * radius * cos(na_phi.reshape(nlat, 1))  * na_p[-1]*100/g.val

### check_precision_and_attribute
["epflx_y", "epflx_z", "v_rmean", "w_rmean", "u_mean", "theta_mean", 
  "uv_dash", "vt_dash", "uw_dash", "dtheta_dz", "epflx_div", "strm_rmean"].each { |gp_nm|
  gp = eval(gp_nm)              # ex. "epflx_y" => epflx_y
  gp_ana = eval(gp_nm+"_ana")   # ex. "epflx_y" => epflx_y_na
  title = gp.data.get_att("long_name").to_s
  p "***************** #{title} *****************"
  show_attr(gp)
  print_error_ratio_max_and_mean(gp.data.val, gp_ana)
}  


p "--------------------------------------------------------------"
p "====      pattern 4: check div_sphere with easy data      ===="
p "--------------------------------------------------------------"

## make axis
nlat = 50; nz = 10
na_lat = NArray.float(nlat).indgen! / (nlat - 1) * 180.0 - 90.0 # [-90, .., 90]
p  ( na_z   = 1000 * (NArray.float(nz).indgen!/(nz-1))  )      # [1000, .., 100]
va_lat = VArray.new( na_lat,
		    {"long_name"=>"latitude","units"=>"degrees"},
		    "lat" )
va_z = VArray.new( na_z,
		  {"long_name"=>"alt","units"=>"m"},
		  "z" )
lat = Axis.new.set_pos(va_lat)
  z = Axis.new.set_pos(va_z)
grid = Grid.new(lat, z)

## make data
na_phi = PI/180.0*na_lat
na_z1 = na_z.dup.fill(1.0)
na_f_phi = 1.0  * cos(na_phi.reshape(nlat, 1)) * (na_z1).reshape(1, nz)
na_f_z   = 3.0  * na_z.newdim(0) * cos(na_phi).reshape(nlat, 1)

va_f_phi = VArray.new( na_f_phi,
		      {"long_name"=>"epflx_y","units"=>"m2.s-2"},
		      "epy" )
va_f_z = VArray.new( na_f_z,
		    {"long_name"=>"epflx_z","units"=>"m2.s-2"},
		    "epz" )

gp_f_phi = GPhys.new(grid, va_f_phi)
gp_f_z = GPhys.new(grid, va_f_z)

kappa = (GPhys::EP_Flux::gas_const / GPhys::EP_Flux::cp).val
p00  = GPhys::EP_Flux::p00
scale_height  = GPhys::EP_Flux::scale_height
rot_period  = GPhys::EP_Flux::rot_period
radius  = GPhys::EP_Flux::radius


na_z = na_z.reshape(1, nz)
na_phi = na_phi.reshape(nlat, 1)
p "*** epflx_div  ***"
epflx_div = GPhys::EP_Flux::div_sphere(gp_f_phi, gp_f_z)
epflx_div_ana = -2*sin(na_phi) + 3 * cos(na_phi)

### check divergence
title = epflx_div.data.get_att("long_name").to_s
p "***************** #{title} *****************"
show_attr(epflx_div)
print_error_ratio_max_and_mean(epflx_div.data.val, epflx_div_ana)

