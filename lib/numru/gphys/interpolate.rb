require "numru/gphys/gphys"
require "numru/dcl"         # math1/gt2dlib is used for pure-2D interpolation.
                            # Also for dcl_fig_cut
require "numru/dcl_mouse"   # for mouse_cut, mouse_cut_repeat
require "narray_miss"                      

if $0 == __FILE__
  require "numru/gphys"  # for test
end

module NumRu
  class GPhys


    @@interpo_previous_cutter = nil
    @@interpo_previous_modifier = nil
    @@interpo_missval = 9.9692099683868690e+36 # NC_FILL_DOUBLE/FLOAT ~15*2^119
    @@interpo_extrapolation = false

    # Change the behavior of the interpolation methods to extrapolate 
    # outside the grid coverage.
    #
    # ARGUMENTS
    # * extrapo : true or false --- the default behaviour is false
    #   (not to extrapolate), so use this method if you
    #   want to set it to true.
    def self.extrapolation=(extrapo)
      @@interpo_extrapolation = extrapo
    end

    # Makes a subset interactively by specifying a (poly-)line on the DCL viewport
    # 
    # ARGUMENTS
    # * dimx {String] : name of number (0,1,..) of the dimension
    #   corresponding to the X coordinate in the current window of DCL
    # * dimy {String] : name of number (0,1,..) of the dimension
    #   corresponding to the Y coordinate in the current window of DCL
    # * num {Integer] : the number of points along the (poly-)line
    #   (2 or greater -- if 2, a single line segment; if 3 or more, a 
    #   poly-line)
    # 
    # RETURN VALUE
    # * a GPhys
    def mouse_cut(dimx, dimy, num=2, line_type=1, line_index=1)

      # < preparation >

      dimx = dim_index(dimx)
      dimy = dim_index(dimy)

      rundef = DCL.glpget("rundef")
      line = nil
      while(true)
        puts "\n*** Waiting for mouse click. Click #{num} points in the current viewport."
        line = DCLMouseLine.new(num)
        if line.ux.include?(rundef)
          puts "** The points specified include one(s) outside the U window. Do it again."
        else
          break
        end
      end
      line.draw(line_type, line_index)
      vx = line.vx
      vy = line.vy
      ux = line.ux
      uy = line.uy
      gpnew = dcl_fig_cut(dimx,dimy,ux,uy)
      [gpnew, line]
    end

    # Interpolation on the DCL window (automatic iso-interval interpolation
    # along a poly line that can be drawn in the current viewport of the
    # DCL window). Used in mouse_cut.
    # 
    # ARGUMENTS
    # * dimx [Integer or String] : specifies the dimension corresponding 
    #   to the UX coordinate.
    #   (Here, the UX coordinate is the X coordinate of the DCL's USER
    #   coordinate. For exapmle, longitude if map projection.)
    # * dimy [Integer or String] : specifies the dimension corresponding 
    #   to the UY coordinate.
    #   (Here, the UY coordinate is the Y coordinate of the DCL's USER
    #   coordinate. For exapmle, latitude if map projection.)
    # * ux [Array] : x values in terms of the UX coordinate
    # * uy [Array] : y values in terms of the UY coordinate
    #   Lengths of ux and uy must be the same and greter or equal to 2.
    # 
    def dcl_fig_cut(dimx,dimy,ux,uy)
      len = ux.length
      raise("ux and uy must be arrays with the (same) length >= 2") if len<=1
      raise("ux's len (#{len}) != uy's len (#{uy.length})") if uy.length != len
      vx=Array.new; vy=Array.new
      for i in 0...len
        vx[i],vy[i] = NumRu::DCL.stftrf(ux[i],uy[i]) 
      end
      kx = Array.new
      ky = Array.new
      cut = [true]*rank
      for i in 0...len
        cut[dimx] = ux[i]
        cut[dimy] = uy[i]
        dummy, sl = grid.cut(*cut)
        kx[i] = sl[dimx]
        ky[i] = sl[dimy]
      end
      ndiv = Array.new
      ndsum = [0]
      for i in 0...len-1
        ndiv[i] = Math.sqrt( (kx[i+1]-kx[i])**2 + (ky[i+1]-ky[i])**2).to_i
        ndiv[i] += 1 if i==len-2
        ndsum.push ndsum[-1] + ndiv[i]   # 0, ndiv[0], ndiv[0]+ndiv[1], ...
      end
      ndtot = ndsum[-1]
      vxdiv = NArray.float(ndtot)
      vydiv = NArray.float(ndtot)
      for i in 0...len-1
        if i!=len-2
          a = NArray.float(ndiv[i]).indgen / ndiv[i]
        else
          a = NArray.float(ndiv[i]).indgen / (ndiv[i]-1)
        end
        vxdiv[ndsum[i]...ndsum[i+1]] = (1.0-a)*vx[i] + a*vx[i+1]
        vydiv[ndsum[i]...ndsum[i+1]] = (1.0-a)*vy[i] + a*vy[i+1]
      end
      uxdiv = NArray.float(ndtot)
      uydiv = NArray.float(ndtot)
      for i in 0...ndtot
        uxdiv[i], uydiv[i] = DCL.stitrf(vxdiv[i], vydiv[i])
      end
      cx = coord(dimx)
      xcrd = VArray.new(uxdiv, cx, cx.name)
      cy = coord(dimy)
      ycrd = VArray.new(uydiv, cy, cy.name)
      if (vxdiv[-1]-vxdiv[0]).abs > (vydiv[-1]-vydiv[0]).abs
        cutter = [xcrd,ycrd]  # x will be the main coord var if not map proj
        crd = xcrd
      else
        cutter = [ycrd,xcrd]  # x will be the main coord var if not map proj
        crd = ycrd
      end
      axnm = crd.name
      itr = DCL.sgqtrn
      if itr>=10 and itr<=40
        newcrd = __sp_dist(xcrd,ycrd)
        modifier = Proc.new{|gp|
          newax = Axis.new.set_pos(newcrd)
          gp.grid.set_axis(axnm,newax)
          g = Grid.new( newax )
          gxcrd = GPhys.new(g,xcrd)
          gycrd = GPhys.new(g,ycrd)
          gp.set_assoc_coords([gxcrd, gycrd])
          gp
        }
      else
        modifier = nil
      end
      @@interpo_previous_cutter = cutter
      @@interpo_previous_modifier = modifier

      # < do the job >

      gpnew = interpolate(cutter)
      gpnew = modifier[gpnew] if modifier
      gpnew
    end

    # Interpolation onto grid points specified by the previous call of GPhys#mouse_cut
    def mouse_cut_repeat
      if @@interpo_previous_cutter.nil?
        raise("You must first use GPhys#mouse_cut. This method repeats it") 
      end
      gpnew = interpolate(@@interpo_previous_cutter)
      gpnew = @@interpo_previous_modifier[gpnew] if @@interpo_previous_modifier
      gpnew
    end

    def __sp_dist(lon,lat)
      x = lon.val * (Math::PI/180.0)   # lon in rad
      y = Math::PI/2 - lat.val*(Math::PI/180.0)   # rad from a pole
      cos_a = NMath::cos(y[1..-1])
      sin_a = NMath::sin(y[1..-1])
      cos_b = NMath::cos(y[0..-2])
      sin_b = NMath::sin(y[0..-2])
      cos_C = NMath::cos(x[1..-1]-x[0..-2])
      cos_c= cos_a*cos_b + sin_a*sin_b*cos_C   # from Spherical trigonometry
      mask = cos_c.gt(1.0)
      cos_c[mask] = 1.0      #  to deal with round error
      c = NMath::acos(cos_c)
      cs = c.cumsum * (180.0/Math::PI)
      cumdist = NArray.float(lon.length)
      cumdist[1..-1] = cs

      VArray.new(cumdist, 
              {"long_name"=>"distance along great circle","units"=>"degrees"}, 
              "dist")
    end
    private :__sp_dist

    # Interpolate to conform the grid to a target GPhys object
    #
    # ARGUMENTS
    # * to [GPhys] : the target gphys
    # 
    # RETURN VALUE
    # * a GPhys
    # 
    def regrid(to)
      coords = to.axnames.collect{|nm| to.coord(nm)}
      interpolate(*coords)
    end

    # Reverse the main data (i.e., the dependent variable) and one of the
    # coordinates (an independent variable) through interpolation.
    # 
    # Returns a GPhys in which the main data is the specfied coordinate
    # (argument: axname) sampled at specified locations (argument: pos)
    # in terms of the main data of self. The main data of self is expected
    # to be quai-monotonic with respect to the specfied coordinate.
    # 
    # ARGUMENTS
    # * axname [String] : one of the names of the axes (i.e. main 
    #   coordinates. Auxiliary coordinates are not supported as the target.)
    # * pos [NArray] : grid locations. For example, if the current data is
    #   potential temperature theta, pos consists of the theta levels to
    #   make sampling.
    #
    # RETURN VALUE
    # * a GPhys
    #   
    def coord_data_reverse(axname,pos)
      gp = self.axis(axname).to_gphys
      gp = self.shape_coerce_full(gp)[0]   # conform the shape to that of self
      gp = GPhys.new( gp.grid.copy, gp.data )  # copy grid to avoid side effect
                                               # on the grid of self
      gp.set_assoc_coords([self])
      pos = NArray[*pos].to_type(NArray::FLOAT) if pos.is_a?(Array)
      newcrd = VArray.new(pos,self.data,self.name)  # succeeds the attributes
      gp.interpolate(axname=>newcrd)
    end

    # Wide-purpose multi-dimensional linear interpolation
    # 
    # This method supports interpolation regarding combinations of 
    # 1D and 2D coordinate variables. For instance, suppose self is
    # 4D with coordinates named ["x", "y", "z", "t"] and associated
    # coordinates "sigma"["z"] ("sigma" is 1D and its axis is "z"),
    # "p"["x","y"], "q"["x","y"] ("p" and "q" are 2D having the
    # coordinates "x" and "y"). You can make interpolation by
    # specifying 1D VArrays whose names are among "x", "y", "z", "t",
    # "sigma", "p", "q". You can also use a Hash like {"z" => 1.0}
    # to specify a single point along the "x" coordinate.
    # 
    # If the units of the target coordinate and the current coordinate
    # are different, a converstion was made so that slicing is
    # made correctly, as long as the two units are comvertible;
    # if the units are not convertible, it is just warned.
    # 
    # If you specify only "x", "y", and "t" coordinates
    # for interpolation, the remaining coordinates "z" is simply
    # retained. So the result will be 4 dimensional 
    # with coordinates named ["x", "y", "z", "t"], but the
    # lengths of "x", "y", and "t" dimensions are changed according
    # to the specification. Note that the result could 
    # be 3-or-smaller dimensional -- see below.
    # 
    # Suppose you have two 1D VArrays, xnew and ynew, having
    # names "x" and "y", respectively, and the lengths of xnew and
    # the ynew are the same. Then, you can give an array of 
    # the two, [xnew, ynew], for coord0 as
    # 
    #   gp_int = gp_org.interpolate( [xnew, ynew] )
    # 
    # (Here, gp_org represents a GPhys object, and the return value
    # pointed by gp_int is also a GPhys.)  In this case, 
    # the 1st dimension of the result (gp_int) will be sampled
    # at the points [xnew[0],ynew[0]], [xnew[1],ynew[1]], [xnew[2],ynew[2]], 
    # ..., while the 2nd and the third dimensions are "z" and "t" (no 
    # interpolation). This way, the rank of the result will be reduced 
    # from that of self.
    # 
    # If you instead give xnew to coord0 and ynew to coord1 as 
    # 
    #   gp_int = gp_org.interpolate( xnew, ynew )
    # 
    # The result will be 4-dimensional with the first coordinate
    # sampled at xnew[0], xnew[1], xnew[2],... and the second
    # coordinate sampled at ynew[0], ynew[1], ynew[2],...
    #
    # You can also cut regarding 2D coordinate variable as
    # 
    #   gp_int = gp_org.interpolate( pnew, qnew )
    #   gp_int = gp_org.interpolate( xnew, qnew )
    #   gp_int = gp_org.interpolate( [pnew, qnew] )
    #   gp_int = gp_org.interpolate( [xnew, qnew] )
    # 
    # In any case, the desitination VArrays such as xnew ynew pnew qnew
    # must be one-dimensional.
    # 
    # Note that
    # 
    #   gp_int = gp_org.interpolate( qnew )
    # 
    # fails (exception raised), since it is ambiguous. If you tempted to
    # do so, perhaps what you want is covered by the following special
    # form:
    # 
    # As a special form, you can specify a particular dimension
    # like this:
    # 
    #   gp_int = gp_org.interpolate( "x"=>pnew )
    # 
    # Here, interpolation along "x" is made, while other axes are
    # retained. This is useful if pnew corresponds to a multi-D
    # coordinate variable where there are two or more corresponding axes
    # (otherwise, this special form is not needed.)
    # 
    # See the test part at the end of this file for more examples.
    # 
    # LIMITATION
    # 
    # Currently associated coordinates expressed by 3D or greater
    # dimensional arrays are not supported.
    # 
    # Computational efficiency of pure two-dimensional coordinate
    # support should be improved by letting C extensions cover deeper
    # and improving the search algorithm for grid (which is usually 
    # ordered quasi-regularly).
    # 
    # COVERAGE
    # 
    # Extrapolation is covered for 1D coordinates, but only
    # interpolation is covered for 2D coordinates (which is
    # limited by gt2dlib in DCL -- exception will be raised
    # if you specify a grid point outside the original 2D grid points.).
    # 
    # MATHEMATICAL SPECIFICATION
    # 
    # The multi-dimensional linear interpolation is done by
    # supposing a (hyper-) "rectangular" grid, where each 
    # dimension is independently sampled one-dimensionally. In case
    # of interpolation along two dimensional coordinates such as "p" 
    # and "q" in the example above, a mapping from a rectangular grid
    # is assumed, and the corresponding points in the rectangular grid 
    # is solved inversely (currently by using gt2dlib in DCL).
    # 
    # For 1D and 2D cases, linear interpolations may be expressed as
    # 
    #    1D:  zi = (1-a)*z0 + a*z1
    #    2D:  zi = (1-a)*(1-b)*z00 + a*(1-b)*z10 + (1-a)*b*z01 + a*b*z11 
    # 
    # This method is extended to arbitrary number of dimensions. Thus, 
    # if the number of dimensions to interpolate is S, then 2**S grid
    # points are used for each interpolation (8 points for 3D, 16 points
    # for 4D,...).  Thus, the linearity of this interpolation is only along 
    # each dimension, not over the whole dimensionality.
    # 
    # USAGE
    #   interpolate(coord0, coord1, ...)
    #
    # ARGUMENTS
    # * coord0, coord1,... [ 1D VArray, or Array of 1D VArray,
    #   or a 1-element Hash as 
    #   {coordinate_name(String) => slice_loc_value(Numeric)} ] :
    #   locations to which interpolation is made. Names of 
    #   all the VArray's in the arguments must exist among
    #   the names of the coordinates of self (including associated
    #   coordinates), since the dimension
    #   finding is made in terms of coordinate names.
    #   If an argument is an Array of VArray's, the first
    #   VArray will become the main coordinate variable,
    #   and the rest will be associated coordinates.
    # * [SPECIAL CASE]
    #   You can specfify a one-element Hash as the only argument
    #   such as
    #        gphys.interpolate("x"=>varray)
    #   where varray is a coordinate onto which interpolation is made.
    #   This is espcially useful if varray is multi-D. If varray's 
    #   name "p" (name of a 2D coordnate var), for example, 
    #   you can interpolate only regarding "x" by retaining other
    #   axes. If varray is 1-diemnsional, the same thing can
    #   be done simply by 
    #        gphys.interpolate(varray)
    #   since the corresponding 1D coordinate is found aotomatically.
    # 
    # RETURN VALUE
    # * a GPhys
    # 
    def interpolate(*coords)
      coords, org_coords, org_dims, newgrid = _interpo_match_coords(coords)
      crdmap = _interpo_reorder_2crdmap(coords, org_coords, org_dims)
      idxmap = _interpo_find_position(crdmap)

      z = val
      if z.is_a?(NArrayMiss)
        missval = ( (a=get_att('_FillValue')) ? a[0] : nil ) || 
                  ( (a=get_att('missing_value')) ? a[0] : nil ) || 
                  @@interpo_missval
        z = z.to_na(missval)
        input_nomiss = false
      else
        input_nomiss = true
        if @@interpo_extrapolation
          missval = nil
        else
          missval = @@interpo_missval
        end
      end

      na = c_interpo_do(newgrid.shape, idxmap, z, missval,
                        @@interpo_extrapolation)   # [C-extension]

      if !input_nomiss || !@@interpo_extrapolation
        mask = na.ne(missval)
        if !input_nomiss || mask.min == 0
          na = NArrayMiss.to_nam_no_dup(na,mask)
        end
      end

      va = VArray.new(na, data, name)

      ret = GPhys.new(newgrid, va)
      ret.grid.set_lost_axes(self.lost_axes)
      ret
    end

    private

    def _interpo_find_position(crdmap)
      idxmap = Array.new
      crdmap.each do|m|
        od = m[0]  # original dim(s): can be a Numeric or an Array of Numerics
        if od.is_a?(Numeric) 
          mp = m[1]
          cd = mp[0]  # current dimension to be treated in the new grid
          if mp.length==1
            idxmap.push( [m[0], cd] )  # simple copying
          elsif cd.is_a?(Numeric) && mp[1].is_a?(NArray)
            xto = mp[1]     # 1-D new coordinate var
            xfrom = mp[2]   # 1-D original coordinate var
            ids, f = c_interpo_find_loc_1D(xto,xfrom,@@interpo_missval,
                                     @@interpo_extrapolation)   # [C-extension]
            idxmap.push( [ m[0], cd, nil, ids, f ] )  # mapping from 1D
          else
            # partially 2D case
            cdims = mp[2]
            xto = mp[3]     # 1-D new coordinate var
            xfrom = mp[4]   # multi-D original coordinate var
            dimc = nil
            for i in 0...cdims.length
              if cdims[i] == od
                dimc = i
                break
              end
            end
            ids, f = c_interpo_find_loc_1D_MD(xto,xfrom,dimc,@@interpo_missval,
                                     @@interpo_extrapolation)   # [C-extension]

            dims_covd = mp[1] #dimensions covered by the coordinate variable(orig)
            idxmap.push( [ od, cd, dims_covd, ids, f ] )  # mapping from 2D
                          #^^
                          #will be removed : see (***) below
          end
        else
          # Full 2D mapping
          txi = m[1][0][1].to_type(NArray::SFLOAT)
          txg = m[1][0][2].to_type(NArray::SFLOAT)
          tyi = m[1][1][1].to_type(NArray::SFLOAT)
          tyg = m[1][1][2].to_type(NArray::SFLOAT)
          uxg = NArray.sfloat(txg.shape[0]).indgen!
          uyg = NArray.sfloat(txg.shape[1]).indgen!
          DCL.g2sctr(uxg,uyg, txg,tyg)
          if m[1][0][0] == m[1][1][0]
            len = txi.length
            ids1 = NArray.int(len)
            f1 = NArray.float(len)
            ids2 = NArray.int(len)
            f2 = NArray.float(len)
            for j in 0...len  
              ## [開発メモ] (高速化) このループはCにしたほうがいい（1Dなのでまあいいけど，下の2Dのをするなら一緒に）．その際，g2ictr は探索を高速化してないので，interpo_find_loc_1D の2D版の探索をした上で g2ibl2 を直接呼ぶ方がいい．
              begin
                uxi, uyi = DCL.g2ictr(txi[j], tyi[j])
                ids1[j] = [ [uxi.floor,0].max, uxg.length-2 ].min
                ids2[j] = [ [uyi.floor,0].max, uyg.length-2 ].min
                f1[j] = uxi - ids1[j]
                f2[j] = uyi - ids2[j]
              rescue
                ids1[j] = -999
                ids2[j] = -999
                f1[j] = 0.0
                f2[j] = 0.0
              end
            end
            idxmap.push( [ od[0], m[1][0][0], nil, ids1, f1] ) # mapping from 1D
            idxmap.push( [ od[1], m[1][0][0], nil, ids2, f2] ) # mapping from 1D
                          #^^^^
                          #will be removed : see (***) below
          else
            lenx = txi.length
            leny = tyi.length
            ids1 = NArray.int(lenx,leny)
            f1 = NArray.float(lenx,leny)
            ids2 = NArray.int(lenx,leny)
            f2 = NArray.float(lenx,leny)
            for k in 0...leny  
              for j in 0...lenx  
                ## [開発メモ] (高速化) このループはCにしたほうがいい(2Dだし特に)．その際，g2ictr は探索を高速化してないので，interpo_find_loc_1D の2D版の探索をした上で g2ibl2 を直接呼ぶ方がいい．
                begin
                  uxi, uyi = DCL.g2ictr(txi[j], tyi[k])
                  ids1[j,k] = [ [uxi.floor,0].max, uxg.length-2 ].min
                  ids2[j,k] = [ [uyi.floor,0].max, uyg.length-2 ].min
                  f1[j,k] = uxi - ids1[j,k]
                  f2[j,k] = uyi - ids2[j,k]
                rescue
                  ids1[j,k] = -999
                  ids2[j,k] = -999
                  f1[j] = 0.0
                  f2[j] = 0.0
                end
              end
            end
            idxmap.push( [ od[0], m[1][0][0], [m[1][1][0]], ids1, f1] )  # mapping from 2D
            idxmap.push( [ od[1], m[1][0][0], [m[1][1][0]], ids2, f2] )  # mapping from 2D
                          #^^^^
                          #will be removed : see (***) below
          end
        end
      end

      if idxmap.length != rank
        raise "Something is wrong: a BUG, or possibly overly specified?"
      end

      idxmap.sort!

      idxmap.each_with_index do |m,i|
        d = m.shift   # the first element is removed (***)
        if d!=i
          raise "Something is wrong: a BUG, or possibly overly specified? #{d}"
        end
      end

      idxmap
    end

    # put the coorinate mapping into a data structure good for 
    # algorithm implementation 
    #
    # RETURN VALUE
    # * crdmap : info regarding mapping from dimensions of self
    #   to those of the new grid. Ordered as [ pure 1D interpolations..,
    #   multi-D interpolations that can be reduced to 1D interpolations,...
    #   pure multi-D (actually 2D) interpolations,...]
    def _interpo_reorder_2crdmap(coords, org_coords, org_dims)
      cids = Array.new  # array (whose length is the rank of newgrid) of ids
      cf = Array.new    # array (whose length is the rank of newgrid) of f
      crdmap1D = Array.new
      crdmap2D = Array.new
      for ic in 0...org_coords.length
        if coords[ic].nil?  # simple copying
          crdmap1D.push( [ org_dims[ic], ic ] )
        else
          for j in 0...coords[ic].length
            xto = coords[ic][j].val
            xfrom = org_coords[ic][j].val
            xto = xto.to_na if !xto.is_a?(NArray)  
                  # missing in the coordinate, if any, is ignored
            if xfrom.is_a?(NArrayMiss)
              xfrom = xfrom.to_type(NArray::FLOAT).to_na(@@interpo_missval)
              # if xfrom is NArrayMiss, this fixed missing value is set.
              # The conversion into double is just in case (not needed for
              # the default @@interpo_missval).
            end
            if org_dims[ic][j].length == 1
              crdmap1D.push( [ org_dims[ic][j][0], ic, xto, 
                               xfrom] )
            else
              crdmap2D.push( [ org_dims[ic][j], ic, xto, 
                               xfrom, coords[ic][j].name] )
            end
          end
        end
      end

      crdmap1D.sort!   # sort by the original dimension ids
      for i in 0...(crdmap1D.length-1)
        d = crdmap1D[i][0]
        if (d == crdmap1D[i+1][0])
          raise("Coordinates to interpolate are overly specified for #{axis(d).name}(#{d})")
        end
      end

      odim_covrd = crdmap1D.collect{|m| m[0]}

      crdmapH = Hash.new
      crdmap1D.each do |m|
        crdmapH[m[0]] = m[1..-1]
      end

      crdmap = crdmapH.to_a.sort!

      pure2D = Array.new
      crdmap2D.each do |m|
        indep = m[0] - odim_covrd
        if indep.length == 0  # over-determined
          raise("Coordinates to interpolate are overly specified: Unnecesary 2D spec exists")
        elsif indep.length == 1 # partially determined (except for one dim)
          od = indep[0]
          odcov = (m[0] - indep)#[0]
          dims_covd = odcov.collect{|d| crdmapH[d][0]}
          oc_covd_int_needed = Array.new
          ocrd = m[3]
          odcov.each do |d|
            a = crdmapH[d]
            if a[2]
              va = coords[d][0]
              oc_covd_int_needed.push(va) 
            end
          end
          if oc_covd_int_needed.length > 0
            cname = m[4]
            cmd = self.assoc_coord_gphys(cname)
            ocrd = cmd.interpolate(*oc_covd_int_needed).val   # interpolate the multi-D coord first
          end
          crdmap.push(xxx=[od, [ m[1], dims_covd, m[0], m[2], ocrd ] ])
          odim_covrd.push(od)  # covered this time
        else
          if m[0].length >= 3
            raise(ArgumentError,"Pure multi-D interpolation is limited upto 2D #{m[0]}")
          end
          pure2D.push(m)
        end
      end

      pure2D.sort!
      while (pure2D.length > 0)
        m1 = pure2D.shift
        m2 = pure2D.shift
        if ( m2.nil? || m1[0] != m2[0] )
          raise("Insufficient specification of 2D slicing: Pair needed")
        end
        crdmap.push( [m1[0], [m1[1..-1],m2[1..-1]]] )
        m1[0].each{|x| odim_covrd.push(x)}
      end

      if odim_covrd.length != rank
        raise("[BUG] Sorry. Something is wrong. Should be a bug.")
      end

      crdmap
    end

    def _interpo_match_coords(coords)

      if coords[0].is_a?(Hash) && coords[0].length==1  # a special case
        dimname, varray = coords[0].to_a[0]
        coords = [ varray ]
        dim = dim_index(dimname) or raise("dimension #{dimname} does not exist")
        nochange_dims = Array.new
        (rank-1).downto(0){|i| nochange_dims.push(i) if i!=dim}
      else
        nochange_dims = nil
      end

      #< to Array of Arrays if not for easiness of treatment >

      coords.collect! do |x|
        x.is_a?(Array) ? x : [x]
      end

      #< check the array contents and modify them if desirable >

      coords.each do |a|
        a.collect! do |x|
          if x.is_a?(Hash) and 
              ( k,v = x.to_a[0]; k.is_a?(String) && v.is_a?(Numeric) )
            na = NArray[v]
            x = VArray.new( na, coord(k), k )
          elsif !(x.is_a?(VArray) and x.rank==1)
            raise(ArgumentError, "Arguments must consist only of 1D VArrays or 1-element Hashs to specify coordinate name (String) and slicing location (Numeric).")
          end
          x
        end
      end

      #< investigate the correspondence >
      org_dims = coords.collect do |a|
        a.collect do |va|
          ids = grid.coord_dim_indices(va.name)
          if ids.nil?
            raise(ArgumentError, "'#{va.name}' is not in the coordiantes #{coordnames.inspect}") 
          end
          if ids.length > 4
            raise(ArgumentError, "coord whose rank is greater than 4 is not supported : #{va.name} mapped to dims: #{ids.inspect}") 
          end
          ids
        end
      end

      if !nochange_dims
        nochange_dims = (0...rank).collect{|i| i}.reverse - org_dims.flatten
      end

      #< corresponding original coordinates >
      org_coords = Array.new
      coords.each do |a|
        oa = Array.new
        org_coords.push(oa)
        a.each do |va|
          crd = coord(va.name)
          units_to = va.units
          units_orig = crd.units
          if ( units_to =~ units_orig )
            crd = crd.convert_units(units_to)
          else
            $stderr.print("WARNING: incompatible units (#{va.name}): #{units_orig} - #{units_to}\n")
          end
          oa.push( crd )
        end      
      end

      #< prepare the new grid >

      axes = coords.collect do |a|
        Axis.new().set_pos(a.first)
      end

      #insdims = Array.new
      gaxes = axes.dup
      irank = org_dims.length
      nochange_dims.each do |nd|
        (org_dims.length-1).downto(0) do |id|
          x = org_dims[id]
          d = x.is_a?(Integer) ? x : (x.flatten - nochange_dims).max
          if d < nd
            gaxes.insert(id+1, axis(nd))  # insert after id
            coords.insert(id+1, nil)
            org_coords.insert(id+1, nil)
            org_dims.insert(id+1, nd)
            break
          elsif id==0
            gaxes.insert(id, axis(nd))  # unshift
            coords.insert(id, nil)
            org_coords.insert(id, nil)
            org_dims.insert(id, nd)
          end
        end
      end

      newgrid = Grid.new(*gaxes)

      assoc = Array.new
      coords.each_with_index do |a,i|
        if !a.nil? && a.length > 1
          ax = axes[i]
          axgrd = Grid.new(ax)
          a[1..-1].each do |va|
            if va.length != ax.length
              raise("coord size mismatch: #{va.inspect} - #{ax.pos.inspect}")
            end
            assoc.push( GPhys.new(axgrd, va) )
          end 
        end
      end

      if assoc.length > 0
        newgrid.set_assoc_coords(assoc)
      end

      [coords, org_coords, org_dims, newgrid]
    end
  end
