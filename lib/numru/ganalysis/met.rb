# = NumRu::GAnalysis::Met : Meteorological analysis

require "numru/gphys"
require 'numru/ganalysis/planet'

module NumRu

  class GPhys
    for f in %w!temp2theta interpolate_onto_theta z2geostrophic_wind q2r r2q r2e e2r q2e e2q lat e_sat rh2e theta_e theta_es!
      eval <<-EOS
        def #{f}(*args)
          GAnalysis::Met.#{f}(self,*args)
        end
      EOS
    end
  end

  module GAnalysis

    # Meteorological analysis
    # 
    # USEFUL METHODS
    # * temp2theta
    # * pv_on_theta
    # * interpolate_onto_theta
    module Met

      #< Themodynamic constants for the Earth's atmosphere >

      R = UNumeric[287.04,"J.kg-1.K-1"] # Gas constant of dry air
      Rv = UNumeric[461.50,"J.kg-1.K-1"] # Gas constant of water vapor
      Cp = UNumeric[1004.6,"J.kg-1.K-1"] # heat capacity at constant pressure for dry air
      Cpv = UNumeric[1870.0,"J.kg-1.K-1"] # heat capacity at constant pressure for water vapor
      Kappa = (R/Cp).to_f  # = 2.0/7.0
      T0 = UNumeric[273.15,"K"]  # K - Celcius
      Lat0 = UNumeric[2.500780e6,"J.kg-1"]  # Latent heat of vaporization at 0 degC

      #< Earth's parameters >
      @@g = UNumeric[9.8,"m.s-2"]    # adjustable: e.g., 9.7 m.s-2 for stratosphere
      P00 = UNumeric[1e5,"Pa"]

      module_function

      #< module parameters >

      # Sets gravity acceleration in the module (default: 9.8 ms-1).
      #
      # ARGUMENT
      # * g [UNumeric]
      # EXAMPLE
      #   Met::set_g( UNumeric[9.7,"m.s-2"] )
      # RETURN VALUE
      # * The argument g
      def set_g(g)
        @@g = g   # e.g., un[9.8,"m.s-2"]
      end


      # Returns gravity acceleration in the module (default: 9.8 ms-1).
      def g
        @@g.dup
      end

      #< potential temperature >

      # Convert temperature into potential temperature
      # 
      # ARGUMENTS
      # * temp [UNumeric or GPhys or VArray, which supports method "units"] :
      #   temperature
      # * prs [UNumeric or GPhys or VArray, which supports method "units"] :
      #   pressure
      # RETURN VALUE
      # * potential temperature [UNumeric or GPhys or VArray,...] in Kelvin
      #
      def temp2theta(temp, prs=nil)
        prs = get_prs(temp) if !prs
        prs = convert_units2Pa(prs)
        if ( !(temp.units === Units["K"]) )
          temp = convert_units(temp,"K")
        end
        theta = temp * (prs/P00)**(-Kappa)
        if theta.respond_to?(:long_name)  # VArray or GPhys
          theta.name = "theta"
          theta.long_name = "potential temperature"
        end
        theta
      end

      #< for isentropic coordinate >

      # Inverse of the "sigma" density in the theta coordinate:
      # 
      # ARGUMENTS
      # * theta [GPhys or VArray] potential temperature
      # * dim [Integer] : the pressure dimension. If theta is a GPhys,
      #   this argument can be omitted, in which case a pressure dimension
      #   is searched internally by find_prs_d.
      # * prs [GPhys or VArray] : the pressure values. Internally searched
      #   if omitted.
      # RETURN VALUE
      # * 1 / sigma = -g d\theta/dp [GPhys]
      #
      def sigma_inv(theta, dim=nil, prs=nil)
        dim = find_prs_d(theta) if !dim
        prs = get_prs(theta) if !prs
        prs = convert_units2Pa(prs)
        #dtheta_dp = df_dx(theta, prs, dim)
        dtheta_dp = df_dx_vialogscale(theta, prs, dim)
        sig_inv = dtheta_dp * (-@@g)
        if sig_inv.respond_to?(:long_name)  # VArray or GPhys
          sig_inv.name = "sig_inv"
          sig_inv.long_name = "1/sigma"
        end
        sig_inv
      end

      # Interpolate onto the potential temperature coordinate
      #
      # ARGUMENTS
      # * gphys [GPhys] a gphys object that have a pressure dimension
      # * theta [GPhys] potential temperature defined on the same grid
      #   as gphys
      # * theta_vals : 1D NArray or Array
      def interpolate_onto_theta(gphys, theta, theta_levs)
        theta_levs = NArray[*theta_levs].to_f if Array === theta_levs
        th_crd = VArray.new( theta_levs, 
               {"units"=>"K", "long_name"=>"potential temperature"}, "theta" )
        gphys.set_assoc_coords([theta])
        pdnm = gphys.coord(find_prs_d(gphys)).name
        gphys.interpolate(pdnm=>th_crd)
      end

      # Derive Ertel's potential vorticity on the theta (isentropic) 
      # coordinate
      #
      # ARGUMENTS
      # * u [GPhys] : zonal wind on pressure coordinate 
      #   (u, v, and theta must share same coordinates)
      # * v [GPhys] : meridional wind on pressure coordinate
      # * theta [GPhys] : potential temperature on pressure coordinate
      # * theta_levs [NArray or Array] : one dimensional array of 
      #   potential temperature values (Kelvin) on which PV is derived.
      #   
      # RETURN VALUE
      # * potential voticity [GPhys] on a theta coordinate, where
      #   levels are set to theta_levs
      def pv_on_theta(u, v, theta, theta_levs)
        sigi = GAnalysis::Met.sigma_inv(theta)
        uth = GAnalysis::Met.interpolate_onto_theta(u, theta, theta_levs)
        vth = GAnalysis::Met.interpolate_onto_theta(v, theta, theta_levs)
        sigith = GAnalysis::Met.interpolate_onto_theta(sigi, theta, theta_levs)
        avorth = GAnalysis::Planet.absvor_s(uth,vth)
        pv = avorth*sigith
        pv.long_name = "potential vorticity"
        pv.name = "PV"
        pv
      end

      # Derive Ertel's potential vorticity on the pressure
      # coordinate
      #
      #
      # ARGUMENTS
      # * u [GPhys] : zonal wind on pressure coordinate 
      #   (u, v, and theta must share same coordinates)
      # * v [GPhys] : meridional wind on pressure coordinate
      # * theta [GPhys] : potential temperature on pressure coordinate
      #   
      # RETURN VALUE
      # * potential vorticity [GPhys] on the same grid as the inputs
      #
      def pv_on_p(u, v, theta)
        up,vp,thp = del_ngp(u,v,theta)    # -g del/del p
        pv = Planet.absvor_s(u, v) * thp \
             - vp * Planet.grad_sx(theta) \
             + up * Planet.grad_sy(theta)
        pv.long_name = "potential vorticity"
        pv.name = "PV"
        pv.units = pv.units.reduce5    # express in the MKS fundamental units
        pv
      end

      # -g del/del p
      def del_ngp(*gps)  # gps: array of GPhys objects having the same grid
        d = find_prs_d(gps[0])
        prs = gps[0].coord(d).convert_units(Units["Pa"])
        dngps = gps.collect{|gp|
          gp.threepoint_O2nd_deriv(d,Derivative::LINEAR_EXT,prs) * (-@@g)
        }
      end
      private :del_ngp

      # Derive geostrophic wind from geopotential hight (spherical but fixed f)
      # 
      # ARGUMENTS
      # * z [GPhys] : geopotential height on the pressure (or log-pressure)
      #   coordinate
      # * f [nil or Numeric of UNumeric] : the constant f value 
      #   (Coriolis parameter).
      #   If nil, the value at the north pole is assumed.
      #   If Numeric, units are assumed to be "s-1".
      #
      def z2geostrophic_wind(z, f=nil)
        if f.nil?
          f = 2 * GAnalysis::Planet.omega
        elsif f.is_a?(Numeric)
          f = UNumeric[f,"s-1"]
        end
        z = z.convert_units("m")
        gx, gy = GAnalysis::Planet.grad_s( z * (g/f) )
        u = -gy
        v = gx
        u.name = "u"
        u.long_name = "geostrophic U"
        u.put_att("assumed_f",f.to_s)
        v.name = "v"
        v.long_name = "geostrophic V"
        v.put_att("assumed_f",f.to_s)
        [u, v]
      end

      # Adiabatic frontogenesis function over the sphere. --
      # D/Dt(|gradH theta|) or D/Dt(|gradH theta|^2), where gradH express
      # the horizontal component of gradient. 
      # 
      # if full_adv is true (default),
      #  D/Dt(|gradH theta|) = 
      #    [ -(ux-va)*thetax^2 - (vx+uy)*thetax*thetay - vy*thetay^2
      #      - (wx*thetax + wy*thetay)*theta_z ]
      #    / |gradH theta|
      # or else,
      #  (\del/\del t + u gradx + v grady )(|gradH theta|) = 
      #    [ -(ux-va)*thetax^2 - (vx+uy)*thetax*thetay - vy*thetay^2
      #      - (w*theta_z)_x*thetax - (w*theta_z)_y*thetay ]
      #    / |gradH theta|
      # 
      # Here, the 2nd line (vertical advection) is optional;
      # [vx, vy] = gradH v; [thetax, thetay] = gradH theta;
      # [ux, uy] = cos_phi * gradH (u/cos_phi)
      # va = v*tan_phi/a (a=radius).
      # z and w is the vertical coordinate and the lagrangian
      # "velocity" in that coordinate --- Typically they are
      # p and omega, or log-p height and log-p w.
      # 
      # This formulation is adiabatic; the diabatic heating effect
      # can be easily included if needed.
      # 
      # ARGUMENTS
      # * theta [GPhys] : potential temperature
      # * u [GPhys] : zonal wind
      # * v [GPhys] : meridional wind
      # * w [nil (default) or GPhys] : (optional) "vertical wind", which must
      #   be dimensionally consistent with the vertical coordiante 
      #   (e.g., omega for the pressure coordinate). 
      #   If w is given, the vertical cooridnate is assumed to be
      #   the 3rd one (dim=2).
      # * fstodr [true (default) or false] (optional) if true 
      #   D/Dt(|\NablaH theta|) returned; if false D/Dt(|\NablaH theta|^2)
      #   is returned.
      # * full_adv [true (default) or false] : whether to calculate
      #   full lagrangian tendency or lagragian tendency only in 
      #   horizontal direction
      # 
      # RETURN VALUE
      # * frontogenesis function [GPhys]
      # 
      def frontogenesis_func(theta, u, v, w=nil, fstodr=true, full_adv = true)
        thx, thy = GAnalysis::Planet.grad_s( theta )
        ux = GAnalysis::Planet.grad_sx( u )
        uy = GAnalysis::Planet.grad_sy_cosphifact( u, -1 )
        vx, vy =  GAnalysis::Planet.grad_s( v )
        va = GAnalysis::Planet.weight_tanphi( v, 1, -1 )
        frgf = - (ux-va)*thx*thx - (vx+uy)*thx*thy - vy*thy*thy
        frgf.name = "frgen"
        frgf.long_name = "frontogenesis function"
        if w 
          zdim = 2
          if (wun=w.units) !~ (ztun = theta.coord(zdim).units * Units["s-1"])
            raise "w in #{wun} is inconsistent with the vertical coordinate of theta in #{ztun}"
          else
            w = w.convert_units(ztun)    # For example, Pa/s -> hPa/s
          end
          z = theta.axis(zdim).to_gphys
          if z.units =~ Units["Pa"]
            thz = df_dx_vialogscale(theta, z, zdim)
          else
            thz = df_dx(theta, z, zdim)
          end
          if full_adv
            # full lagragian tendency of theta-gradient strength
            wx,  wy =  GAnalysis::Planet.grad_s( w ) 
            frgf -= (wx*thx + wy*thy)*thz
          else
            # lagragian tendency only in horizontal direction
            wthzx,  wthzy =  GAnalysis::Planet.grad_s( w*thz ) 
            frgf -= wthzx*thx + wthzy*thy
          end
        end
        if fstodr
          frgf /= (thx**2 + thy**2).sqrt 
        else
          frgf *= 2
        end
        frgf
      end

