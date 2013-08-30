require 'narray'
require 'numru/gphys/derivative'


############################################################

=begin
=module NumRu::GPhys::EP_Flux in ep_flux.

==Testprogram
Test script path is 'test/test_ep_flux.rb' in expand dir of gphys.tar.gz.

==Index
* ((<module NumRu::GPhys::EP_Flux>))
  * ((<Functions:>))
    * ((<ep_full_sphere>))
      * calculate EP Flux with full set equations on spherical coordinate.
    * ((<div_sphere>))
      * calculate divergence on spherical coordinate, Not only for EP Flux!
    * ((<strm_rmean>))
      * calculate residual mass stream function in spherical coordinate
        (it might be good precision, but enough test has not done yet.)
    * ((<scale_height>)) 
      * get the scale height.
    * ((<scale_height=>))
      * set the scale height.
    * ((<radius>))
      * get the radus of planet.
    * ((<radius=>))
      * set the radus of planet.
    * ((<rot_period>))
      * get the rotation period of planet.
    * ((<rot_period=>))
      * set the rotation period of planet.
    * ((<g_forces>))
      * get the gravitational acceleration in surface.
    * ((<g_forces=>))
      * set the gravitational acceleration in surface.
    * ((<p00>))
      * get the reference surface pressure.
    * ((<p00=>))
      * set the reference surface pressure.
    * ((<cp>))
      * get the the specific heat at constant pressure of the atmosphere.
    * ((<cp=>))
      * set the the specific heat at constant pressure of the atmosphere.
    * ((<gas_const>))
      * get the specific heat at constant pressure of the atmosphere.
    * ((<gas_const=>))
      * set the specific heat at constant pressure of the atmosphere.
    * ((<get_constants>))
      * get the module variables
    * ((<set_constants>))
      * set the module variables
    * ((<make_gphys>))
      * convert ((<Axis>)) to ((<GPhys>)).
    * ((<to_w_if_omega>))
      * convert to velocity if ((<gp>)) is pressure velocity.
    * ((<to_z_if_pressure>))
      * convert to altitude if ((<gp>)) is pressure.
    * ((<to_p_if_altitude>))
      * convert to pressure if ((<gp>)) is altitude.
    * ((<to_theta_if_temperature>))
      * convert to potential temperature of temperature if ((<flag>)) is true.
    * ((<to_rad_if_deg>))
      * convert to radian if ((<gp>)) is degrees.
    * ((<eddy_products>))
      * calculate eddy flux respect to ((<dimname>)).
    * ((<remove_0_at_poles>))
      * set value if the cos(phi) is 0 at poles (phi is latitude).
    * ((<preparate_for_vector_on_merdional_section>))
      * preparate for ((<GGraph::vector_on_merdional_section>)) 
        in vector_on_merdional_section.rb
  * ((<Constants:>))
    * ((<Deriv_methods>))
      * derivative method names.
        
=module NumRu::GPhys::EP_Flux

Module functions of EP_Flux Operater for GPhys.

==Functions:

---ep_full_sphere(gp_u, gp_v, gp_w_or_omega, gp_temp_or_theta, flag_temp_or_theta, xyzdims=[0,1,2])

    Calculate Eliassen-Palm Flux(EP-Flux) from full set equations on the 
    spherical coordinate. this method calculates EP-Flux from 4 GPhys objects,
    zonal-wind velocity(U), merdional-wind velocity(V), vertical-wind velocity(W)
    or pressure velocity(Omega), and temperature(T) or potential(Theta) 
    temperature. check the equations on documents.     

    Furthermore, Residual mean merdional circulation (0, v*, w*) can be calculated.
    
    ARGUMENTS
    * gp_u (GPhys): a GPhys which data is U.
    * gp_v (GPhys): a GPhys which data is V.
    * gp_w_or_omega (GPhys): a GPhys which data is W or Omega. if you give 
      gp_omega, convert to W in this method and calculate EP-Flux.
    * gp_temp_or_theta (GPhys): a GPhys which data is T or Theta.
    * xyzdims (Array): an Array which represents location of upper gphyses's 
                       coordinate. if coordinate configuration is 
                       (longitude, latitude, z), then xyzdims = [0, 1, 2].
                       else if coordinate configuration is 
                       (z, latitude, longitude), then xyzdims = [2, 1, 0].

    RETURN VALUE
    * epflx_y (GPhys): EP-Flux y-component. it is on the merdional hoge.
    * epflx_z (GPhys): EP-Flux z-component.
    * v_rmean (GPhys): residual zonal mean V.
    * w_rmean (GPhys): residual zonal mean W.
    * gp_lat (GPhys): latitude (its units is radian)
    * gp_z (GPhys): from vertical axis (z)
    * u_mean (GPhys): zonal-mean U.
    * theta_mean (GPhys): zonal-mean Theta.
    * uv_dash (GPhys): zonal mean of zonal-eddy products U and V.
    * vt_dash (GPhys): zonal mean of zonal-eddy products V and Theta.
    * uw_dash (GPhys): zonal mean of zonal-eddy products U and W.
    * dtheta_dz (GPhys): zonal mean Theta derivate with z.