end

#######################################
## < test >
if $0 == __FILE__
  require "numru/ggraph"
  include NumRu
  include NMath

  module NumRu
    class VArray
      def to_g1D
        ax = Axis.new().set_pos(self)
        grid = Grid.new(ax)
        GPhys.new(grid,self)
      end
    end
  end

  #< prepare a GPhys object with associated coordinates >

  nx = 10
  ny = 8
#  nx = 20
#  ny = 16
  nz = 2
  x = (NArray.sfloat(nx).indgen! + 0.5) * (2*PI/nx)
  y = NArray.sfloat(ny).indgen! * (2*PI/(ny-1))

  z = NArray.sfloat(nz).indgen! 
  vx = VArray.new( x, {"units"=>"m"}, "x")
  vy = VArray.new( y, {"units"=>"m"}, "y")
  vz = VArray.new( z, {"units"=>"m"}, "z")
  xax = Axis.new().set_pos(vx)
  yax = Axis.new().set_pos(vy)
  zax = Axis.new().set_pos(vz)
  xygrid = Grid.new(xax, yax)
  xyzgrid = Grid.new(xax, yax, zax)

  sqrt2 = sqrt(2.0)

  p = NArray.sfloat(nx,ny)
  q = NArray.sfloat(nx,ny)
  for j in 0...ny
    p[true,j] = NArray.sfloat(nx).indgen!(2*j,1)*sqrt2
    q[true,j] = NArray.sfloat(nx).indgen!(2*j,-1)*sqrt2
  end
  vp = VArray.new( p, {"units"=>"mm"}, "p")
  vq = VArray.new( q, {"units"=>"mm"}, "q")
  gp = GPhys.new(xygrid, vp) 
  gq = GPhys.new(xygrid, vq) 

  r = NArray.sfloat(nz).indgen! * 2
  vr = VArray.new( r ).rename("r")
  gr = GPhys.new( Grid.new(zax), vr ) 

  d = sin(x.newdim(1,1)) * cos(y.newdim(0,1)) + z.newdim(0,0)
  vd = VArray.new( d ).rename("d")
  gd = GPhys.new(xyzgrid, vd)

  gx = vx.to_g1D
  ga = gd + gx 
  ga.name = "a"

  gd.set_assoc_coords([gp,gq,gr,ga])

  #print "GPhys with associated coordinates:\n"
  #p gd


  DCL.swpset('iwidth',700)
  DCL.swpset('iheight',700)
  #DCL.sgscmn(4)  # set colomap
  DCL.gropn(1)
  DCL.sgpset('isub', 96)      # control character of subscription: '_' --> '`'
  DCL.glpset("lmiss",true)
  DCL.sldiv("y",2,2)
  GGraph::set_fig "viewport"=>[0.15,0.85,0.15,0.85]
  GGraph::tone gd
  GGraph::color_bar
  GGraph::tone gd[true,ny/2,true]
  GGraph::color_bar
  gdd = gd.copy

  #< prepare coordinates to interpolate >

  xi = NArray[1.0, 2.0, 3.0, 4.0, 5.0]
