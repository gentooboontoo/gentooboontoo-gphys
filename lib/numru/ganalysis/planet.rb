# = NumRu::GAnalysis::Planet : Library for spherical planets (default: Earth)
#
# ASSUMPTIONS
# * longitude is assumed to increase in the eastward direction.
# * latitude is assumed to increase in the northward direction,
#   and it is zero at the equator.

require "numru/gphys"
require 'numru/gphys/derivative'

module NumRu
  module GAnalysis

    module Planet
      module_function

      #< Pre-defined planets >

      Earth = "Earth"
      def init(planet)
        case planet
        when Earth
          @@R = UNumeric[6.37e6, "m"]
          @@Ome = UNumeric[2*Math::PI/8.64e4,"s-1"]
        else
          raise "Unsupported predefined planet: #{planet}."
        end
      end

      init(Earth)    ###### default setting as the Earth ######

      #< Adjustable planetary settings >

      def radius=(r); @@R = r; end
      def omega=(o);  @@Ome = o; end
      def radius; @@R; end
      def omega; @@Ome; end

      #< Class variables regarding lon & lat >

      @@lonbc = GPhys::Derivative::CYCLIC_OR_LINEAR # this should be always fine
      # @@latbc = GPhys::Derivative::LINEAR_EXT       # this should be always fine

      @@lam = nil  # lambda (lon in radian) obtaiend lately (see get_lambda_phi)
      @@phi = nil  # phi (lat in radian) obtaiend lately (see get_lambda_phi)

      #< Differentian at the planets's near surface. With suffix "_s" >

      def latbc(phi)
=begin
        # not so good
        pi2 = Math::PI/2
        eps = 0.1
        xs = phi[0..1].val 
        xe = phi[-2..-1].val
        if (pi2-xs[0].abs) / (xs[0]-xs[1]).abs < eps and
           (pi2-xe[-1].abs) / (xe[-1]-xe[-2]).abs < eps 
          GPhys::Derivative::MIRROR_B
        else
          GPhys::Derivative::LINEAR_EXT
        end