---div_sphere(gp_y, gp_z)

    Calculate divergence on the spherical coordinate. it is exclusive to in 
    merdional cross section.

    ARGUMENTS
    * gp_y (GPhys): a GPhys which is merdional component you want to calculate
                    divergence.
    * gp_z (GPhys): a GPhys which is vertical component you want to calculate 
                    divergence.

    RETURN VALUE
    * gp_div (GPhys): a GPhys which is divergence on the spherical coordinate.

---set_deriv_method( method_name )

    Set derivative method. methods are defined in ((<GPhys::derivative>)).
    Now ((<cderiv>)) and ((<threepoint_O2nd_deriv>)) supported

    ARGUMENTS
    * method_name (String): derivative method name.

    RETURN VALUE
    * nil

---deriv( *args )

    Call derivative method defined in ((<GPhys::Derivative>)) refer to
    ((<@@deriv_method>)). 

    ARGUMENTS
    *args : Option for derivative method. Pleaase see ((<GPhys::Derivative>)).

    RETURN VALUE
    * nil

---scale_height

   return a value of the scale height on the log-pressure coordinate.
   default value is "7000 m".

    RETURN VALUE
    * scale height (UNumeric)

---scale_height=(h)

   set a value of the scale height on the log-pressure coordinate.

    RETURN VALUE
    * nil

---radius

   return a value of the radius of the planet. default value is "6.37E6 m".

    RETURN VALUE
    * radius (UNumeric)

---radius=(a)

   set a value of the radius of the planet.

    RETURN VALUE
    * nil

---rot_period

   return a value of the rotation period of the planet. 
   default value is "8.64E4 s".

    RETURN VALUE
    * rotation period (UNumeric)

---rot_period=(rp)

   set a value of the rotation period of the planet.

    RETURN VALUE
    * nil

---g_forces

   return a value of the gravitational acceleration on the surface.
   default value is "9.81 m/s2".

    RETURN VALUE
    * rotation period (UNumeric)

---g_forces=(g)

   set a value of the gravitational acceleration on the surface.

    RETURN VALUE
    * nil

---p00

   return a value of the reference surface pressure.
   default value is "1.0E5 Pa".

    RETURN VALUE
    * reference surface pressure (UNumeric)

---p00=(p00)

   set a value of the reference surface pressure.

    RETURN VALUE
    * nil

---cp

   return a value of the specific heat at constant pressure of the atmosphere.
   default value is "1004.0[J.K-1.kg-1]"

    RETURN VALUE
    * reference surface pressure (UNumeric)

---cp=(cp)

   set a value of the specific heat at constant pressure of the atmosphere.

    RETURN VALUE
    * nil

---gas_const

   return a value of the gas constant divided by molecular mass.
   default value is "287.0[J.K-1.kg-1]".

    RETURN VALUE
    * reference surface pressure (UNumeric)

---gas_const=(r)

   set a value of the gas constant divided by molecular mass.

    RETURN VALUE
    * nil

---get_constants

   return  values of the scale height, radius, rotation period, 
   gravitational acceleration, reference surface pressure, specific heat,
   gas constant.

    RETURN VALUE
    * scale height (UNumeric)
    * radius (UNumeric)
    * rotation period (UNumeric)
    * gravitational acceleration (UNumeric)
    * reference surface pressure (UNumeric)
    * specific heat at constant pressure of the atmosphere (UNumeric)
    * gas constant divided by molecular mass (UNumeric)