#  yi = NArray[1.0, 4.0, 5.0]
  yi = NArray[-0.1,2.5, 4.0, 5.5, 6.8]  # test of extrapolation
  vxi = VArray.new( xi, {"units"=>"m"}, "x")  # "0.5m" to test unit conversion
  vyi = VArray.new( yi, {"units"=>"m"}, "y")  # "0.5m" to test unit conversion

#  pi = NArray[10.0, 13.0, 15.0, 17.0, 20.0]
#  qi = NArray[0.0,  3.0,  5.0,  7.0,  10.0]
#  pi = NArray.float(23).indgen!*0.5+8
#  qi = NArray.float(23).indgen!*0.5-3
  pi = NArray.float(6).indgen!*2+10
  qi = NArray.float(6).indgen!*2
  vpi = VArray.new( pi, {"units"=>"mm"}, "p")
  vqi = VArray.new( qi, {"units"=>"mm"}, "q")

  ai = NArray[2.0, 2.5]
  vai = VArray.new( ai ).rename("a")

  #< test of interpolate >

  gxi = vxi.to_g1D
  gyi = vyi.to_g1D
  gp = GPhys.new(xygrid,vp)
  gq = GPhys.new(xygrid,vq)

  #GPhys::extrapolation = true
  gi = gd.interpolate(vxi,vyi,{"z"=>0.5})
  GGraph::tone gi,true,"color_bar"=>true

  ###gd.interpolate(vxi,vyi,vr,vz)   # nust fail by over-determination

  gi = gd.interpolate([vxi,vyi])
  #p gi.max, gi.min
  GGraph::tone gd[false,0],true,"min"=>-1.2,"max"=>1.2,"int"=>0.1
  GGraph::scatter gxi, gyi, false,"type"=>4,"size"=>0.027,"index"=>3
  GGraph::color_scatter gxi, gyi, gi[true,0], false,"min"=>-1.2,"max"=>1.2,"int"=>0.1,"type"=>10,"size"=>0.029
  GGraph::color_bar

  gi = gd.interpolate(vyi,vxi)
  GGraph::tone gi,true,"color_bar"=>true

  #GGraph::tone gp,true,"color_bar"=>true

  GGraph::tone gq,true
  GGraph::contour gq,false
  GGraph::color_bar

  gi = gd.interpolate(vxi,vqi)
  GGraph::tone gi,true,"color_bar"=>true
  ##gi = gd.interpolate(vx,vqi)

  gi = gd.interpolate("y"=>vqi)
  #GGraph::tone gi,true,"color_bar"=>true

  #p "###",gd.coordnames
  #gi = gd.interpolate(vxi,vyi,vai)
  gi = gd.interpolate("y"=>vai)
  GGraph::tone gi[2,false],true,"color_bar"=>true

  GGraph::tone gp,true
  GGraph::contour gp,false
  GGraph::color_bar
  gi = gd.interpolate("x"=>vpi)
  GGraph::tone gd
  GGraph::tone gi,true,"color_bar"=>true,"exchange"=>true,"min"=>-1,"max"=>1

  gi = gd.interpolate([vpi,vqi])
  GGraph::tone gi,true,"color_bar"=>true

  GGraph::tone gd
  GGraph::tone gd.cut("p"=>vpi.min.to_f..vpi.max.to_f,"q"=>vqi.min.to_f..vqi.max.to_f),true

  gi = gd.interpolate(vpi,vqi)
  GGraph::tone gi,true,"color_bar"=>true

  gi = gd.interpolate(vqi,vpi)
  GGraph::tone gi,true,"color_bar"=>true

  gi2 = gd.regrid(gi[false,0])
  p "regriding test (should be true):", gi.val == gi2.val

  gi = gd.interpolate(vqi,vpi,{"z"=>0.5})
  GGraph::tone gi,true,"color_bar"=>true

  ###gd.interpolate(vpi)   # must fail by insufficient specification


  mask=d.lt(0.7)
  missv = -999.0
  d[mask.not] = missv
  #p d[false,0]
  dm = NArrayMiss.to_nam(d, mask )
  vdm = VArray.new( dm, {"missing_value"=>NArray[missv]}, "d")
  gdm = GPhys.new(xyzgrid, vdm)
  gi = gdm.interpolate(vpi,vqi)
