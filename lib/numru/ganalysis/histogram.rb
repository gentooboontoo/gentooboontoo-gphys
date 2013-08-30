require "numru/gphys"
require "numru/ggraph"
module NumRu
  module GAnalysis

    begin
      require "gsl"
      HistogramGSL = true
    rescue LoadError
      HistogramGSL = false
    end

    module_function

    def histogram(gphys0,opts=Hash.new)
      unless HistogramGSL
        raise "gsl is necessary to use this method"
      end
      unless GPhys === gphys0
        raise "gphys0 (1st arg) must be GPhys"
      end
      unless Hash === opts
        raise "opts (2nd arg) must be Hash"
      end
      if opts["bins"]
        bins = opts["bins"]
        unless (bins.is_a?(NArray) || bins.is_a?(Array))
          raise(TypeError, "option 'bins' must be Array or NArray")
        end
        bins = bins.to_gslv if bins.is_a?(NArray)
        hist = GSL::Histogram.alloc(bins)
      else
        nbins = opts["nbins"] || gphys0.total/500
        nbins = 10 if nbins < 10
        min = opts["min"] || gphys0.min.val
        max = opts["max"] || gphys0.max.val
        if log_bins = (opts["log_bins"] && (min > 0))
          min = Math.log10(min)
          max = Math.log10(max)
        end
        hist = GSL::Histogram.alloc(nbins,[min,max])
      end
      val = gphys0.val
      val = val.get_array![val.get_mask!] if NArrayMiss === val
      val = NMath.log10(val) if log_bins
      hist.increment(val)

      bounds = hist.range.to_na
      bounds = 10 ** bounds if log_bins
      center = (bounds[0..-2]+bounds[1..-1])/2
      cell_width = (bounds[1..-1] - bounds[0..-2]) / 2
      name = gphys0.name
      attr = gphys0.data.attr_copy
      bounds = VArray.new(bounds, attr, name)
      center = VArray.new(center, attr, name)
      axis = Axis.new(true)
      axis.set_cell(center, bounds, name)
      axis.set_pos_to_center

      bin = hist.bin.to_na
      bin /= cell_width if opts["log_bins"]
      bin = VArray.new(bin,
                       {"long_name" => (log_bins ? "number per unit bin width" : "number in bins"), "units"=>"1"},
                       "bin")
      new_gphys = GPhys.new(Grid.new(axis), bin)
      new_gphys.set_att("mean",[hist.mean])
      new_gphys.set_att("standard_deviation",[hist.sigma])
      return new_gphys
    end
    alias :histogram1D :histogram

    def histogram2D(gphys0, gphys1, opts=Hash.new)
      unless HistogramGSL
        raise "gsl is necessary to use this method"
      end
      unless GPhys === gphys0
        raise "gphys0 (1st arg) must be GPhys"
      end
      unless GPhys === gphys1
        raise "gphys1 (2nd arg) must be GPhys"
      end
      unless Hash === opts
        raise "opts (3nd arg) must be Hash"
      end

      nbins0 = opts["nbins0"] || gphys0.total/500
      nbins0 = 10 if nbins0 < 10
      nbins1 = opts["nbins1"] || gphys1.total/500
      nbins1 = 10 if nbins1 < 10

      min0 = opts["min0"] || gphys0.min.val
      max0 = opts["max0"] || gphys0.max.val
      min1 = opts["min1"] || gphys1.min.val
      max1 = opts["max1"] || gphys1.max.val

      hist = GSL::Histogram2d.alloc(nbins0,[min0,max0],nbins1,[min1,max1])
      val0 = gphys0.val
      val1 = gphys1.val
      mask = nil
      if NArrayMiss === val0
        mask = val0.get_mask!
        val0 = val0.get_array!
      end
      if NArrayMiss === val1
        if mask
          mask = mask & val1.get_mask!
        else
          mask = val1.get_mask!
        end
        val1 = val1.get_array!
      end
      if mask
        val0 = val0[mask]
        val1 = val1[mask]
      end
      hist.increment(val0.to_gslv, val1.to_gslv)

      bounds0 = hist.xrange.to_na
      center0 = (bounds0[0..-2]+bounds0[1..-1])/2
      name = gphys0.name
      attr = gphys0.data.attr_copy
      bounds0 = VArray.new(bounds0, attr, name)
      center0 = VArray.new(center0, attr, name)
      axis0 = Axis.new(true)
      axis0.set_cell(center0, bounds0, name)
      axis0.set_pos_to_center

      bounds1 = hist.yrange.to_na
      center1 = (bounds1[0..-2]+bounds1[1..-1])/2
      name = gphys1.name
      attr = gphys1.data.attr_copy
      bounds1 = VArray.new(bounds1, attr, name)
      center1 = VArray.new(center1, attr, name)
      axis1 = Axis.new(true)
      axis1.set_cell(center1, bounds1, name)
      axis1.set_pos_to_center

      bin = hist.bin.to_na.reshape!(nbins1,nbins0).transpose(1,0)
      bin = VArray.new(bin,
                       {"long_name"=>"number in bins", "units"=>"1"},
                       "bin")
      new_gphys = GPhys.new(Grid.new(axis0,axis1), bin)
      new_gphys.set_att("mean0",[hist.xmean])
      new_gphys.set_att("standard_deviation0",[hist.xsigma])
      new_gphys.set_att("mean1",[hist.ymean])
      new_gphys.set_att("standard_deviation1",[hist.ysigma])
      new_gphys.set_att("covariance",[hist.cov])
      return new_gphys
    end


  end

  class GPhys
    def histogram(opts=Hash.new)
      GAnalysis.histogram(self, opts)
    end
    alias :histogram1D :histogram
  end

  module GGraph
    module_function

    @@histogram_options = Misc::KeywordOptAutoHelp.new(
            ['window', [nil,nil,nil,nil], "window bounds"],
            ['title', "histogram", "window title"],
            ['exchange', false, "exchange x and y"],
            ['fill', false, "fill bars"],
            ['fill_pattern', nil, "fill pattern"]
                                                       )
    def histogram(gphys, newframe=true, options=nil)
      gropn_1_if_not_yet
      if newframe!=true && newframe!=false
        raise ArgumentError, "2nd arg (newframe) must be true of false"
      end
      unless gphys.rank == 1
        raise ArgumentError, "rank of gphys must be 1"
      end
      unless gphys.axis(0).cell?
        raise ArgumentError, "axis must be cell type"
      end
      # if window is specified via GGraph#fig or GGraph#set_fig, use it.
      opts = @@histogram_options.interpret(options)
      exchange = opts["exchange"]
      raise "Option 'window' must be an Array of length == 4" unless opts["window"].is_a?(Array) && opts["window"].length == 4
      window = opts["window"].dup
      4.times{|i| window[i] ||= @@fig['window'][i]} if @@fig['window']
      4.times{|i| window[i] ||= DCL::sgqwnd[i]} unless newframe
      unless exchange
        x = gphys.axis(0).cell_bounds
        y = gphys
        window[2] ||= 0
      else
        y = gphys.axis(0).cell_bounds
        x = gphys
        window[0] ||= 0
      end
      itr = @@fig['itr'] || DCL::sgpget("itr")
      if (itr==2 || itr==4)
        tmp = y.val
        if tmp.min * tmp.max < 0
          if tmp.min.abs < tmp.max
            mask = tmp.lt(0)
          else
            mask = tmp.gt(0)
          end
        else
          mask = tmp.ne(0)
        end
        if tmp.is_a?(NArrayMiss)
          tmp.set_mask(mask * tmp.get_mask)
        else
          tmp = NArrayMiss.to_nam_no_dup(tmp, mask)
        end
        y.replace_val(tmp)
        if(window[2].nil? || window[2] == 0)
          window[2] = tmp.abs.min * (tmp.min < 0 ? -1 : 1)
        end
      end
      if (itr==3 || itr==4)
        tmp = x.val
        if tmp.min * tmp.max < 0
          if tmp.min.abs < tmp.max
            mask = tmp.lt(0)
          else
            mask = tmp.gt(0)
          end
        else
          mask = tmp.ne(0)
        end
        if tmp.is_a?(NArrayMiss)
          tmp.set_mask(mask * tmp.get_mask)
        else
          tmp = NArrayMiss.to_nam_no_dup(tmp, mask)
        end
        x.replace_val(tmp)
        if(window[0].nil? || window[0] == 0)
          window[0] = tmp.abs.min * (tmp.min < 0 ? -1 : 1)
        end
      end
      opts["window"] = window

      fig(x, y, "window" => window) if newframe
      lmiss = DCL::gllget("lmiss")
      DCL::gllset("lmiss", true)
      if opts["fill"]
        itps = DCL::uuqarp
        itps[0] = itps[1] = opts["fill_pattern"] if opts["fill_pattern"]
        DCL::uusarp(*itps)
      end
      unless exchange
        if opts["fill"]
          DCL::uvbxa(x.val, [window[2]] * y.length, y.val)
        end
        bottom = [window[2]] * y.length
        DCL::uvbxf(x.val, bottom, y.val)
      else
        if opts["fill"]
          DCL::uhbxa([window[0]] * x.length, x.val, y.val)
        end
        bottom = [window[0]] * x.length
        DCL::uhbxf(bottom, x.val, y.val)
      end
      DCL::gllset("lmiss", lmiss)
      axes(x, y, "title" => opts["title"]) if newframe
      return nil
    end
    alias :histogram1D :histogram

  end

