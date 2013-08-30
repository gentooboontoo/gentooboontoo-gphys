require "numru/gphys"

module NumRu
  module GAnalysis

    begin
      require "numru/ssl2"
      @@EOF_engin = "ssl2"
    rescue LoadError
      begin
        require "numru/lapack"
        @@EOF_engin = "lapack"
      rescue LoadError
        begin
          require "rubygems"
        rescue LoadError
        end
        begin
          require "gsl"
          @@EOF_engin = "gsl"
        rescue LoadError
        end
      end
    end

    print "EOF engin is #{@@EOF_engin}\n" if $DEBUG

    module_function

    # = Calculate EOF vectors and contribution rate
    # call-seq:
    #  NumRu::GAnalysis.eof(gphys, dim0[, dim1, ..., dimN[, opts]]) => [eof, rate]
    #
    # == Arguments
    # +gphys+:: GPhys object to be calculated its EOF
    # +dim0+, ..., +dimN+:: dimension name (String) or number (Ingeter) to calculate variance or covariance, and those dimensions are not contained in the result EOF vectors.
    # +opts+:: a Hash object whose key is String or Symbol. The following options are available:
    #   * nmodes: Integer, number of EOF modes to be calculate (default all EOF modes)
    #   * weight: GPhys or NArray, weight vector
    #              +gphys+ is multiplied by the weight vector before calculation of variance covariance matrix
    #              and the result eigen vectors are divided by the vector.
    #              If weight vector is not set,
    #                 it is cosine of latitude when the first two axes of the +gphys+ are "lon" and "lat" and +disable_weight+ option is not +true+,
    #                 else 1.
    #   * disable_weight: See weight option.
    #
    # == Return values
    # +eof+:: GPhys object for array of EOF vectors.
    # +rate+:: GPhys object for array of contribution rate correspoinding to the EOF vectors.
    def eof(gphys, *args)

      unless defined?(@@EOF_engin)
        raise "SSL2 (Ruby-SSL2) or LAPACK (Ruby-LAPACK) or GSL (Ruby/GSL) must have been installed. (SSL2 or LAPACK is recommended for large computation)"
      end

      if Hash === args[-1]
        dims = args[0..-2]
        opts = args[-1]
      else
        dims = args
        opts = Hash.new
      end
      dims = dims.map{|dim| gphys.dim_index(dim) }
      n = 1
      n_lost = 1
      dims1 = Array.new
      shape1 = Array.new
      gphys.shape.each_with_index{|s,i|
        if dims.include?(i)
          n_lost *= s
        else
          n *= s
          dims1.push i
          shape1.push s
        end
      }
      new_grid = gphys.instance_variable_get("@grid").delete_axes(dims, "covariance matrix").copy
      new_index = NArray.sint(*new_grid.shape).indgen
      index = NArray.object(gphys.rank)
      index[dims] = true

      if w = (opts[:weight] || opts["weight"])
        if GPhys === w
          w = w.val
        end
        unless NArray === w
          raise "weight must be NArray of GPhys"
        end
        unless w.shape == new_grid.shape
          raise "shape of weight is invalid"
        end
        w /= w.mean
        w.reshape!(n)
      else
        if !(opts[:disable_weight]||opts["disable_weight"]) && /^lon/ =~ new_grid.coord(0).name && /^lat/ =~ new_grid.coord(1).name
          rad = NumRu::Units.new("radian")
          nlon = new_grid.coord(0).length
          lat = new_grid.coord(1).convert_units(rad).val
          w = NArray.new(lat.typecode,nlon).fill!(1) * NMath::cos(lat).reshape(1,lat.length)
          w /= w.mean
          w.reshape!(n)
        else
          w = nil
        end
      end

      ary = NArrayMiss.new(gphys.typecode, n_lost, n)
      ind_rank = dims1.length
      ind = Array.new(ind_rank,0)
      n.times{|n1|
        index[dims1] = ind
        val = gphys[*index].val
        val.reshape!(n_lost)
        val -= val.mean
        ary[true,n1] = val
        break if n1==n-1
        ind[0] += 1
        ind_rank.times{|i|
          if ind[i] == shape1[i]
            ind[i] = 0
            ind[i+1] += 1
          else
            break
          end
        }
      }
      ary.mul!(w.reshape(1,n)) if w


      nmodes = opts[:nmodes] || opts["nmodes"] || n
      case @@EOF_engin
      when "ssl2"
        print "start calc covariance matrix\n" if $DEBUG
        nary = NArray.new(gphys.typecode,n*(n+1)/2)
        nn = 0
        total_var = 0
        n.times{|n0|
          for n1 in n0...n
            nary[nn] = ary[n0].mul_add(ary[n1],0)/(n_lost-1)
            if n1==n0
              total_var += nary[nn]
            end
            nn += 1
          end
        }
        ary = nil # for GC
        print "start calc eigen vector\n" if $DEBUG
        val, vec = SSL2.seig2(nary,nmodes)
      when "lapack"
        print "start calc covariance matrix\n" if $DEBUG
        nary = NArray.new(gphys.typecode,n,n)
        total_var = 0.0
        n.times{|n0|
          nary[n0...n,n0] = (ary[true,n0...n].mul_add(ary[true,n0],0)/(n_lost-1)).get_array!
          total_var += nary[n0,n0]
        }
        ary = nil # for GC
        print "start calc eigen vector\n" if $DEBUG
        case nary.typecode
        when NArray::DFLOAT
	  m, val, vec, isuppz, work, iwork, info, = NumRu::Lapack.dsyevr("V", "I", "L", nary, 0, 0, n-nmodes+1, n, 0.0, -1, -1)
	  m, val, vec, = NumRu::Lapack.dsyevr("V", "I", "L", nary, 0, 0, n-nmodes+1, n, 0.0, work[0], iwork[0])
        when NArray::SFLOAT
	  m, val, vec, isuppz, work, iwork, info, = NumRu::Lapack.ssyevr("V", "I", "L", nary, 0, 0, n-nmodes+1, n, 0.0, -1, -1)
	  m, val, vec, = NumRu::Lapack.ssyevr("V", "I", "L", nary, 0, 0, n-nmodes+1, n, 0.0, work[0], iwork[0])
        end
        val = val[-1..0]
        vec = vec[true,-1..0]
      when "gsl"
        print "start calc covariance matrix\n" if $DEBUG
        nary = NArray.new(gphys.typecode,n,n)
        n.times{|n0|
          nary[n0...n,n0] = (ary[true,n0...n].mul_add(ary[true,n0],0)/(n_lost-1)).get_array!
          nary[n0,n0...n] = nary[n0...n,n0]
        }
        ary = nil # for GC
        print "start calc eigen vector\n" if $DEBUG
        val, vec = GSL::Eigen::symmv(nary.to_gm)
        GSL::Eigen.symmv_sort(val, vec, GSL::Eigen::SORT_VAL_DESC)
        vec = vec.to_na[0...nmodes,true].transpose(1,0)
        val = val.to_na
        total_var = val.sum
        val = val[0...nmodes]
      end

      axes = new_grid.instance_variable_get('@axes')
      axis_order = Axis.new
      axis_order.pos = VArray.new(NArray.sint(nmodes).indgen(1),
                                  {}, "mode")
      axes << axis_order
      new_grid = Grid.new(*axes)
      vec /= w if w
      vec.reshape!(*new_grid.shape)
      vec *= NMath::sqrt( val.reshape( *([1]*(axes.length-1)+[nmodes]) ) )
      va_eof = VArray.new(vec,
                          {"long_name"=>"EOF vector","units"=>gphys.units.to_s },
                          "EOF")
      eof = GPhys.new(new_grid, va_eof)

      va_rate = VArray.new(val.div!(total_var),
                           {"long_name"=>"EOF contribution rate", "units"=>"1" },
                           "rate")
      rate = GPhys.new(Grid.new(axis_order), va_rate)

      return [eof, rate]
    end

    def eof2(gphys1, gphys2, *args)
      if Hash === args[-1]
        opts = args[-1]
      else
        opts = Hash.new
      end
      raise ArgumentError, "The 1st arg must be a GPhys of rank 1: arg1 = #{gphys1.inspect}" unless gphys1.rank==1
      raise ArgumentError, "The 2nd arg must be a GPhys of rank 1: arg2 = #{gphys2.inspect}" unless gphys2.rank==1
      raise ArgumentError, "The 1st and 2nd args must have the same length: #{gphys1.length}!=#{gphys2.length}" unless gphys2.rank==1
      nam = NArrayMiss.new(gphys1.typecode, 2, gphys1.length)
      nam[0,true] = gphys1.val
      nam[1,true] = gphys2.val
      gphys = GPhys.new(Grid.new(Axis.new.set_pos(VArray.new(NArray[0,1],{},"var")),
                                 gphys1.axis(0)),
                        VArray.new(nam,gphys1.data.attr_copy,gphys1.name))
      eof(gphys, 1, opts)
    end
  end

  class GPhys
    def eof(*args)
      GAnalysis.eof(self, *args)
    end
  end