#  gi = gdm.interpolate(vxi,vyi)
  GGraph::tone gi,true,"color_bar"=>true
  
  print "start the test of coord_data_reverse\n"
  GGraph::tone gp
  GGraph::color_bar
  xp = gp.coord_data_reverse("x",NArray.sfloat(30).indgen! )
  GGraph::tone xp,true,"title"=>"#{xp.name} <-coord_data_reverse"
  GGraph::color_bar

  #< test of mouse_cut / dcl_fig_cut >
  gdc = gdd[1..-1,1..-1,true]

=begin
  GGraph.set_fig "itr"=>4
  GGraph.tone gdc,true,"int"=>0.15,"min"=>-1.05,"max"=>1.05
  gpcut, line = gdc.mouse_cut(0,1,3)
  x = gpcut.coord("x")
  y = gpcut.coord("y")
  DCL.sgpmzu(x.val,y.val,2,1,0.015)
  GGraph.set_fig "itr"=>1
  GGraph.tone gpcut,true,"int"=>0.15,"min"=>-1.05,"max"=>1.05
  GGraph.color_bar
=end

  GGraph.set_fig "itr"=>4
  GGraph.tone gdc,true,"int"=>0.15,"min"=>-1.05,"max"=>1.05
  gpcut = gdc.dcl_fig_cut(0,1,[1.0,3.0,6.0],[1.1,2.2,5.5])
  x = gpcut.coord("x")
  y = gpcut.coord("y")
  DCL.sgplu(x.val,y.val)
  DCL.sgpmzu(x.val,y.val,2,1,0.015)
  GGraph.set_fig "itr"=>1
  GGraph.tone gpcut,true,"int"=>0.15,"min"=>-1.05,"max"=>1.05
  GGraph.color_bar
  

  #< finish >
  DCL.grcls
end