=begin
      def frontogenesis_eulerian(theta, u, v, w=nil, fstodr=true )
        thx, thy = GAnalysis::Planet.grad_s( theta )
        uthxx,  uthxy =  GAnalysis::Planet.grad_s( u*thx )
        vthyx,  vthyy =  GAnalysis::Planet.grad_s( v*thy )
        va = GAnalysis::Planet.weight_tanphi( v, 1, -1 )
        frgf = - (uthxx+vthyx)*thx - (uthxy+vthyy)*thy
        frgf.name = "thgrd_tend"
        frgf.long_name = "Eluerian grad-theta tendency"
        if w 
          zdim = 2
          if (wun=w.units) !~ (ztun = theta.coord(zdim).units * Units["s-1"])
            raise "w in #{wun} is inconsistent with the vertical coordinate of theta in #{ztun}"
          else
            w = w.convert_units(ztun)    # For example, Pa/s -> hPa/s
          end
          z = theta.axis(zdim).to_gphys
          if z.units =~ Units["Pa"]
            thz = df_dx_vialogscale(theta, z, zdim)
          else
            thz = df_dx(theta, z, zdim)
          end
          wthzx,  wthzy =  GAnalysis::Planet.grad_s( w*thz ) 
          frgf -= wthzx*thx + wthzy*thy
        end
        if fstodr
          frgf /= (thx**2 + thy**2).sqrt 
        else
          frgf *= 2
        end
        frgf
      end