end


#:enddoc

if  $0 == __FILE__
  require "numru/ggraph"
  include NumRu
  N = 10000
  x = NArray.float(N).randomn!*2
  y = NArray.float(N).randomn!*1
  ary = NArray.float(2,N)
  theta = Math::PI/6
  ary[0,true] = x*Math::cos(theta)-y*Math::sin(theta)
  ary[1,true] = x*Math::sin(theta)+y*Math::cos(theta)
  vary = VArray.new(ary, { }, "test")
  axis0 = Axis.new
  axis0.pos = VArray.new(NArray[0,1], {}, "dimensions")
  axis1 = Axis.new
  axis1.pos = VArray.new(NArray.sint(N).indgen, {}, "t")
  gphys = GPhys.new(Grid.new(axis0,axis1), vary)

  eof,rate = gphys.eof("t")

  max = 5
  DCL::gropn(4)
  DCL::grfrm
  DCL::grsvpt(0.1,0.9,0.1,0.9)
  DCL::grswnd(-max,max,-max,max)
  DCL::grstrn(1)
  DCL::grstrf

  DCL::sgpmzu(ary[0,true],ary[1,true],1,1,0.01)

  eof1 = eof[true,0].val
  eof2 = eof[true,1].val
  DCL::sgplzu([eof1[0],-eof1[0]],[eof1[1],-eof1[1]], 1, 23)
  DCL::sgplzu([eof2[0],-eof2[0]],[eof2[1],-eof2[1]], 1, 43)

  DCL::usdaxs
  DCL::uxsttl("T","test of GAnalysis::eof",0)

  # TEST OF GAnalysis::eof2

  vary1 = VArray.new(ary[0,true], { }, "test")
  gphys1 = GPhys.new(Grid.new(axis1), vary1)
  vary2 = VArray.new(ary[1,true], { }, "test")
  gphys2 = GPhys.new(Grid.new(axis1), vary2)

  eof,rate = GAnalysis.eof2(gphys1,gphys2)

  max = 5
  DCL::grfrm
  DCL::grsvpt(0.1,0.9,0.1,0.9)
  DCL::grswnd(-max,max,-max,max)
  DCL::grstrn(1)
  DCL::grstrf

  DCL::sgpmzu(ary[0,true],ary[1,true],1,1,0.01)

  eof1 = eof[true,0].val
  eof2 = eof[true,1].val
  DCL::sgplzu([eof1[0],-eof1[0]],[eof1[1],-eof1[1]], 1, 23)
  DCL::sgplzu([eof2[0],-eof2[0]],[eof2[1],-eof2[1]], 1, 43)

  DCL::usdaxs
  DCL::uxsttl("T","test of GAnalysis::eof2",0)

  DCL::grcls
end