---set_constants(scale_height, radius, rot_period, g_forces, p00, cp, gas_const)

   set values of the scale height, radius, rotation period, and gravitational 
   acceleration.

    ARGUMENTS
    * scale height (UNumeric)
    * radius (UNumeric)
    * rotation period (UNumeric)
    * gravitational acceleration (UNumeric)
    * reference surface pressure (UNumeric)
    * specific heat at constant pressure of the atmosphere (UNumeric)
    * gas constant divided by molecular mass (UNumeric)

    RETURN VALUE
    * nil

---make_gphys(*ax_ary)

    make GPhys objects from Axis or VArray. data components is VArray of 
    ((<Axis.pos>)).

    ARGUMENTS
    * ax_ary (Array): an Array each objects are ((<Axis>)) or ((<VArray>)).

    RETURN VALUE
    * gp_ary (Array): an Array each objects are ((<GPhys>)).

---to_w_if_omega(gp, z)

    convert to velocity(W) if ((<gp>)) is pressure velocity(Omega). 
    decide from units ((<gp.data.units>)). if it compatible with "m/s" then 
    deem it ((<W>)), else if "Pa/s" then deem it ((<Omega>)).

    ARGUMENTS
    * gp(GPhys): a GPhys which data represents velocity or pressure velocity.
    * z(GPhys): a GPhys which data represents z-coordinate.

    RETURN VALUE
    * gp_w(GPhys):  a GPhys which data represents velocity or pressure velocity

---to_z_if_pressure(gp)

    convert to altitude(z) if ((<gp>)) is pressure coordinate (p). 
    decide from units ((<gp.data.units>)). if it compatible with "Pa" then 
    deem it (p).

    ARGUMENTS
    * gp(GPhys): a GPhys which data represents z or pressure coordinate.

    RETURN VALUE
    * gp_z(GPhys): a GPhys which data represents z-coordinate.

---to_p_if_altitude(gp)

    convert to pressure(p) if ((<gp>)) is altitude(z). 
    decide from units ((<gp.data.units>)). if it compatible with "m" then 
    deem it (z).

    ARGUMENTS
    * gp(GPhys): a GPhys which data represents z or pressure coordinate.

    RETURN VALUE
    * gp_p(GPhys): a GPhys which data represents p-coordinate.


---to_theta_if_temperature(gp_t, z, flag_temp_or_theta=true) 

    convert ((<gp>)) to potential temperature(\theta) if 
    ((<flag_temp_or_theta>)) is true. 

    ARGUMENTS
    * gp_t(GPhys): a GPhys which data represents potential temperature or 
                   temperature.
    * z(GPhys)   : a GPhys which data represents z-coordinate.
    * flag_temp_or_theta(True or False): a flagment if ((<gp_t>)) convert to.

    RETURN VALUE
    * gp_theta(GPhys): a GPhys which data represents potential temperature.

---to_rad_if_deg(gp)


    convert  to radian if ((<gp.data.units>)) is degrees. 

    ARGUMENTS
    * gp(GPhys): a GPhys which represents angle (radian or degree).

    RETURN VALUE
    * gp_rad(GPhys): a GPhys which units is radian.

---eddy_products(gp_u, gp_v, gp_w, gp_t, dimname)

    calculate eddy products along "dimname" dimension. now in this documents,
    ' means eddy from zonal mean, and () means zonal mean.

    ARGUMENTS
    * gp_u(GPhys): a GPhys which data represents zonal-wind velocity(m/s).
    * gp_v(GPhys): a GPhys which data represents merdional-wind velocity(m/s).
    * gp_w(GPhys): a GPhys which data represents vertical-wind velocity(m/s).
    * gp_t(GPhys): a GPhys which data represents temperature(K).

    RETURN VALUE
    * uv_dash(GPhys): a GPhys which represents (gp_u'*gp_v').
    * vt_dash(GPhys): a GPhys which represents (gp_v'*gp_t').
    * uw_dash(GPhys): a GPhys which represents (gp_u'*gp_w').