=end

      # Find a pressure coordinate in a GPhys object
      # 
      # ARGUMENT
      # * gphys [GPhys]
      # * error [nil/false or true] change the behavior if a
      #   pressure coordinate is not found. Default: returns nil;
      #   if error is true, an exception is raised.
      # RETURN VALUE
      # * Integer to indicate the dimension of the pressure coordinate,
      #   or nil if not found by default (see above)
      def find_prs_d(gphys, error=nil)
        pa = Units.new("Pa")
        (gphys.rank-1).downto(0) do |d|
          un = gphys.axis(d).pos.units
          if ( un =~ pa or un.to_s=="millibar" )
            return(d)
          end
        end
        if error
          raise("Could not find a pressure coordinate.")
        else
          nil
        end
      end

      # Find and return a pressure coordinate in a GPhys object
      # 
      # ARGUMENT
      # * gphys [GPhys]
      # 
      # RETURN VALUE
      # * pressure in a 1D GPhys object created from the pressure 
      #   axis in the GPhys object or a UNumeric object if the pressure
      #   coordinated has been deleted by subsetting.
      def get_prs(gphys)
        begin
          prs = gphys.axis( find_prs_d(gphys, true) ).to_gphys
        rescue
          regexp = /([\d\.]+) *(millibar|hPa)/
          cand = gphys.lost_axes.grep(regexp)
          if (str=cand[0])   # substitution, not ==
            regexp =~ str
            hpa = $1.to_f
            prs = UNumeric[hpa*100,"Pa"]
          else
            raise "No pressure axis was found"
          end
        end
        prs
      end

      # Convert units into Pa. To deal with old versions of NumRu::Units 
      # that do not support "millibar".
      #
      # ARGUMENT
      # * prs [GPhys and UNumeric]
      def convert_units2Pa(prs)
        pa = Units["Pa"]
        un = prs.units
        if ((un =~ pa) and !(un === pa))
          prs = convert_units(prs, pa)
        elsif un.to_s=="millibar"
          if UNumeric === prs
            ret = UNumeric[prs.val*100, "Pa"]
          else
            ret = prs*100
            ret.units = "Pa"
          end
          ret
        else
          prs
        end
      end

      #< misc >

      # Unit conversion good to both GPhys and UNumeric
      def convert_units(obj, un)
        begin
          obj.convert_units(un)   # for GPhys etc
        rescue
          obj.convert2(un)        # for UNumeric etc
        end
      end
      private :convert_units   # this method should be defined somewhere else

      # numerical derivative good to both GPhys and UNumeric
      def df_dx(f, x, dim)
        if GPhys === f
          mdl = NumRu::GPhys::Derivative
          mdl.threepoint_O2nd_deriv(f, dim, mdl::LINEAR_EXT, x)
        else
          mdl = NumRu::Derivative
          mdl.threepoint_O2nd_deriv(f, x, dim, mdl::LINEAR_EXT)
        end
      end
      private :df_dx   # this method should be defined somewhere else

      def df_dx_vialogscale(f, x, dim)
        z = Misc::EMath.log(x)
        if GPhys === f
          mdl = NumRu::GPhys::Derivative
          dfdz = mdl.threepoint_O2nd_deriv(f, dim, mdl::LINEAR_EXT, z)
        else
          mdl = NumRu::Derivative
          dfdz = mdl.threepoint_O2nd_deriv(f, z, dim, mdl::LINEAR_EXT)
        end
        dfdz / x
      end

      ##### moist thermodynamics ###
      
      @@consider_ice = true
      @@ice_thres = T0    # Celcius

      # whether or not ice is considered in the water phase change
      def consider_ice
        @@consider_ice
      end

      # set whether or not ice is considered in the water phase change
      def consider_ice=(t_or_f)
        @@consider_ice=t_or_f
      end

      # the threshold temperature for liquid/ice-phase treatment
      def ice_thres
        @@ice_thres
      end

      # set the threshold temperature for liquid/ice-phase treatment (default: O degC)
      def ice_thres=(temp)
        @@ice_thres=temp
      end

      # specific humidity -> mixing ratio
      #
      # ARGUMENTS
      # * q:  specific humidty
      # 
      # RETURN VALUE
      # * r:  mixing ratio
      def q2r(q)
        r = q/(1.0-q)
        r.name = "r"
        r.long_name = "mixing ratio"
        r
      end

      # mixing ratio -> specific humidity
      #
      # ARGUMENTS
      # * r:  mixing ratio
      # 
      # RETURN VALUE
      # * q:  specific humidty
      def r2q(r)
        q = r/(1.0+r)
        q.name = "q"
        q.long_name = "specific humidity"
        q
      end

      # water vapor mixing ratio -> water vapor pressure
      #
      # ARGUMENTS
      # * r:  water vapor mixing ratio
      # * prs:  pressure
      # 
      # RETURN VALUE
      # * e:  water vapor pressure
      def r2e(r,prs=nil)
        prs = get_prs(r) if !prs
        prs = convert_units2Pa(prs)
        rratio = R / Rv
        e = prs*r/(rratio+r)     # water vapor pertial pressure
        e.name = "e"
        e.long_name = "water vapor pressure"
        e
      end

      # water vapor pressure -> mixing ratio 
      #
      # ARGUMENTS
      # * e:  water vapor pressure
      # * prs:  pressure
      # 
      # RETURN VALUE
      # * r:  mixing ratio
      def e2r(e,prs=nil)
        prs = get_prs(e) if !prs
        prs = convert_units(prs,e.units)
        rratio = R / Rv
        r = rratio * e / (prs-e)
        r.name = "r"
        r.long_name = "mixing ratio"
        r
      end

      # specific humidity -> water vapor pressure
      #
      # ARGUMENTS
      # * q:  specific humidity[g/g]
      # * prs:  pressure[hPa]
      # 
      # RETURN VALUE
      # * e:  water vapor pressure
      def q2e(q,prs=nil)
        prs = get_prs(q) if !prs
        prs = convert_units2Pa(prs)
	rratio = R / Rv
	e = prs*q/(rratio+(1-rratio)*q)     # water vapor pertial pressure
        e.name = "e"
        e.long_name = "water vapor pressure"
        e
      end

      # water vapor pressure -> specific humidity
      #
      # ARGUMENTS
      # * e:  water vapor pressure
      # * prs:  pressure
      # 
      # RETURN VALUE
      # * q: specific humidity
      def e2q(e,prs=nil)
        prs = get_prs(e) if !prs
        prs = convert_units(prs,e.units)
	rratio = R / Rv
	q = rratio * e / (prs-(1-rratio)*e) 
        q.name = "q"
        q.long_name = "specific humidity"
        q
      end

      # temperature --> latent heat [J.kg-1]
      #
      # good for -100<T<50
      #
      # ARGUMENTS
      # * temp: temperature
      # 
      # RETURN VALUE
      # * lat: latent heat
      def lat(temp)
        tempK = temp.convert_units("K")
        lat = Lat0*(T0/tempK)**(0.167+tempK.val*3.67E-4) 
        lat.name = "L"
        lat.long_name = "Latent heat"
        lat
      end

      # Bolton formula for saturation water vapor pressure against water
      #
      # ARGUMENTS
      # * temp: temperature
      # 
      # RETURN VALUE
      # * es: saturation water vapor pressure [Pa]
      def e_sat_bolton(temp)
        tempC = temp.convert_units("degC")
        es = UNumeric[6.112e2,"Pa"] * 
          Misc::EMath.exp( 17.67 * tempC / (tempC + UNumeric[243.5,"degC"] ) )
        es.name = "e_sat"
        es.long_name = "e_sat_water bolton"
        es
      end

      # saturation water vapor pressure against ice. 
      #
      # Emanuel (1994) eq.(4.4.15)
      #
      # ARGUMENTS
      # * temp: temperature
      # 
      # RETURN VALUE
      # * es: saturation water vapor pressure [Pa]
      def e_sat_emanuel_water(temp, mask=nil)
        es = temp.copy
        tempK = temp.convert_units("K").val   # units removed
        tempK = tempK[mask] if mask
        e = 53.67957 - 6743.769/tempK \
             - 4.8451 * Misc::EMath.log(tempK)
        if !mask
          es.replace_val( Misc::EMath.exp(e) * 100.0 )
        else
          es[false] = 0
          es[mask] = Misc::EMath.exp(e) * 100.0
        end
        es.units = "Pa"
        es.name = "e_sat_ice"
        es.long_name = "e_sat_ice emanuel"
        es
      end

      # Saturation water vapor pressure against ice.
      #
      # Emanuel (1994) eq.(4.4.15)
      #
      # ARGUMENTS
      # * temp: temperature
      # 
      # RETURN VALUE
      # * es: saturation water vapor pressure [Pa]
      def e_sat_emanuel_ice(temp, mask=nil)
        es = temp.copy
        tempK = temp.convert_units("K").val   # units removed
        tempK = tempK[mask] if mask
        e = 23.33086 - 6111.72784/tempK \
             + 0.15215 * Misc::EMath.log(tempK)
        if !mask
          es.replace_val( Misc::EMath.exp(e) * 100.0 )
        else
          es[false] = 0
          es[mask] = Misc::EMath.exp(e) * 100.0
        end
        es.units = "Pa"
        es.name = "e_sat_ice"
        es.long_name = "e_sat_ice emanuel"
        es
      end

      # Selector of the formulat to compute saturation water vapor pressure against water (default: Bolton)
      # 
      # ARGUMENTS
      # * formula: nil(default), "bolton", "emanuel"
      # 
      # RETURN VALUE
      # * nil
      def set_e_sat_water(formula=nil)
        case formula
        when nil,"bolton"
          alias :e_sat_water :e_sat_bolton
        when "emanuel"
          alias :e_sat_water :e_sat_emanuel_water
          module_function :e_sat_water
        end
        nil
      end
      set_e_sat_water
      module_function :e_sat_water

      # currently, only a single formula is avilable for ice
      alias  :e_sat_ice :e_sat_emanuel_ice
      module_function :e_sat_ice

      # Calculates saturation water vapor pressure using enhanced 
      #
      # ARGUMENTS
      # * temp: temperature
      # 
      # RETURN VALUE
      # * es: saturation water vapor pressure
      def e_sat(temp)

        ice = @@consider_ice && ( temp.lt(@@ice_thres) )
        #ice = ice.to_na
        water = !@@consider_ice || ( (ice==true||ice==false) ? !ice : ice.not)

        if water
          es = e_sat_water(temp)
        end

        case ice
        when true
          es = e_sat_ice(temp)
        when NArray, NArrayMiss 
          es[ice] = e_sat_ice(temp,ice).val[ice]
        end
        es.name = "e_sat"
        es.long_name = "e_sat"
        es
      end

      # relative humidity -> water vapor pressure
      #
      # ARGUMENTS
      # * rh: relative humidity
      # * temp: temperature
      # 
      # RETURN VALUE
      # * e: water vapor pressure
      def rh2e(rh,temp)
        es = e_sat(temp)
        rh = rh.convert_units("1")
        e = es * rh
        e.name = "e"
        e.long_name = "water vapor pressure"
        e
      end

      # Derive equivalent potential temperature
      # 
      # ARGUMENTS
      # * temp [GPhys] : temperature (ok whether degC or K)
      # * q [GPhys] : specific humidity
      # * prs [GPhys or VArray] : the pressure values. 
      #   If nil, searched from coordinates (for data on
      #   the pressure coordinate)
      # 
      # RETURN VALUE
      # * theta_e: equivalent potential temperature
      def theta_e(temp,q,prs=nil)
        tempK = temp.convert_units("K")
        theta = temp2theta(tempK, prs)
        theta_e = theta * Misc::EMath.exp( lat(tempK)*q/(Cp*tempK) )
        theta_e.name = "theta_e"
        theta_e.long_name = "equivalent potential temperature"
        theta_e
      end

      # Derive the saturation equivalent potential temperature
      # 
      # ARGUMENTS
      # * temp [GPhys] : temperature (ok whether degC or K)
      # * prs [GPhys or VArray] : the pressure values. 
      #   If nil, searched from coordinates (for data on
      #   the pressure coordinate)
      # 
      # RETURN VALUE
      # * theta_es: saturation equivalent potential temperature
      def theta_es(temp,prs=nil)
        tempK = temp.convert_units("K")
        theta = temp2theta(tempK, prs)
        q = e_sat(temp).e2q(prs)
        theta_e = theta * Misc::EMath.exp( lat(tempK)*q/(Cp*tempK) )
        theta_e.name = "theta_es"
        theta_e.long_name = "theta_e sat"
        theta_e
      end

    end
  end