=end
        GPhys::Derivative::LINEAR_EXT
      end

      def rot_s(u,v)
        lam, phi, lond, latd  = get_lambda_phi(u)
        cos_phi = phi.cos
        dv_dlam = v.cderiv(lond,@@lonbc,lam)
        duc_dphi  = (u*cos_phi).cderiv(latd,latbc(phi),phi)
        rot = (dv_dlam - duc_dphi) / (@@R*cos_phi)
        rot.long_name = "rot(#{u.name},#{v.name})"
        rot.name = "rot"
        rot
      end

      def div_s(u,v)
        lam, phi, lond, latd  = get_lambda_phi(u)
        cos_phi = phi.cos
        du_dlam = u.cderiv(lond,@@lonbc,lam)
        dvc_dphi  = (v*cos_phi).cderiv(latd,latbc(phi),phi)
        rot = (du_dlam + dvc_dphi) / (@@R*cos_phi)
        rot.long_name = "div(#{u.name},#{v.name})"
        rot.name = "div"
        rot
      end

      def vor_s(u,v)
        vor = rot_s(u,v)
        vor.long_name = "Relative Vorticity"
        vor.name = "vor"
        vor
      end
      
      def absvor_s(u,v)
        avor = vor_s(u,v) + @@phi.sin * (2*@@Ome)
        avor.long_name = "Absolute Vorticity"
        avor.name = "avor"
        avor
      end

      def grad_s(s)
        lam, phi, lond, latd  = get_lambda_phi(s)
        cos_phi = phi.cos
        xs = s.cderiv(lond,@@lonbc,lam) / (@@R*cos_phi)
        ys = s.cderiv(latd,latbc(phi),phi) / @@R
        xs.long_name = "xgrad(#{s.name})"
        xs.name = "xgrad"
        ys.long_name = "ygrad(#{s.name})"
        ys.name = "ygrad"
        [xs,ys]
      end

      def grad_sx(s)
        lam, phi, lond, latd  = get_lambda_phi(s)
        cos_phi = phi.cos
        xs = s.cderiv(lond,@@lonbc,lam) / (@@R*cos_phi)
        xs.long_name = "xgrad(#{s.name})"
        xs.name = "xgrad"
        xs
      end

      def grad_sy(s)
        lam, phi, lond, latd  = get_lambda_phi(s)
        cos_phi = phi.cos
        ys = s.cderiv(latd,latbc(phi),phi) / @@R
        ys.long_name = "ygrad(#{s.name})"
        ys.name = "ygrad"
        ys
      end

      def grad_sy_cosphifact(s,cosphi_exponent)
        lam, phi, lond, latd  = get_lambda_phi(s)
        cos_phi = phi.cos
        cos_phi_factor = cos_phi**cosphi_exponent
        ys = (s*cos_phi_factor).cderiv(latd,latbc(phi),phi)/cos_phi_factor / @@R
        ys.long_name = "ygrad(#{s.name})"
        ys.name = "ygrad"
        ys
      end

      def weight_tanphi(s, tan_exp, r_exp)
        lam, phi, lond, latd  = get_lambda_phi(s)
        tan_phi = phi.tan
        ys = s * (tan_phi**tan_exp * @@R**r_exp)
        ys
      end

      def weight_cosphi(s, cos_exp, r_exp)
        lam, phi, lond, latd  = get_lambda_phi(s)
        cos_phi = phi.cos
        ys = s * (cos_phi**cos_exp * @@R**r_exp)
        ys
      end

      def weight_sinphi(s, sin_exp, r_exp)
        lam, phi, lond, latd  = get_lambda_phi(s)
        sin_phi = phi.sin
        ys = s * (sin_phi**sin_exp * @@R**r_exp)
        ys
      end

      #< helper methods >

      # Find longitude and latitude coordinates and convert into
      # radian.
      #
      # RETURN VALUE
      # * [lam, phi, lond, latd]
      #   * lam (GPhys): longitude in radian (lambda). 
      #     (nil if not found && !err_raise)
      #   * phi (GPhys): latitude in radian (lambda). 
      #     (nil if not found && !err_raise)
      #   * lond : Interger to show that longitude is the lon-th dim if found; 
      #     (nil if not found && !err_raise)
      #   * latd : Interger to show that latitude is the lat-th dim iffound;
      #     (nil if not found && !err_raise)
      def get_lambda_phi(gp, err_raise=true)
        lond, latd = find_lon_lat_dims(gp, err_raise)
        lam = lond && gp.axis(lond).to_gphys.convert_units("rad") # lon in rad
        lam.units = "" if lond                            # treat as non-dim
        phi = latd && gp.axis(latd).to_gphys.convert_units("rad") # lat in rad
        phi.units = "" if latd                            # treat as non-dim
        @@lam = lam
        @@phi = phi
        [lam, phi, lond, latd]
      end

      # Find longitude and latitude coordinates.
      # 
      # ARGUMENTS
      # * gp : GPhys to inspect
      # * err_raise (OPTIONAL; default:false) : if true, exception is raised
      #   if longitude or latitude coordinate is not found.
      # 
      # SEARCH CRITERIA
      # (1) Find coord having units "degrees_east" (lon) or 
      #     "degrees_north" (lat)
      # (2) Investigate coordinate name matches (to find a lonitude coord, 
      #     /longitude/i for long_name or standard_name, or /^lon/ for name)
      #     and match units compatible with "degrees".
      #
      #
      # RETURN VALUE
      # * [lond,latd]
      #   * lond: dimension number of longitude (0,1,..) if found / 
      #     nil if not found
      #   * latd: dimension number of latitude (0,1,..) if found / 
      #     nil if not found
      #
      def find_lon_lat_dims(gp, err_raise=false)
        lond = nil
        latd = nil
        (0...gp.rank).each do |dim|
          crd = gp.coord(dim)
          if /^degrees?_east$/i =~ crd.get_att("units")
            lond = dim
            break
          elsif ( ( /longitude/i =~ crd.long_name || 
                    /^lon/i =~ crd.name ||
                    (nm=crd.get_att("standard_name") && /longitude/i =~ nm ) &&
                    (crd.units =~ Units["degrees_east"]) ) )
            lond = dim
            break
          end
        end
        (0...gp.rank).each do |dim|
          next if dim == lond
          crd = gp.coord(dim)
          if /^degrees?_north$/i =~ crd.get_att("units")
            latd = dim
            break
          elsif ( ( /latitude/i =~ crd.long_name || 
                    /^lat/i =~ crd.name ||
                    (nm=crd.get_att("standard_name") && /latitude/i =~ nm ) &&
                    (crd.units =~ Units["degrees_north"]) ) )
            latd = dim
            break
          end
        end
        if err_raise
          raise("Longitude dimension was not found") if !lond
          raise("Latitude dimension was not found") if !latd
        end
        [lond,latd]
      end
    end

  end