end



if $0 == __FILE__
  include NumRu

  npoints = 10000
  rng = GSL::Rng.alloc

  vary = VArray.new(rng.weibull(1,2,npoints).to_na,
                    {"long_name"=>"wind speed", "units"=>"m/s"},
                    "u")
  axis = Axis.new
  axis.pos = VArray.new(NArray.sint(npoints),
                        {"long_name"=>"points"},
                        "points")
  gphys1D = GPhys.new(Grid.new(axis), vary)

  npoints = 100000
  na0 = rng.weibull(1,2,npoints).to_na
  na1 = rng.gaussian(0.5,npoints).to_na
  theta = Math::PI/6
  vary0 = VArray.new(na0*Math.cos(theta)-na1*Math.sin(theta),
                    {"long_name"=>"zonal wind speed", "units"=>"m/s"},
                    "u")
  vary1 = VArray.new(na0*Math.sin(theta)+na1*Math.cos(theta),
                    {"long_name"=>"meridional wind speed", "units"=>"m/s"},
                    "v")
  axis = Axis.new
  axis.pos = VArray.new(NArray.sint(npoints),
                        {"long_name"=>"points"},
                        "points")
  gphys2D_0 = GPhys.new(Grid.new(axis), vary0)
  gphys2D_1 = GPhys.new(Grid.new(axis), vary1)

  DCL::gropn(4)

  hist = GAnalysis.histogram(gphys1D)
  GGraph.histogram(hist)

  GGraph.set_fig("itr"=>2)
  GGraph.histogram(hist)

  GGraph.set_fig("itr"=>3)
  GGraph.histogram(hist)

  GGraph.set_fig("itr"=>4)
  GGraph.histogram(hist)

  GGraph.set_fig("itr"=>1)
  GGraph.histogram(hist, true, "fill" => true, "fill_pattern" => 15999)

  GGraph.set_fig("itr"=>1)
  hist = gphys1D.histogram("nbins"=>10)
  GGraph.histogram(hist, true, "title"=>"histogram 1D")

  hist = GAnalysis.histogram(gphys1D, 'log_bins' => true)
  GGraph.histogram(hist)

  hist = GAnalysis.histogram2D(gphys2D_0, gphys2D_1, "nbins0"=>50)
  GGraph.tone(hist, true, "tonc"=>true)


  DCL::grcls
end