end

################################################
##### test part ######
if $0 == __FILE__
  require "numru/ggraph"
  include NumRu

  #< data >

  temp = GPhys::IO.open("../../../testdata/T.jan.nc","T")
  u = GPhys::IO.open("../../../testdata/UV.jan.nc","U")
  v = GPhys::IO.open("../../../testdata/UV.jan.nc","V")

  #< theta >

  print "***** test theta *****\n\n"

  theta = GAnalysis::Met.temp2theta(temp)
  p theta
  DCL.swpset('iwidth',800)
  DCL.swpset('iheight',800)
  DCL.sgscmn(10)  # set colomap
  DCL.gropn(1)
  DCL.sgpset('isub', 96)      # control character of subscription: '_' --> '`'
  DCL.glpset('lmiss',true)
  DCL.sldiv("y",2,2)
  GGraph::set_fig "itr"=>2
  #GGraph::tone_and_contour temp.mean(0)
  GGraph::tone_and_contour theta.mean(0)

  p temp.coord(2).val[3]
  t = temp[0..1,0,3]
  p t.val
  p GAnalysis::Met.temp2theta(t).val
  p GAnalysis::Met.temp2theta(t,UNumeric[4e4,"Pa"]).val
  p GAnalysis::Met.temp2theta(UNumeric[20,"degC"],UNumeric[850,"hPa"]).val

  #< isentropic coordinate >

  print "\n***** test isentropic coordinate *****\n\n"
  sig_inv = GAnalysis::Met.sigma_inv(theta)
  GGraph::tone_and_contour 1/sig_inv.mean(0),true,"log"=>true,"title"=>"sigma"
  p( (sig_inv.units**(-1)).reduce5.to_s )

  theta_rg = theta.regrid(u)

  theta_levs = [320.0, 350.0, 400.0, 600.0, 800.0]
  u_th = GAnalysis::Met.interpolate_onto_theta(u, theta_rg, theta_levs)
  p u_th