=begin
  class GPhys

    # Find longitude and latitude coordinates.
    # 
    # SEARCH CRITERIA
    # (1) Find coord having units "degrees_east" (lon) or 
    #     "degrees_north" (lat)
    # (2) Investigate coordinate name matches (to find a lonitude coord, 
    #     /longitude/i for long_name or standard_name, or /^lon/ for name)
    #     and match units compatible with "degrees".
    #
    # ARGUMENT
    # * out_in_radian (OPTIONAL default:false) : if true, output is made
    #   in radian
    #
    # RETURN VALUE
    # * [lon, lat, dimlon, dimlat]
    #   * lon : VArray representing longitude if found; nil if not found.
    #     By default (out_in_radian==false), its units are converted into 
    #     "degrees_east" if not; If out_in_radian==true, converion is made
    #     into "radian".
    #   * lat : VArray representing latitude if found; nil if not found.
    #     By default (out_in_radian==false), its units are converted into 
    #     "degrees_north" if not; If out_in_radian==true, converion is made
    #     into "radian".
    #   * lon : Interger to show that longitude is the lon-th dim if found; 
    #     nil if not found.
    #   * lat : Interger to show that latitude is the lat-th dim iffound;
    #     nil if not found.
    def get_lon_lat_coord(out_in_radian=false)
      unrad = Units["radian"]

      #< find longitude >
      unlon = Units["degrees_east"]
      reg_additional = /east/
      lon = dimlon = nil
      for dim in 0...rank
        crd = coord(dim)
        uncrd = crd.units
        if uncrd == unlon && reg_additional =~ uncrd.to_s
          dimlon = dim
          lon = crd
          break
        elsif ( ( /longitude/i =~ crd.long_name || 
                  /^lon/i =~ crd.name ||
                  (nm=crd.get_att("standard_name") && /longitude/i =~ nm ) &&
                  (uncrd =~ unlon) ) )
          dimlon = dim
          lon = crd
          break
        end
      end
      if lon 
        if out_in_radian
          lon = lon.convert_units(unrad)
        else
          lon = lon.convert_units(unlon)
        end
      end
      
      #< find latitude >
      unlat = Units["degrees_north"]
      reg_additional = /north/
      lat = dimlat = nil
      for dim in 0...rank
        next if dim == dimlon
        crd = coord(dim)
        uncrd = crd.units
        if uncrd == unlat && reg_additional =~ uncrd.to_s
          dimlat = dim
          lat = crd
          break
        elsif ( ( /latitude/i =~ crd.long_name || 
                  /^lat/i =~ crd.name ||
                  (nm=crd.get_att("standard_name") && /latitude/i =~ nm ) &&
                  (uncrd =~ unlat) ) )
          dimlat = dim
          lat = crd
          break
        end
      end
      if lat 
        if out_in_radian
          lat = lat.convert_units(unrad)
        else
          lat = lat.convert_units(unlon)
        end
      end
      
      [lon, lat, dimlon, dimlat]
    end
    
  end
=end

end

################################################
##### test part ######
if $0 == __FILE__
  require "numru/ggraph"
  include NumRu
  u = GPhys::IO.open("../../../testdata/UV.jan.nc","U")
  v = GPhys::IO.open("../../../testdata/UV.jan.nc","V")
  ##i = 3
  ##u = GPhys::IO.open("/mnt/disk2/horinout/ncep/daily/pressure/uwnd.2008.nc","uwnd")[{0..-1=>i},{1..-2=>i},true,0]
  ##v = GPhys::IO.open("/mnt/disk2/horinout/ncep/daily/pressure/vwnd.2008.nc","vwnd")[{0..-1=>i},{1..-2=>i},true,0]
  rot = GAnalysis::Planet.rot_s(u,v)
  avor = GAnalysis::Planet.absvor_s(u,v)
  div = GAnalysis::Planet.div_s(u,v)
  print "*** test ***\n"
  p rot
  p rot.units
  p rot.max,rot.min

  DCL.swpset('iwidth',700)
  DCL.swpset('iheight',700)
  DCL.sgscmn(10)  # set colomap
  DCL.gropn(1)
  DCL.sgpset('isub', 96)      # control character of subscription: '_' --> '`'
  DCL.glpset('lmiss',true)
  DCL.sldiv("y",1,2)
  DCL.sgpset("lfull",true)
  GGraph::set_fig "itr"=>10,"viewport"=>[0.1, 0.8, 0.05, 0.4]
  GGraph::set_map "coast_world"=>true
  iz = 4
  GGraph::vector u[false,iz], v[false,iz],true  #,"fact"=>2
  #GGraph::tone u[false,iz],true,"color_bar"=>true
  GGraph::tone rot[false,iz],true,"max"=>2e-5,"min"=>-2e-5,"int"=>2e-6
  ##GGraph::tone rot[false,iz],true,"max"=>1e-4,"min"=>-1e-4,"int"=>1e-5
  GGraph::tone avor[false,iz],true,"max"=>2e-4,"min"=>-2e-4,"int"=>2e-5
  GGraph::color_bar
  GGraph::tone div[false,iz],true,"max"=>0.5e-5,"min"=>-0.5e-5,"int"=>0.5e-6
  GGraph::color_bar
  DCL.grcls

  print "\n\n*** test lon/lat coords ***\n"
  p GAnalysis::Planet.find_lon_lat_dims(u)
  #u.get_lon_lat_coord.each{|x| p x}
  #u.get_lon_lat_coord(true).each{|x| p x}
end
