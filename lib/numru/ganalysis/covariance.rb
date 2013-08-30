require "numru/gphys"

module NumRu
  module GAnalysis

    module_function

    def covariance(gphys0, gphys1, *dims)
      unless GPhys===gphys0 && GPhys===gphys1
        raise "gphys0 and gphys1 must be GPhys"
      end
      unless gphys0.shape == gphys1.shape
        raise "gphys0 and gphys1 must have the same shape"
      end
      units = gphys0.units*gphys1.units
      if dims.length == 0
        dims = Array.new
        gphys0.rank.times{|i| dims.push i }
      else
        dims = dims.map{|dim| gphys0.dim_index(dim) }
      end
      val0 = gphys0.val
      val1 = gphys1.val
      if val0.is_a?(NArrayMiss)
        if val1.is_a?(NArrayMiss)
          mask = val0.get_mask * val1.get_mask
          ndiv = mask.to_type(NArray::LINT).accum(*dims)
          val0 = val0.set_mask(mask)
          val1 = val1.set_mask(mask)
        else
          ndiv = val0.get_mask.to_type(NArray::LINT).accum(*dims)
          val1 = NArrayMiss.to_nam(val1,val0.get_mask)
        end
      elsif val1.is_a?(NArrayMiss)
        ndiv = val1.get_mask.to_type(NArray::LINT).accum(*dims)
        val0 = NArrayMiss.to_nam(val0,val1.get_mask)
      else
        ndiv = 1
        gphys0.shape.each_with_index{|s,i|
          ndiv *= s if dims.include?(i)
        }
      end
      val0 -= val0.accum(*dims).div!(ndiv)
      val1 -= val1.accum(*dims).div!(ndiv)
      nary = val0.mul_add(val1,*dims)
      if Float === nary
        ndiv = ndiv[0] if ndiv.is_a?(NArray)
        nary /= (ndiv-1)
        return UNumeric.new(nary, units), ndiv
      else
        nary.div!(ndiv-1)
        vary = VArray.new(nary,
                          {"long_name"=>"covariance","units"=>units.to_s},
                          "covariance")
        new_grid = gphys0.grid.delete_axes(dims, "covariance").copy
        return GPhys.new(new_grid,vary), ndiv
      end
    end

    def corelation(gphys0, gphys1, *dims)
      val0 = gphys0.val
      val1 = gphys1.val
      if val0.is_a?(NArrayMiss)
        mask = val0.get_mask
      else
        mask = NArray.byte(*(val0.shape)).fill!(1)
      end
      if val1.is_a?(NArrayMiss)
        mask2 = val1.get_mask
      else
        mask2 = NArray.byte(*(val1.shape)).fill!(1)
      end
      mask.mul!(mask2)
      val0 = NArrayMiss.to_nam(val0) unless val0.is_a?(NArrayMiss)
      val1 = NArrayMiss.to_nam(val1) unless val1.is_a?(NArrayMiss)
      val0 = val0.set_mask(mask)
      val1 = val1.set_mask(mask)
      p val0,val1 if $DEBUG
      gphys0 = gphys0.copy.replace_val(val0)
      gphys1 = gphys1.copy.replace_val(val1)

      covariance, ndiv = gphys0.covariance(gphys1,*dims)
      return covariance/(gphys0.stddev(*dims)*gphys1.stddev(*dims)), mask.to_type(NArray::LINT).sum(*dims)
    end
    alias correlation corelation
  end

  class GPhys
    def covariance(other, *dims)
      GAnalysis.covariance(self, other, *dims)
    end

    def corelation(other, *dims)
      GAnalysis.corelation(self, other, *dims)
    end
    alias correlation corelation
  end
end

if  $0 == __FILE__
  require "numru/ggraph"
  include NumRu

  # TEST DATA WITHOUT MISSING VALUE
  p x = NArray[1.0, 2.0, 4.0, 8.0, 9.0, 10.0]
  p y = NArray[1.0, 2.0, 4.0, 8.0, 9.0, 10.0]

  vx = VArray.new(x, {}, "x")
  vy = VArray.new(y, {}, "y")
  i  = VArray.new(NArray.int(6).indgen!, {}, "i")
  ai = Axis.new.set_pos(i)
  gi = Grid.new(ai)

  p gx = GPhys.new(gi, vx)
  p gy = GPhys.new(gi, vy)

  corr_true, n = gx.correlation(gy)
  covar_true, m = gx.covariance(gy)

  puts "Test of GPhys::correlation"
  puts "gx.correlation(gy) = #{corr_true.val}, num of samples = #{n}"

  puts "Test of GPhys::covariance"
  puts "gx.covariance(gy) = #{covar_true.val}, num of samples = #{m}"

  # TEST DATA WITH MISSING VALUE
  x = NArray[1.0, 2.0, 2.9, 4.0, 4.9, -99, -99, 8.0, 9.0, 10.0]
  y = NArray[1.0, 2.0, -99, 4.0, -99, 6.1, -99, 8.0, 9.0, 10.0]

  p x = NArrayMiss.to_nam_no_dup(x,x.gt(-99))
  p y = NArrayMiss.to_nam_no_dup(y,y.gt(-99))

  vx = VArray.new(x, {}, "x")
  vy = VArray.new(y, {}, "y")
  i  = VArray.new(NArray.int(10).indgen!, {}, "i")
  ai = Axis.new.set_pos(i)
  gi = Grid.new(ai)

  p gx = GPhys.new(gi, vx)
  p gy = GPhys.new(gi, vy)

  corr, n2 = gx.correlation(gy)
  covar, m2 = gx.covariance(gy)

  puts "Test of GPhys::correlation"
  puts "gx.correlation(gy) must be #{corr_true.val}"
  puts "gx.correlation(gy) = #{corr.val}, num of samples = #{n2}"

  puts "Test of GPhys::covariance"
  puts "gx.covariance(gy) must be #{covar_true.val}"
  puts "gx.covariance(gy) = #{covar.val}, num of smaples = #{m2}"

end