#  DCL.grfrm
  GGraph::tone u.mean(0)
  GGraph::contour theta_rg.mean(0), false, "levels"=>theta_levs,"index"=>[3]
  GGraph::color_bar
  GGraph::set_fig "itr"=>1
  GGraph::tone_and_contour u_th.mean(0),true,"keep"=>true
  GGraph::color_bar

  #< isentropic potential vorticity >
  pv = GAnalysis::Met.pv_on_theta(u, v, theta_rg, theta_levs)
  p pv.units
  GGraph::tone_and_contour pv.mean(0),true
  GGraph::tone pv.cut("theta"=>320),true,"nlev"=>20,"color_bar"=>true
  GGraph::tone pv.cut("theta"=>600),true,"nlev"=>20,"color_bar"=>true


  #< moist thermo > 
  DCL.grfrm

  GGraph::set_fig "itr"=>2

  sel = [0,true,0..-4]

  es = temp[*sel].e_sat  
  # es = GAnalysis::Met.e_sat(temp[*sel])  #  same as temp[*sel].e_sat
  GGraph::tone es,true,"int"=>2e2,"max"=>4e3,"min"=>0,"tonf"=>true
  GGraph::contour temp[*sel],false
  GGraph.color_bar

  GAnalysis::Met.consider_ice=false
  es2 = temp[*sel].e_sat
  GGraph::tone( (es2-es)/es,true )
  GGraph.color_bar

#  GAnalysis::Met.set_e_sat_water("emanuel")
#  es3 = GAnalysis::Met.e_sat(temp[*sel])
#  GGraph::tone (es2-es3)/es3,true,"tonf"=>true
#  GGraph.color_bar

  qs = es.e2r
  GGraph::tone qs,true,"nlev"=>20
  GGraph.color_bar

  #< finish >
  DCL.grcls

end
