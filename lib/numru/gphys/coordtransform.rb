require "numru/gphys/coordmapping"
require "numru/gphys/gphys"
begin
  require "numru/ssl2"
  HAVE_NUMRU_SSL2 = true
rescue LoadError
  HAVE_NUMRU_SSL2 = false
end

=begin
=class NumRu::GPhys

Additional methods regarding coordinate transformation.

== Methods

---coordtransform( coordmapping, axes_to, *dims )

     Coordinate transformation with ((|coordmapping|)) into ((|axes_to|)).

     ARGUMENTS
     * ((|coordmapping|)) (CoordMapping) : relation between the new and
       original coordinate systems. Mapping is defined from the new one to
       the orinal one. If the rank of the mapping is smaller than 
       the rank of self, ((|dims|)) must be used to specify the
       correspondence. e.g., if the rank of the mapping is 2 and that 
       of self is 3 and the mapping is regarding the first 2 dimensions
       of the three, ((|dims|)) must be [0,1].
     * ((|axes_to|)) (Array of Axis) : grid in the new coordinate system.
       Its length must be the same as the rank of ((|coordmapping|))
     * ((|dims|)) (integers) : Specifies the dimensions to which 
       ((|coordmapping|)) is applied. Needed if 
       (({self.rank!=coordmapping.rank})) (neglected otherwise). 
       The number of integers must agree with the rank of the mapping.

=end

module NumRu
  class GPhys

    def coordtransform( coordmapping, axes_to, *dims )

      rankmp = coordmapping.rank

      #< check arguments >
      if axes_to.length != rankmp
        raise ArgumentError,
          "length of axes_to must be equal to the rank of coordmapping"
      end
      if self.rank == rankmp
        dims = (0...rankmp).collect{|i| i}
      elsif self.rank < rankmp
        raise ArgumentError,"rank of coordmapping is greater than self.rank"
      elsif dims.length != rankmp
        raise ArguemntError,
          "# of dimensions speficied is not equal to the rank of coordmapping"
      elsif dims != dims.sort
        raise ArguementErroor,"dims must be in the increasing order"
      end

      #< get grid points >
      vt = coordmapping.map_grid( *dims.collect{|d| axes_to[d].pos.val} )
      x = dims.collect{|d| self.grid.axis(d).pos.val}
      #< prepare the output object >
      axes = (0...self.rank).collect{|i| grid.axis(i)}
      dims.each_with_index{|d,j| axes[d]=axes_to[j]}
      grid_to = Grid.new( *axes )
      vnew = VArray.new( NArray.new( self.data.ntype, *grid_to.shape ),
                        self.data, self.name )

      #< do interpolation (so far only 2D is supported) >
      case dims.length
      when 2
        if !HAVE_NUMRU_SSL2

          p "interpolation without SSL2"
#         raise "Sorry, so far I need SSL2 (ruby-ssl2)"
          self.each_subary_at_dims_with_index( *dims ){ |fxy,idx|

            wgts = Array.new
            idxs = Array.new

            for d in 0..dims.length-1
              wgt = vt[d].dup.fill!(-1.0)
              idx0 = vt[d].dup.to_i.fill!(-1)
              idx1 = idx0.dup.fill!(x[d].length)

              xsort = x[d].sort
              xsortindex = x[d].sort_index
              for i in 0..x[d].length-1
                idx0[ xsort[i] <= vt[d] ] = xsortindex[i]
                idx1[ xsort[-1-i] >= vt[d] ] = xsortindex[-1-i]
              end

              # where idx0=idx1
              wgt[ idx0.eq(idx1) ] = 1.0

              # where vt[d] < x[d].min
              wgt[ idx0 <= -1 ] = 1.0
              idx0[ idx0 <= -1 ] = 0

              # where vt[d] > x[d].max
              wgt[ idx1 >= x[d].length ] = 0.0
              idx1[ idx1 >= x[d].length ] = x[d].length-1

              # normal points
              mask = wgt.eq(-1.0)
              wgt[mask] = (vt[d][mask]-x[d][idx0[mask]])/(x[d][idx1[mask]]-x[d][idx0[mask]])

              wgts.push(wgt)
              idxs[d*2] = idx0
              idxs[d*2+1] = idx1

            end

            case dims.length
#            when 1
#              f =   fxy.data.val[idxs[0]]*(1-wgts[0]) + 
#                    fxy.data.val[idxs[1]]*wgts[0]
#              f = f.to_na if( f.class.to_s == "NArrayMiss" )
            when 2
              lx = fxy.shape[0]
              f =   ( fxy.data.val[idxs[0]+idxs[2]*lx]*(1-wgts[0]) + 
                      fxy.data.val[idxs[1]+idxs[2]*lx]*wgts[0]
                    ) * (1-wgts[1]) + 
                    ( fxy.data.val[idxs[0]+idxs[3]*lx]*(1-wgts[0]) + 
                      fxy.data.val[idxs[1]+idxs[3]*lx]*wgts[0] 
                    ) * wgts[1]
              f = f.to_na if( f.class.to_s == "NArrayMiss" )
            else
              raise "Sorry, #{v.length}D interpolation is yet to be supported"
            end

            if(idx==false)
              vnew[] = f
            else
              vnew[*idx] = f
            end
          }

        else
          ix=iy=0
          m=3
          self.each_subary_at_dims_with_index( *dims ){ |fxy,idx|
            c,xt = SSL2.bicd3(x[0],x[1],fxy.val,m)
            begin
              ix,iy,f = SSL2.bifd3(x[0],x[1],m,c,xt,0,vt[0],ix,0,vt[1],iy)
            rescue
              $stderr.print "Interpolation into", vt[0].inspect, vt[1].inspect
              raise $!
            end
            vnew[*idx] = f
          }
        end
      else
        raise "Sorry, #{v.length}D interpolation is yet to be supported"
      end

      #< finish >
      GPhys.new( grid_to, vnew )
    end

  end
end

########################################

if __FILE__ == $0
  include NumRu
  include NMath

  #< make a GPhys >

  puts "** preparation **"

  nx=ny=10
  nz=3
  xv = VArray.new( xx=NArray.sfloat(nx).indgen!.mul!(4*PI/(nx-1)) ).rename("x")
  yv = VArray.new( yy=NArray.sfloat(ny).indgen!.mul!(4*PI/(ny-1)) ).rename("y")
  zv = VArray.new( NArray.sfloat(nz).indgen! ).rename("z")
  xax = Axis.new.set_pos(xv)
  yax = Axis.new.set_pos(yv)
  zax = Axis.new.set_pos(zv)
  grid = Grid.new(xax,yax,zax)
  fxy = sin(yy).newdim(0,1) + NArray.sfloat(nx).newdim(1,1) +
                              NArray.sfloat(nz).indgen!.newdim(0,0)
  p fxy.shape, fxy
  z = VArray.new( fxy )
  gp = GPhys.new( grid, z )


  #< make the new coordinate  >

  puts "** transformation **"

  theta = PI/6
  factor = NMatrix[ [cos(theta), -sin(theta)],
                    [sin(theta), cos(theta) ] ]
  offset = NVector[ 0.0, 0.0 ]
  coordmapping = LinearCoordMapping.new(offset, factor)

  axes_to = [ Axis.new.set_pos( xv[0..(nx/2)] + 1.5*PI ), 
              Axis.new.set_pos( yv[0..(ny/2)] ) ]

  gprot = gp.coordtransform( coordmapping, axes_to, 0, 1 )
  p gprot.val

end