---remove_0_at_poles(cos_gp)

   set value if the cos(latitude) is nearly equal to 0 (|x|< 1e-6) at poles.
   at North pole, new value is ((<(a_cos_lat.val[0] + a_cos_lat.val[1])/2>))
   and at South pole ((<(a_cos_lat.val[-1] + a_cos_lat.val[-2])/2>))

    ARGUMENTS
    * cos_gp(GPhys): a GPhys which represents latitude.

    RETURN VALUE
    * new_cos_gp(GPhys): a GPhys which value at poles displaceed.

---preparate_for_vector_on_merdional_section(xax, yax)

   preparate for ((<GGraph::vector_on_merdional_section>)) in 
   vector_on_merdional_section. 

     (1) check ((<yax>)) if it is proportional to p 
     (2) get axis ( a*phi, z ) 

    ARGUMENTS
    * xax(VArray): a VArray which represents x axis.
    * yax(VArray): a VArray which represents y axis.

    RETURN VALUE
    * va_aphi(VArray): a VArray which represents x-coordinate(radius * phi).
    * va_z(VArray): a VArray which represents z-coordinate.
    * was_proportional_to_p(True or False): flag original axis proportional to 
                                            pressure or z.

---strm_rmean(v_rmean, yzdims=[0,1])

    Calculate mass stream function for residual zonal mean circulation. 

    ARGUMENTS
    * v_rmean (GPhys): a GPhys which is residual zonal mean V.
    * yzdims  (Array): an Array which represents axis.

    RETURN VALUE
    * gp_strm (GPhys): a GPhys which is mass stream function on merdional section.

==Constants:

---Deriv_methods

    derivative method name [ 'cderiv', 'threepoint_O2nd_deriv' ]

=end
############################################################

module NumRu
  class GPhys
    module EP_Flux

      include Misc::EMath
      extend  Misc::EMath

      #<<< module constants >>>
