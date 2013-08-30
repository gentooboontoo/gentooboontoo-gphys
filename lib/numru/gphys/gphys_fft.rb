=begin
=extension of class NumRu::GPhys -- Fast Fourier transformation and its applications

This manual documents the methods of NumRu::GPhys defined in gphys_fft.rb

=class methods
---GPhys::fft_ignore_missing( ignore=true, replace_val=nil )
    Set a flag (class variable) to ignore missing values. 
    This is for data that do not have missing 
    but is treated as potentially having missing (often
    by having the valid_* attributes of NetCDF.)
    If replace_val is specified, data missing with replaced
    with that value.


=methods
---fft(backward=false, *dims)
    Fast Fourier Transformation (FFT) by using  
    (((<FFTW|URL:http://www.fftw.org>))) ver 3 or ver 2.
    A FFTW ver.2 interface is included in NArray, while
    to use FFTW ver.3, you have to install separately.
    Dimension specification by the argument dims is available
    only with ver.3. By default, FFT is applied to all dimensions.

    The transformation is complex. If the input data is not complex,
    it will be coerced to complex before transformation.

    When the FT is forward, the result is normalized 
    (i.e., divided by the data number), unlike the default behavior of
    FFTW.
    
    Each coordinate is assumed to be equally spaced without checking.
    The new coordinate variables will be set equal to wavenumbers,
    derived as 2*PI/(length of the axis)*[0,1,2,..], where the length
    of the axis is derived as (coord.val.max - coord.val.min)*(n+1)/n.

    REMARK
    * If the units of the original coordinate is degree (or its
      equivalent ones such as degrees_east), the wavenumber was
      made in integers by converting the coordinate based on 
      radian.

    ARGUMENTS
    * backward (true of false) : when true, backward FT is done;
      otherwise forward FT is done.
    * dims (integers) : dimensions to apply FFT

    RETURN VALUE
    * a GPhys

    EXAMPLE
      gphy.fft           # forward, for all dimensions
      gphy.fft(true)     # backward, for all dimensions
      gphy.fft(nil, 0,1) # forward, for the first and second dimensions.
      gphy.fft(true, -1) # backward, for the last dimension.


---detrend(dim1[,dim2[,...]])
    Remove means and linear trends along dimension(s) specified.
    Algorithm: 1st order polynomial fitting.

    ARGUMENTS
    * dim? (Integer of String): the dimension along which you want to remove
      trends.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * See ((<detrend>)).

---cos_taper(dim1[,dim2[,...]])
    Cosine tapering along dimension(s) specified.

    Algorithm: to multiply with the half cosine curves at the both 
    1/10 ends of the data.

         cos taper shape:
                  _____________
                _/             \_
              ->   <-       ->   <-
               T/10           T/10
            half-cosine     half-cosine
              shaped         shaped

    The spectra of tapered data should be multiplied by 1/0.875,
    which is stored as GPhys::COS_TAPER_SP_FACTOR (==1/0.875).

    ARGUMENTS
    * dim? (Integer of String): the dimension along which you want to remove
      trends.

    RETURN VALUE
    * a GPhys

    EXAMPLE
       dim = 0    # for the 1st dimension
       fc = gphys.detrend(dim).cos_taper(dim).fft(nil,dim)
       sp = fc.abs**2 * GPhys::COS_TAPER_SP_FACTOR

---spect_zero_centering(dim)
    Shifts the wavenumber axis to cover from -K/2 to K/2 instead of 
    from 0 to K-1, where the wavenumber is symbolically treated as integer,
    which is actually not the case, though. Since the first (-K/2) and
    the last (K/2) elements are duplicated, both are divided by 2.
    Therefore, this method is to be used for spectra (squared quantity)
    rather than the raw Fourier coefficients. (That is why the method name
    is prefixed by "spect_").

    The method is applied for a single dimension (specified by the argument
    dim). If you need to apply for multiple dimensions, use it for multiple
    times.

    ARGUMENTS
    * dim (integer): the dimension you want to shift spectra elements.
      Count starts from zero.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * To get a spectra of a variable var along the 1st and 2nd dimensions:

        fc = var.fft(nil, 0,1)    # --> Fourier coef
        sp = ( fc.abs**2 ).spect_zero_centering(0).spect_zero_centering(1)

      Note that spect_zero_centering is applied after taking |fc|^2.

    * Same but if you want to have the 2nd dimension one-sided:

        fc = var.fft(nil, 0,1)
        sp = ( fc.abs**2 ).spect_zero_centering(0).spect_one_sided(1)

    * Similar to the first example but for cross spectra:

        fc1 = var1.fft(nil, 0,1)
        fc2 = var2.fft(nil, 0,1)
        xsp = (fc1 * fc2.conj).spect_zero_centering(0).spect_zero_centering(1)

---spect_one_sided(dim)
    Similar to ((<spect_zero_centering>)) but to make one-sided spectra.
    Namely, to convert from 0..K-1 to 0..K/2. To be applied for spectra;
    wavenumber 2..K/2-1 are multiplied by 2.

    ARGUMENTS
    * dim (integer): the dimension you want to shift spectra elements.
      Count starts from zero.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * See the 2nd example of ((<spect_zero_centering>)).

---rawspect2powerspect(*dims)
    Converts raw spectra obtained by gphys.fft.abs**2 into
    power spectra by dividing by wavenumber increments
    along the dimensions specified by dims.

    ARGUMENTS
    * dims (integers): the dimensions corresponding to wavenumbers.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * Suppose a 2 (or more) dimensional data gphys.

        fc = gphys.fft(nil, 0, 1)
        sp = fc.abs**2
        ps = sp.rawspect2powerspect(0,1)

      Here, sp is the raw spectrum of gphys, and ps is the power spectrum.
      The Parseval relation for them are as follows:

        (gphys**2).mean == sp.sum
                        == pw.sum*dk*dl (== \int pw dk dl, mathematically),

      where, dk = (pw.coord(0)[1] - pw.coord(0)[0]), and
      dl = (pw.coord(1)[1] - pw.coord(1)[0]).

---phase_velocity_filter(xdim, tdim, cmin=nil, cmax=nil, xconv=nil, tconv=nil, remove_xtmean=false)

    Filtering by phase velocity (between cmin and cmax)

    REMARKS
    * If the number of the grid points along x or t is an even number,
      the maximum wavenumber or frequency is treated as positive 
      and negative, respectively, which results in an asymmetry of 
      the treatment of positive and negative phase speeds.
      (That should be ok. -- In case its effect is significant, 
      to do the filtering itself is not meaningful.)

    ARGUMENTS
    * xdim (Integer or String): spacial dimension
    * tdim (Integer or String): time dimension
    * cmin (Float or nil): minimum phase velocity. nil means no specification. 
      (at least cmin or cmax must be given by Float)
    * cmax (Float or nil): maximum phase velocity. nil means no specification. 
      (at least cmin or cmax must be given by Float)
    * xconv (nil or UNumeric) : (optional) if given, xconv is multiplied
      with the x axis before computing the phase velocity
      (kconv=1/xconv is used to scale wavenumbers)
    * tconv (nil or UNumeric) : (optional) if given, tconv is multiplied
      with the t axis before computing the phase velocity
      (fconv=1/tconv is used to scale frequency)
    * remove_xtmean (false or true) : if false (default), 
      components with k=0 and f=0 are counted as c=0 (stationary),
      (unlike ((<phase_velocity_binning>))), so they are included if
      cmin*cmax <= 0; if true, k=0 & f=0 components are always removed.

    RETURN VALUE
    * a GPhys

    EXAMPLE
    * For a 4D data with [x,y,z,t] dimensions, filtering by the phase
      velocity in the y dimension greater than 10.0 (in the unit
      of y/t) can be made by

         cmin = 10.0; cmax = nil
         gpfilt = gp.phase_velocity_filter(1, 3, cmin, cmax)

    * For a global data (on the Earth's surface) with 
      [lon, lat, z, time] axes, where the units of lon is 
      "degrees" (or "degrees_east" or "radian")
      and the units of time is "hours", to filter disturbances
      whose zonal phase speed MEASURED AT THE EQUATOR is less or
      equal to 30 m/s can be made by

         cmin = -30.0; cmax = 30.0
         xconv = UNumeric[6.37e6, "m"]  # Earth's radius (i.e., m/radian)
            # This is a special case since "radian" is exceptionally omitted.
            # See the private method __predefined_coord_units_conversion.
         tconv = UNumeric[3.6e3, "s/hours"]
         gpfilt = gp.phase_velocity_filter(1, 3, cmin, cmax, xconv, tconv)


---phase_velocity_binning_iso_norml(kdim, fdim, cmin, cmax, cint, kconv=nil, fconv=nil)

    Same as ((<phase_velocity_binning>)) but exclusively for
    equal phase velocity spacing. Also, a normalization is
    additionally made, to scale spectra in terms of integration
    along phase velocity axis --- The result of
    ((<phase_velocity_binning>)) called inside
    this method is divided by cint along with corresponding
    units conversion. Therefore, if this method is applied
    to spectra, a normalization is made such that an integration
    (not summation) along the phase velocity gives the variance
    (or covariance etc.) -- This normalization is suitable to
    quadratic quantities (such as spectra) but is not suitable to
    raw Fourier coefficients.

    ARGUMENTS
    * kdim (Integer or String): see ((<phase_velocity_binning>))
    * fdim (Integer or String): see ((<phase_velocity_binning>))
    * cmin (Float) : minimum phase velocity
    * cmin (Float) : maximum phase velocity
    * cint (Float) : inter val with which the range [cmin and cmax]
      is divided.
    * kconv (nil or UNumeric) : see ((<phase_velocity_binning>))
    * fconv (nil or UNumeric) : see ((<phase_velocity_binning>))

    RETURN VALUE
    * a GPhys

---phase_velocity_binning(kdim, fdim, cbins, kconv=nil, fconv=nil)

    Bin a 2D spectrum in space and time based on phase velocity.
    The operand (self) must be Fourier coefficients or spectra,
    whose grid has not been altered since the call of the method
    fft (i.e., those that have not applied with zero centering
    etc, since it is done in this method).

    Binning by this method is based on summation, leaving
    the units unchanged.

    REMARKS
    * Components whose phase velocities are exactly equal to one 
      of the boundaries are divided into the two bins half by half
    * components with k=0 and f=0 are excluded -- the spatio-temporal
      mean do not reflect in the result 

    ARGUMENTS
    * kdim (Integer or String): wavenumber dimension (from spacial dimension)
    * fdim (Integer or String): frequency dimension (from time dimension)
    * cbins : an Array of bin bounds or a Hash of max, min, int
      e.g., [-10,-1,-0.1,0.1,11,10], {"min"=>-30,"max"=>30,"int"=>5}
    * kconv (nil or UNumeric) : (optional) if given, kconv is multiplied
      with the wavenumber axis before computing the phase velocity
    * fconv (nil or UNumeric) : (optional) if given, fconv is multiplied
      with the frequency axis before computing the phase velocity

    RETURN VALUE
    * a GPhys

    EXAMPLES
    * Example A
       fu = u.fft(nil, 0, 2)
       cfu = fu.phase_velocity_binning(0, 2, {"min"=>-1,"max"=>1,"int"=>0.1})

    * Example B
       fu = u.fft(nil, 0, 2)
       pw = fu.abs**2rawspect2powerspect(0,2)          # power spectrum
       cbins = [-100.0, -10.0, -1.0, 1.0, 10.0, 100.0] # logarithmic spacing
       cpw = pw.phase_velocity_binning(0, 2, cbins)

    * Example C
       fu = u.fft(nil, 0, 3)
       fv = v.fft(nil, 0, 3)
       kconv = UNumeric[1/6.37e6, "m-1"]
       fconv = UNumeric[1/3.6e3, "hours/s"]
       fuv = (fu * fv.conj)   # cross spectra
       cfuv = fuv.phase_velocity_binning(0, 3, {"min"=>-50,"max"=>50,"int"=>5},
                                         kconv, fconv)

=end

begin
  require "numru/fftw3"
rescue LoadError
end
require "numru/gphys/gphys"

module NumRu
  class GPhys
    @@fft_forward = -1
    @@fft_backward = 1
    @@fft_ignore_missing = false
    @@fft_missing_replace_val = nil

    def self.fft_ignore_missing( ignore=true, replace_val=nil )
      @@fft_ignore_missing = ignore 
      @@fft_missing_replace_val = replace_val
    end


    COS_TAPER_SP_FACTOR = 1.0 / 0.875  # Spectral factor for the cosine taper.
                                       # Specta should be multiplied by this.
    def cos_taper(*dims)
      if dims.length < 1
	raise ArgumentError,'You have to specify one or more dimensions'
      end
      dims.sort!.uniq!
      val = self.data.val
      dims.each{|dim|
	dim = dim_index(dim) if dim.is_a?(String)
	dim += rank if dim < 0
	raise ArgumentError,"dim #{dim} does not exist" if dim<0 || dim>rank
        nx = shape[dim]
	wgt = NArray.float(nx).fill!(1)
        x = 10.0 / nx * (NArray.float(nx).indgen!+0.5) 
	wskl = x.lt(1).where
	wskr = x.gt(9).where
	wgt[wskl] = 0.5*( 1.0 - NMath::cos(Math::PI*x[wskl]) )
	wgt[wskr] = 0.5*( 1.0 - NMath::cos(Math::PI*x[wskr]) )
	wgt.reshape!( *([1]*dim + [nx] + [1]*(rank-dim-1)) )
	val = val*wgt
      }
      to_ret = self.copy
      to_ret.data.val = val
      to_ret
    end

    def detrend(*dims)
      if dims.length < 1
	raise ArgumentError,'You have to specify one or more dimensions'
      end
      dims.sort!.uniq!
      val = self.data.val
      dims.each{|dim|
	dim = dim_index(dim) if dim.is_a?(String)
	dim += rank if dim < 0
	raise ArgumentError,"dim #{dim} does not exist" if dim<0 || dim>rank
	if val.is_a?(NArray)
	  x = self.coord(dim).val
	  x.reshape!( *([1]*dim + [x.length] + [1]*(rank-dim-1)) )
	  vmean = val.mean(dim)
	  vxmean = (val*x).mean(dim)
	  xmean = x.mean(dim)
	  x2mean = (x*x).mean(dim)
	  denom = x2mean-xmean**2
	  if denom != 0
	    a = (vxmean - vmean*xmean)/denom
	    b = (vmean*x2mean - vxmean*xmean)/denom
	  else
	    a = 0
	    b = vmean
	  end
	elsif val.is_a?(NArrayMiss)
	  x = self.coord(dim).val
	  x.reshape!( *([1]*dim + [x.length] + [1]*(rank-dim-1)) )
	  x = NArrayMiss.to_nam( NArray.new(x.typecode, *val.shape) + x,
				 val.get_mask ) 
	  vmean = val.mean(dim)
	  vxmean = (val*x).mean(dim)
	  xmean = x.mean(dim)
	  x2mean = (x*x).mean(dim)
	  denom = x2mean-xmean**2
	  meq0 = denom.eq(0).to_na(0)    # ==0 and not masked
	  mne0 = denom.ne(0).to_na(0)    # !=0 and not masked
          denom.set_mask(mne0)    # only nonzero part will be used to divide:
	  a = (vxmean - vmean*xmean)/denom
	  b = (vmean*x2mean - vxmean*xmean)/denom
	  a[meq0] = 0
	  b[meq0] = vmean[meq0]
	end
	a.newdim!(dim) if !a.is_a?(Numeric)
	b.newdim!(dim) if !b.is_a?(Numeric)
	val = val - a*x-b
      }
      to_ret = self.copy
      to_ret.data.val = val
      to_ret
    end

    def fft(backward=false, *dims)
      fftw3 = false
      if defined?(FFTW3)
	fftw3 = true
      elsif !defined?(FFTW)
	raise "Both FFTW3 and FFTW are not installed."
      end
      if backward==true
	dir = @@fft_backward
      elsif !backward
	dir = @@fft_forward
      else
	raise ArgumentError,"1st arg must be true or false (or, equivalenty, nil)"
      end

      # <FFT>

      gfc = self.copy  # make a deep clone
      if fftw3
	val = gfc.data.val
	if @@fft_ignore_missing and val.is_a?(NArrayMiss)
	  if @@fft_missing_replace_val
	    val = val.to_na(@@fft_missing_replace_val)
	  else
	    val = val.to_na 
	  end
        elsif val.is_a?(NArrayMiss) && val.count_invalid == 0
          val = val.to_na 
	end
	fcoef = FFTW3.fft( val, dir, *dims )
      else
	# --> always FFT for all dimensions
	if dims.length == 0
	  raise ArgumentError,
	    "dimension specification is available only if FFTW3 is installed"
	end
	val = gfc.data.val
	if @@fft_ignore_missing and val.is_a?(NArrayMiss)
	  if @@fft_missing_replace_val
	    val = val.to_na(@@fft_missing_replace_val)
	  else
	    val = val.to_na 
	  end
        elsif val.is_a?(NArrayMiss) && val.count_invalid == 0
          val = val.to_na 
	end
	fcoef = FFTW.fftw( val, dir )
      end
      if dir == @@fft_forward
	if dims.length == 0
	  fcoef = fcoef / fcoef.length       # normalized if forward FT
	else
	  sh = fcoef.shape
	  len = 1
	  dims.each{|d|
	    raise ArgumentError, "dimension out of range" if sh[d] == nil
	    len *= sh[d]
          }
	  fcoef = fcoef / len
        end
      end
      gfc.data.replace_val( fcoef )

      # <coordinate variables>
      for i in 0...gfc.rank
	if dims.length == 0 || dims.include?(i) || dims.include?(i+rank)
	  __predefined_coord_units_conversion(gfc.coord(i))
	  cv = gfc.coord(i).val
	  n = cv.length
	  clen = (cv.max - cv.min) * n / (n-1)
	  wn = (2*Math::PI/clen) * NArray.new(cv.typecode,cv.length).indgen!
	  if (!backward)
	    gfc.coord(i).set_att('origin_in_real_space',cv[0..0])
	  else 
	    if ( org = gfc.coord(i).get_att('origin_in_real_space') )
	      wn += org[0]
	      ###gfc.coord(i).del_att('origin_in_real_space')
	    end
	  end
	  gfc.coord(i).replace_val(wn)
	  gfc.coord(i).units = gfc.coord(i).units**(-1)
	  __coord_name_conversion(gfc.coord(i), backward)
	end
      end

      # <fini>
      gfc
    end

    def __predefined_coord_units_conversion(coord)
      case coord.units
      when Units["degree"]
	val = coord.val
	coord.replace_val( val * (Math::PI/180) )
	coord.units = "radian"
      end
    end
    private :__predefined_coord_units_conversion

    def __coord_name_conversion(coord, backward)

      if !backward   #--> forward

	( ln = coord.get_att('long_name') ) &&
	  coord.set_att('long_name','wavenumber - '+ln) 

	case coord.name
	when 'x'
	  coord.name = 'k'
	when 'y'
	  coord.name = 'l'
	when 'z'
	  coord.name = 'm'
	  # when 'lon','longitude'
	  #  coord.name = 's'
	when 't','time'
	  if coord.units === Units['s-1']   # compatible_with?
	    coord.name = 'omega'
	    coord.set_att('long_name', 'angular frequency')
	  end
	end

      else  #--> backward

	if ( ln = coord.get_att('long_name') )
	  case ln
	  when /^wavenumber -/
	    coord.set_att( 'long_name', ln.sub(/^wavenumber - */,'') ) 
	  when /angular frequency/
	    coord.set_att( 'long_name', 'time' ) 
	  end
	end

	case coord.name
	when 'k'
	  coord.name = 'x'
	when 'l'
	  coord.name = 'y'
	when 'm'
	  coord.name = 'z'
	when 'omega'
	  coord.name = 'time'
	end
      end
    end
    private :__coord_name_conversion

    def spect_zero_centering(dim)
      dim = dim + self.rank if dim<0
      len = self.shape[dim]
      b = self[ *( [true]*dim + [[(len+1)/2..len-1,0..len/2],false] ) ].copy
      s1 = [true]*dim + [0, false]
      s2 = [true]*dim + [-1, false]
      if (len % 2) == 0   #--> even number
        b[*s1] = b[*s1]/2      # the ends are duplicated --> halved
        b[*s2] = b[*s1]
      end
      b.coord(dim)[0..len/2-1] = -b.coord(dim)[len/2+1..-1].val[-1..0]
      b
    end

    def spect_one_sided(dim)
      dim = dim + self.rank if dim<0
      len = self.shape[dim]
      b = self[ *([true]*dim + [0..len/2,false]) ] * 2
      b[*([true]*dim + [0,false])] = b[*([true]*dim + [0,false])] / 2
      if (self.shape[dim] % 2) == 0  # --> even number
        b[*([true]*dim + [-1,false])] = b[*([true]*dim + [-1,false])] / 2
      end
      b
    end

    def rawspect2powerspect(*dims)
      # developpers memo: Needs Units conversion.
      factor = nil
      dims.each{|dim|
	ax = self.coord(dim)
	dwn = UNumeric.new( ((ax[-1].val - ax[0].val)/(ax.length - 1)).abs,
			    ax.units )
        if !factor
	  factor = dwn**(-1)
	else
	  factor = factor / dwn
	end
      }
      self * factor
    end

    def phase_velocity_filter(xdim, tdim, cmin=nil, cmax=nil, xconv=nil, tconv=nil, remove_xtmean=false)
      raise(ArgumentError,"need at least cmin or cmax") if !(cmin || cmax)


      xdim = dim_index(xdim) if xdim.is_a?(String)
      xdim += rank if xdim < 0
      tdim = dim_index(tdim) if tdim.is_a?(String)
      tdim += rank if tdim < 0
      fc = self.fft(nil,xdim,tdim)
      
      kdim = xdim
      fdim = tdim
      kconv = ( xconv ? 1.0/xconv : nil )
      fconv = ( tconv ? 1.0/tconv : nil )
      cp, = fc.phase_velocity(kdim,fdim,kconv,fconv,!remove_xtmean,true)

      fcv = fc.val
      nk = fc.shape[kdim]
      nf = fc.shape[fdim]
      sel = [true]*fc.rank
      for jf in 0...nf
        for jk in 0...nk
          c = cp[jk,jf]
          if ( cmin && c<cmin or cmax && c>cmax)
            sel[kdim]=jk
            sel[fdim]=jf
            fcv[*sel] = 0.0
          end
        end
      end
      fc.replace_val(fcv)
      gp = fc.fft(true,xdim,tdim)
      gp = gp.real if (self.typecode <= NArray::FLOAT)
      GPhys.new(self.grid_copy, gp.data)
                #^ use the original grid, since units may have changed
    end

    def phase_velocity_binning_iso_norml(kdim, fdim, cmin, cmax, cint, 
                                   kconv=nil, fconv=nil)
      cbins = {"min"=>cmin,"max"=>cmax,"int"=>cint}
      pwc = phase_velocity_binning(kdim, fdim, cbins, kconv, fconv)
      fact = UNumeric[int, pwc.coord(0).units]
      pwc/fact
    end

    def phase_velocity_binning(kdim, fdim, cbins, kconv=nil, fconv=nil)

      # < process arguments >

      case cbins
      when Hash 
        min = cbins["min"] ||raise(ArgumentError,"a Hash cbins must have 'min'")
        max = cbins["max"] ||raise(ArgumentError,"a Hash cbins must have 'max'")
        int = cbins["int"] ||raise(ArgumentError,"a Hash cbins must have 'int'")
        cbins = Array.new
        eps = int.abs*1e-6   # epsilon to deal with float steps
        (min.to_f..(max.to_f+eps)).step(int){|c| cbins.push(c)}
        cbins = NArray.to_na(cbins)
      when Array
        cbins = NArray.to_na(cbins)
      when NArray
      else
        raise ArgumentError, "cbins must be a Hash or Array or NArray"
      end

      kdim = dim_index(kdim) if kdim.is_a?(String)
      kdim += rank if kdim < 0
      fdim = dim_index(fdim) if fdim.is_a?(String)
      fdim += rank if fdim < 0

      # < sort along wavenumber/freuqency axis >

      pw = self.spect_zero_centering(kdim).spect_one_sided(fdim)

      # < process axes >

      cp, cunits = pw.phase_velocity(kdim,fdim,kconv,fconv,false)

      vcbins = VArray.new(cbins, {"units"=>cunits.to_s, 
                    "long_name"=>"phase velocity bounds"}, "cbounds")
      vccent = VArray.new( (cbins[0..-2] + cbins[1..-1])/2, 
                    {"units"=>cunits.to_s, "long_name"=>"phase velocity"}, "c")
      axc = Axis.new(true).set_cell(vccent, vcbins).set_pos_to_center
      axes = [axc]   # the first dimension will be "c"
      gr = pw.grid
      (0...pw.rank).each do |d|
        if d!=kdim && d!=fdim
          axes.push(gr.axis(d))
        end
      end
      newgrid = Grid.new(*axes)

      nk = pw.shape[kdim]
      nf = pw.shape[fdim]
      cp.reshape!(nk*nf)

      # < reorder input data >

      dimorder = (0...pw.rank).collect{|i| i}
      dimorder.delete(fdim)
      dimorder.unshift(fdim)
      dimorder.delete(kdim)
      dimorder.unshift(kdim)   # --> [kdim, fdim, the other dims...]
      sh = pw.shape
      reshape = [nk*nf]
      (0...rank).each{|i| reshape.push(sh[i]) if i!=fdim && i!=kdim}
      pwv = pw.val.transpose(*dimorder).reshape(*reshape)  
                               # --> [ combined k&fdim, the other dims...]

      # < binning >

      shc = newgrid.shape
      pwc = NArray.new(pwv.typecode, *shc)    # will have no missing data
      nc = axc.length
      for jc in 0...nc
        w = (cp.gt(cbins[jc]) & cp.lt(cbins[jc+1])).where
        pwc[jc,false] += pwv[w,false].sum(0) if w.length>0
        w = (cp.eq(cbins[jc])).where
        pwc[jc,false] += pwv[w,false].sum(0)/2 if w.length>0  # half from bdry
        w = (cp.eq(cbins[jc+1])).where
        pwc[jc,false] += pwv[w,false].sum(0)/2 if w.length>0  # half from bdry
      end

      vpwc = VArray.new(pwc,pw.data,pw.name)
      gpwc = GPhys.new(newgrid,vpwc)

      gpwc
    end

    def phase_velocity(kdim,fdim,kconv,fconv,kf0_is_c0=true,no_kfreorder=false)
      kax = self.axis(kdim)
      fax = self.axis(fdim)
      kax.pos = kax.pos*kconv if kconv
      fax.pos = fax.pos*fconv if fconv
      cunits = fax.pos.units / kax.pos.units

      f = fax.pos.val
      k = kax.pos.val
      nk = k.length
      nf = f.length
      if no_kfreorder
        k[nk/2+1..-1] = -k[nk/2+1..-1][-1..0]+k[nk/2]
        f[nf/2+1..-1] = -f[nf/2+1..-1][-1..0]+f[nf/2]
      end
      f = -f
      cp = f.newdim(0) / k.newdim(1) #cp[kdim,fdim]
      jf0 = f.eq(0).where[0]  # where f==0
      jk0 = k.eq(0).where[0]  # where k==0
      if kf0_is_c0
        cp[jk0,jf0] = 0.0       # treat k=f=0 as stationary (c=0)
      else
        cp[jk0,jf0] = 1.0/0.0   # not to count k=f=0 component at all (c=infty)
      end

      [cp, cunits]
    end

  end
end

######################################################
## < test >
if $0 == __FILE__
  require "numru/ggraph"

  include NumRu
  include NMath

  # < make a GPhys from scratch >
  vx = VArray.new( NArray.float(11).indgen! * (3*Math::PI/11) ).rename("x")
  vx.units = 'km'
  vy = VArray.new( NArray.float(8).indgen! * (3*Math::PI/8) ).rename("y")
  vy.units = 'km'
  xax = Axis.new().set_pos(vx)
  #yax = Axis.new(true).set_cell_guess_bounds(vy).set_pos_to_center
  yax = Axis.new().set_pos(vy)
  grid = Grid.new(xax, yax)
  a = NArray.float(vx.length, vy.length)
  a[] = sin(vx.val.newdim(1)) * cos(vy.val.newdim(0))
  v = VArray.new( a )
  v.units = 'm/s'
  gpz = GPhys.new(grid,v)

  print "Original:\n"
  p gpz.val
  fc = gpz.fft
  print "2D FFT & abs:\n"
  p fc.val.abs, fc.units.to_s, fc.coord(0).units.to_s
  print "Check the invertivility: ",
        (fc.fft(true) - gpz).abs.max, ' / ', gpz.abs.max, "\n"
  sp = fc.abs**2
  print "Check parsevals relation: ",
        sp.sum, ' / ', (gpz**2).mean, "\n"

  spex = sp.spect_zero_centering(0)
  spex2 = spex.spect_one_sided(1)
  print "   sidedness changed -->  ",spex.sum,",  ",spex2.sum,"\n"

  if defined?(FFTW3)
    fc = gpz.fft(nil, 0)
    print "1D FFT & abs:\n"
    p fc.val.abs
    print "Check the invertivility: ",
          (fc.fft(true, 0) - gpz).abs.max, ' / ', gpz.abs.max, "\n"
    sp = fc.abs**2
    print "Check parsevals relation: ",
          sp.sum(0).mean, ' / ', (gpz**2).mean, "\n"
  end

  print "\n** Check detrend **\n"
  print "when NArray...\n"
  EPS = 5e-14
  a.indgen!
  v = VArray.new( a )
  gp = GPhys.new(grid,v)
  gpdt = gp.detrend(0)
  if gpdt.val.max <EPS; print "test succeeded\n";else; raise "test failed";end
  gpdt = gp.detrend(1)
  if gpdt.val.max <EPS; print "test succeeded\n";else; raise "test failed";end
  print "  -- NArrayMiss\n"
  mask = a.le(47)
  am = NArrayMiss.to_nam(a, mask)
  v = VArray.new( am )
  gp = GPhys.new(grid,v)
  gpdt = gp.detrend(0)
  #if gpdt.val.max <EPS; print "test succeeded\n";else; raise "test failed";end
  p "The following should be basically zero:",gpdt.val
  gpdt = gp.detrend(1)
  #if gpdt.val.max <EPS; print "test succeeded\n";else; raise "test failed";end
  p "The following should be basically zero:",gpdt.val

  print "\n** Check cos_taper **\n"
  a = NArray.float(30,10).fill!(1)
  v = VArray.new( a )
  xax2 = Axis.new().set_pos(VArray.new(NArray.float(30).indgen!).rename("x"))
  yax2 = Axis.new().set_pos(VArray.new(NArray.float(10).indgen!).rename("y"))
  gp = GPhys.new( Grid.new(xax2, yax2), v )
  gpct = gp.cos_taper(0)
  gpct = gp.cos_taper(0,1)
  p gpct.val
  p GPhys::COS_TAPER_SP_FACTOR, 1/GPhys::COS_TAPER_SP_FACTOR

  print "\n** Check phase velocity binning **\n"

  vd = VArray.new( NArray.to_na([0.0,1.0]),{"units"=>"m","long_name"=>"dummy"},"d")
  dax = Axis.new().set_pos(vd)
  vy.units = 'hour'
  vy.name = 't'

  xx = vx.val.newdim(1)
  yy = vy.val.newdim(0)
  a = sin(xx) * cos(yy) + 0.5*sin(xx*1.2+yy*0.6)
  #a = 0.5*sin(xx*1.2+yy*0.7)
  #a = sin(xx) * cos(yy)  + 0.2*sin(xx+yy)
      
  b = NArray.float(a.shape[0], 2, a.shape[1])
  b[true,0,true] = a + 1
  b[true,1,true] = a
  v = VArray.new( b, {"units"=>"K", "long_name"=>"vv"}, "v" )
  grid = Grid.new(xax, dax, yax)
  gp = GPhys.new(grid, v)

  fc = gp.fft(nil, 0, 2)
  sp = fc.abs**2
  fconv = UNumeric[1/3.6e3,"hour/s"]
  kconv = UNumeric[1e-3,"km/m"]
  csp = fc.phase_velocity_binning(0, 2, {"min"=>-2,"max"=>2,"int"=>0.25}, 
                                  kconv, fconv)
  p csp
  #cspn = sp.phase_velocity_binning_iso_norml(0, 2, -2, 2, 0.25, kconv, fconv)

  DCL.gropn(1)
  DCL.sldiv('y',2,2)
  GGraph::tone gp[true,0,true],true,"color_bar"=>true
  GGraph::line csp[true,0].real,true, "max"=>0.6,"min"=>-0.6
  GGraph::line csp[true,0].imag,false, "type"=>2
  #GGraph::line cspn[true,0]

  gpf = gp.phase_velocity_filter(0, 2, -2.0, 0.0, 1/kconv, 1/fconv)
  GGraph::tone gpf[true,0,true],true,"color_bar"=>true
  gpf = gp.phase_velocity_filter(0, 2, -0.3, -0.01, 1/kconv, 1/fconv)
  GGraph::tone gpf[true,0,true],true,"color_bar"=>true


  DCL.grcls
end