#      C_p = 1004.0 # specific heat at constant pressure of the earth's atmosphere [J.K-1.kg-1]
#      R   = 287.0  # gas constant per unit mass for dry air of the earth [J.K-1.kg-1]
      Deriv_methods = [ 'cderiv', 'threepoint_O2nd_deriv' ] # list of derivatave method

      #<<< module variable >>>
      @@scale_height = UNumeric.new(7000,  "m") # log-pressure scale height
      @@radius       = UNumeric.new(6.37E6,"m") # radius of the planet
      @@rot_period   = UNumeric.new(8.64E4,"s") # rotation period of the planet
      @@g_forces     = UNumeric.new(9.81,"m.s-2") 
                                    # gravitational acceleration in the surface
      @@p00          = UNumeric.new(1.0E5,"Pa") # reference surface pressure
      @@cp           = UNumeric.new(1004.0, "J.K-1.kg-1")
                                           # specific heat at constant pressure
      @@gas_const    = UNumeric.new(287.0, "J.K-1.kg-1")
                                           # gas constant per molecular mass
      @@deriv_method = Proc.new{|*args|
        GPhys::Derivative::threepoint_O2nd_deriv(*args)
      }                                    # deriv_method. default method is three*

      module_function

      #<<< access to constants method >>> -------------------------------------
      def scale_height 
	@@scale_height 
      end
      def scale_height=(h)
	@@scale_height = h 
	return nil
      end
      def radius
	@@radius
      end
      def radius=(a)
	@@radius = a
	return nil
      end
      def rot_period
	@@rot_period
      end
      def g_forces=(g)
	@@g_forces = g
	return nil
      end
      def g_forces
	@@g_forces
      end
      def rot_period=(rp)
	@@rot_period = rp
	return nil
      end
      def p00
	@@p00
      end
      def p00=(p00)
	@@p00 = p00
	return nil
      end
      def cp
	@@cp
      end
      def cp=(cp)
	@@cp = cp
	return nil
      end
      def gas_const
	@@gas_const
      end
      def gas_const=(r)
	@@gas_const = r
	return nil
      end
      def set_constants(scale_height, radius, rot_period, g_forces, p00, cp, gas_const)
	@@scale_height = scale_height
	@@radius       = radius
	@@rot_period   = rot_period
	@@g_forces     = g_forces
	@@p00          = p00
	@@cp           = cp
	@@gas_const    = gas_const
	return nil
      end
      def get_constants
	return @@scale_height, @@radius, @@rot_period, @@g_forces, 
                                                       @@p00, @@cp, @@gas_const
      end

      #<<< derivation method  >>> ---------------------------------------------

      def set_deriv_method( method_name )
        if Deriv_methods.include?( method_name )
          @@deriv_method = eval <<-EOS
	  Proc.new{|*args|
	    GPhys::Derivative::#{method_name}(*args)
	  }
          EOS
        else
          raise ArgumentError, "Unsupported method: #{method_name}. " +
	    "(Supported are #{Deriv_methods.inspect}.)"
        end
	nil
      end

      def deriv(*args)
        @@deriv_method.call(*args)
      end

      #<<< calculation method >>> --------------------------------------------- 
      def ep_full_sphere(gp_u, gp_v, gp_w, gp_t, 
                         flag_temp_or_theta=true, xyzdims=[0,1,2]) ## get axis and name
	raise ArgumentError,"xyzdims's size (#{xyzdims.size}) must be 3." if xyzdims.size != 3 
	ax_lon = gp_u.axis(xyzdims[0]) # Axis of longitude 
	ax_lat = gp_u.axis(xyzdims[1]) # Axis of latitude 
	ax_z =   gp_u.axis(xyzdims[2]) # Axis of vertical 
	lon_nm, lat_nm, z_nm = ax_lon.pos.name, ax_lat.pos.name, ax_z.pos.name
	gp_lon, gp_lat, gp_z = make_gphys(ax_lon, ax_lat, ax_z)
	
	## convert axes
	gp_z = to_z_if_pressure(gp_z)     # P => z=-H*log(P/P00) (units-based)
	gp_lon = to_rad_if_deg(gp_lon)    # deg => rad (unit convesion)
	gp_lat = to_rad_if_deg(gp_lat)    # deg => rad (unit convesion)
	gp_w = to_w_if_omega(gp_w, gp_z)  # dP/dt => dz/dt (units-based)
	gp_t = to_theta_if_temperature(gp_t, gp_z, flag_temp_or_theta)	
                      # temperature => potential temperature (if flag is true)

	## replace grid (without duplicating data)
	grid = gp_u.grid_copy
	old_grid = gp_u.grid_copy                 # saved to use in outputs
	grid.axis(lon_nm).pos = gp_lon.data       # in radian
	grid.axis(lat_nm).pos = gp_lat.data       # in radian
	grid.axis(z_nm).pos = gp_z.data           # log-p height
	gp_u = GPhys.new(grid, gp_u.data)
	gp_v = GPhys.new(grid, gp_v.data)
	gp_w = GPhys.new(grid, gp_w.data)
	gp_t = GPhys.new(grid, gp_t.data)
	## get each term
        #  needed in F_y and F_z
	uv_dash, vt_dash, uw_dash = eddy_products(gp_u, gp_v, gp_w, gp_t, lon_nm)
	theta_mean = gp_t.mean(lon_nm)
	dtheta_dz = deriv(theta_mean, z_nm)
	cos_lat = cos(gp_lat)
        a_cos_lat = @@radius * cos_lat
  	a_cos_lat.data.rename!('a_cos_lat')
	a_cos_lat.data.set_att('long_name', 'radius * cos_lat')
        remove_0_at_poles(a_cos_lat)
        #  needed in F_y only
	u_mean = gp_u.mean(lon_nm)
	du_dz  = deriv(u_mean, z_nm)
        #  needed in F_z only
	f_cor = 2 * (2 * PI / @@rot_period) * sin(gp_lat) 
  	f_cor.data.rename!('f_cor')
	f_cor.data.set_att('long_name', 'Coriolis parameter')
	ducos_dphi = deriv( u_mean * cos_lat, lat_nm)
	avort = (-ducos_dphi/a_cos_lat) + f_cor        # -- absolute vorticity
	avort.data.units = "s-1"
	avort.data.rename!('avort')
	avort.data.set_att('long_name', 'zonal mean absolute vorticity')

	## F_y, F_z
	sigma = exp(-gp_z/@@scale_height)
	epflx_y = ( - uv_dash + du_dz*vt_dash/dtheta_dz ) * cos_lat * sigma
	epflx_z = ( - uw_dash + avort*vt_dash/dtheta_dz ) * cos_lat * sigma
	epflx_y.data.name = "epflx_y"; epflx_z.data.name = "epflx_z"
	epflx_y.data.set_att("long_name", "EP flux y component")
	epflx_z.data.set_att("long_name", "EP flux z component")

	## v_rmean, w_rmean
	z_nm = gp_z.data.name    # change z_nm from pressure to z
	v_mean = gp_v.mean(lon_nm); w_mean = gp_w.mean(lon_nm)
	v_rmean = ( v_mean - deriv( (vt_dash/dtheta_dz*sigma), z_nm )/sigma )
	w_rmean = ( w_mean + deriv( (vt_dash/dtheta_dz*cos_lat), lat_nm )/a_cos_lat )
	v_rmean.data.name = "v_rmean"; w_rmean.data.name = "w_rmean"
	v_rmean.data.set_att("long_name", "residual zonal mean V")
	w_rmean.data.set_att("long_name", "residual zonal mean W")

	## convert with past grid
	gp_ary = [] # grid convertes gphyss into 
	grid_xmean = old_grid.delete_axes(lon_nm)
	[epflx_y, epflx_z, v_rmean, w_rmean, gp_lat, gp_z, u_mean, theta_mean, 
         uv_dash, vt_dash, uw_dash, dtheta_dz].each {|gp|  
	  if grid_xmean.shape.size != gp.shape.size
	    gp_ary << gp
	  else
	    gp_ary << GPhys.new(grid_xmean, gp.data) #back to the original grid
	  end
	}
	return gp_ary
      end

      def div_sphere(gp_fy, gp_fz, yzdims=[0,1])
	raise ArgumentError,"yzdims's size (#{yzdims.size}) must be 2." if yzdims.size != 2
	## get axis and name
	ax_lat = gp_fy.axis(yzdims[0])    # Axis of latitude
	ax_z   = gp_fy.axis(yzdims[1])    # Axis of vertical
        lat_nm, z_nm = ax_lat.pos.name, ax_z.pos.name
	gp_lat, gp_z = make_gphys(ax_lat, ax_z)
	## convert
	gp_z =   to_z_if_pressure(gp_z)   # P => z=-H*log(P/P00) (units-based)
	gp_lat = to_rad_if_deg(gp_lat)    # deg => rad (unit convesion)

	## replace grid (without duplicating data)
	grid = gp_fy.grid_copy
	cp_grid = gp_fy.grid_copy         # saved to use in outputs
	grid.axis(lat_nm).pos = gp_lat.data
	grid.axis(z_nm).pos = gp_z.data
	gp_fy = GPhys.new(grid, gp_fy.data)
	gp_fz = GPhys.new(grid, gp_fz.data)

	## d_F_phi_dz
	a_cos_lat = @@radius * cos(gp_lat)
        remove_0_at_poles(a_cos_lat)	
	d_gp_fy_d_phi = deriv(gp_fy * cos(gp_lat), lat_nm)
	## d_F_z_dz
	d_gp_fz_d_z =   deriv(gp_fz, z_nm)
	f_div = ( d_gp_fy_d_phi / a_cos_lat )  + d_gp_fz_d_z

	f_div.data.name = "epflx_div"
	f_div.data.set_att("long_name", "EP Flux divergence")
	## convert with past grid
	return GPhys.new(cp_grid, f_div.data)
      end

      def make_gphys(*ax_ary) 
                 # it will be lost when new grid.rb released : to use delete_ax
	gp_ary = []           
	ax_ary.each{|ax|
	  if ax.is_a?(Axis)
	    ax_data = ax.pos
	    ax_grid = Grid.new(ax) 
	  elsif ax.is_a?(VArray)
	    ax_data = ax
	    ax_grid = Grid.new(Axis.new().set_pos(ax))
	  end
	  gp = GPhys.new(ax_grid, ax_data)
	  gp_ary << gp
	}
	return gp_ary
      end

      def to_w_if_omega(gp, z) # it is only for z coordinate!!!
        gp_units = gp.data.units
	if gp_units =~ Units.new("Pa/s")
	  pr = @@p00*exp(-z/@@scale_height)
	  gp_un = gp_units
	  pr = pr.convert_units(gp_un*Units.new('s'))
	  gp = gp*(-@@scale_height/pr)
	  gp.data.rename!("wwnd")
	  gp.data.set_att('long_name', "log-P vertical wind")
	elsif gp_units =~ Units.new("m/s") 
	  gp = gp.convert_units(Units.new('m/s'))
	else
	  raise ArgumentError,"units of gp.data (#{gp.data.units}) 
                               must be dimention of pressure/time 
                                                 or length/time."
	end
	return gp
      end      

      def to_theta_if_temperature(gp_t, z, flag_temp_or_theta=true) 
                                               # it is only for z coordinate!!!
	if flag_temp_or_theta
	  gp_un = gp_t.data.units
	  gp_t = gp_t.convert_units(Units.new("K"))
	  gp_t = gp_t*exp((@@gas_const/@@cp)*z/@@scale_height)
	  gp_t.data.set_att('long_name', "Potential Temperature")
	end
	return gp_t
      end
      
      def to_z_if_pressure(gp_z) 
                            # number in units is not considerd operater as log.
	if ( gp_z.data.units =~ Units.new('Pa') )
	  p00 = @@p00.convert(gp_z.units)
          gp_z = -@@scale_height*log(gp_z.to_type(NArray::DFLOAT)/p00)
            # it will be change if GPhys is modified for scalor production
	  gp_z.data.set_att('long_name', "z").rename!("z")
	elsif ( gp_z.data.units =~ Units.new('m') )
	  gp_z = gp_z.convert_units(Units.new("m"))
	else
	  raise ArgumentError,"units of gp_z (#{gp_z.data.units}) 
                               must be dimention of pressure or length."
	end
	return gp_z
      end

      def to_p_if_altitude(gp_z) 
                            # number in units is not considerd operater as log.
	if ( gp_z.data.units =~ Units.new('m') )
	  h = @@scale_height.convert(gp_z.units)
	  gp_z = @@p00*exp(-gp_z/h)
	  gp_z.data.set_att('long_name', "p").rename!("p")
	elsif ( gp_z.data.units =~ Units.new('Pa') )
	  gp_z = gp_z.convert_units(Units.new("Pa"))
	else
	  raise ArgumentError,"units of gp_z (#{gp_z.data.units}) 
                               must be dimention of pressure or length."
	end
	return gp_z
      end

      def to_rad_if_deg(gp)
	if gp.data.units =~ Units.new("degrees")
	  gp = gp.convert_units(Units.new('rad'))
	  gp.units = Units[""]	  
	  gp
	elsif gp.data.units =~ Units.new('rad') 
	  gp.data = gp.data.copy
	  gp.data.units = Units[""]	  
	  gp
	else
	  raise ArgumentError,"units of gp #{gp.data.units} must be equal to deg or radian."
	end
	return gp
      end
      
      def eddy_products(gp_u, gp_v, gp_w, gp_t, dimname)
	# get zonal_eddy 
	u_dash = gp_u - gp_u.mean(dimname)
	v_dash = gp_v - gp_v.mean(dimname)
	w_dash = gp_w - gp_w.mean(dimname)
	t_dash = gp_t - gp_t.mean(dimname)

	# get eddy_product 
	uv_dash = u_dash*v_dash  # u'v'
	vt_dash = v_dash*t_dash  # v't'
	uw_dash = u_dash*w_dash  # u'w'

	# set attribute
	uv_dash.data.set_att("long_name", "U'V'")
	vt_dash.data.set_att("long_name", "V'T'")
	uw_dash.data.set_att("long_name", "U'W'")
	uv_dash.data.rename!("uv_dash")
	vt_dash.data.rename!("vt_dash")
	uw_dash.data.rename!("uw_dash")	

	return uv_dash.mean(dimname), vt_dash.mean(dimname), uw_dash.mean(dimname)
      end
      
      def remove_0_at_poles(a_cos_lat)
	eps = 1e-6
	if ( (a_cos_lat.val[0]/@@radius).abs.val < eps )
	  a_cos_lat[0] = (a_cos_lat.val[0] + a_cos_lat.val[1])/2
	end
	if ( (a_cos_lat.val[-1]/@@radius).abs.val < eps )
	  a_cos_lat[-1] = (a_cos_lat.val[-1] + a_cos_lat.val[-2])/2
	end
	if a_cos_lat.min.val <= 0
	  raise "Illegal cos(phi) data. phi must between -pi/2 and +pi/2 " +
                "and aligned in increasing or decreasing order."
	end
	nil
      end

      def preparate_for_vector_on_merdional_section(xax, zax)
	gp_x, gp_z = make_gphys(xax, zax) # make gphys from axis	
	gp_phi = to_rad_if_deg(gp_x)      # deg => rad (unit convesion)
	gp_aphi = @@radius * gp_phi       # radius * phi
	# check zax units, if proportional to z or p
	if ( gp_z.data.units =~ Units.new('Pa') )
	  was_proportional_to_p = true 
	elsif ( gp_z.data.units =~ Units.new('m') )
	  was_proportional_to_p = false
	else
	  raise ArgumentError,'unit of zax #{gp_z.data.units} must be 
                               compatible to length or pressure.'
	end
        gp_z = to_z_if_pressure(gp_z)   # convert to z if gp_z is pressure
	gp_z[0] = +1E-6 if gp_z.data.val[0] == -0.0
	return gp_aphi.data, gp_z.data, was_proportional_to_p
      end

      def strm_rmean(gp_v, yzdims=[0,1])

	raise ArgumentError,"yzdims's size (#{yzdims.size}) must be 2." if yzdims.size != 2
	## get axis and name
	lat_dim, z_dim = yzdims             # Index of dims
	ax_lat = gp_v.axis(lat_dim)      # Axis of latitude
	ax_z   = gp_v.axis(z_dim)        # Axis of vertical
        lat_nm, z_nm = ax_lat.pos.name, ax_z.pos.name
	gp_lat, gp_z = make_gphys(ax_lat, ax_z)
	## convert
	gp_lat =   to_rad_if_deg(gp_lat)      # deg. to rad.
	gp_p   =   to_p_if_altitude(gp_z)     # z => p=p00exp(-z/H) (units-based) and "Pa"

	## copy grid 
	grid =    gp_v.grid_copy

	## calculate stream function
	na_v  = gp_v.data.val                  # for integration box 
	int_v = gp_v.data.val.dup.fill!(0.0)   # for integration box 
	pres  = gp_p.data.val.dup
	if pres[0] < pres[-1]
	  int_v[*([true]*z_dim+[0, false])] = 0.5*(na_v[*([true] + [0, false])])*pres[0]
	  1.upto( pres.size-1 ) do |idx|
	    dp = (pres[idx] - pres[idx-1])
	    int_v[*([true]*z_dim+[idx, false])] = \
  	      0.5 * (na_v[*([true] + [idx-1, false])] + na_v[*([true] + [idx, false])]) * dp \
	      + int_v[*([true] + [idx-1, false])]
	  end
	else
	  int_v[*([true]*z_dim+[-1, false])] = 0.5*(na_v[*([true] + [-1, false])])*pres[-1]
	  ( pres.size-2 ).downto(0) do |idx|
	    dp = (pres[idx] - pres[idx+1])
	    int_v[*([true]*z_dim+[idx, false])] = \
	      0.5 * (na_v[*([true] + [idx+1, false])] + na_v[*([true] + [idx, false])]) * dp \
	      + int_v[*([true] + [idx+1, false])]
	  end
	end
	int_v = VArray.new( int_v, gp_v.data, gp_v.data.name )
	int_v.units = Units.new("Pa.m.s-1")
	gp_int_v   = GPhys.new(grid, int_v)
        strm_rmean = gp_int_v * cos(gp_lat) * 2 * PI * @@radius / @@g_forces

	## change attribute
	strm_rmean.name = "strm_rmean"
	strm_rmean.set_att("long_name", "Residual mean mass stream function")

	## convert with past grid
	return strm_rmean
      end
      
    end  
  end
end

#########################################################

if __FILE__ == $0
  print "Test script path is 'test/test_ep_flux.rb' in expand gphys dir.\n"
end 
