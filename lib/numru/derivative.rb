require "narray"

############################################################

=begin
=module NumRu::Derivative in derivative.rb

==todo
* decide argument of b_expand_linear_ext is Symbol or Numeric.
  * now is Numeric.
  * it denpends the treatment of dRuby.
* support other boundary conditions.

==Index
* ((<module NumRu::Derivative>))
  * ((<threepoint_O2nd_deriv>))
    * First derivative (2nd Order difference use three point.)
  * ((<cderiv>))
    * First derivative (center difference use two point.)
  * ((<deriv2d>))
    * 2nd derivative
  * ((<b_expand_linear_ext>))
    * return array extended boundaries with linear extention.
  * ((<cdiff>))
    * return difference. (center difference)

=module NumRu::Derivative

Module functions of Derivative Operater for NArray.

---threepoint_O2nd_deriv(z, x, dim, bc=LINEAR_EXT)

    Derivate of (({z})) with respect to (({dim})) th dim using a 2nd 
    order 3-point differentiation valid for non-uniform grid: 
      (s**2*z_{i+1} + (t**2 - s**2)*f_{i} - t**2*f_{i-1}) / (s*t*(s + t))
    Here, s represents (x_{i} - x_{i-1}) ,t represents (x_{i+1} - x_{i})
    and _{i} represents the suffix of {i} th element in the ((<dim>)) th 
    dimension of the array. ).

    ARGUMENTS
    * z (NArray): a NArray which you want to derivative.
    * x (NArray): a NArray represents the dimension which derivative respect to.
      z.rank must be 1.
    * dim (Numeric): a Numeric represents the dimention which derivative respect to. 
      you can give number count backward (((<dim>))<0), but ((<z.rank ¡Üdim>)) must be > 0. 
    * bc (Numeric) : a Numeric to represent boundary condition.
      Supported conditions are expressed in terms of boundary extension
      applied before differentiation:
       * LINEAR_EXT(=1): default value. linear extension using two
         grid points at the boundaries.
       * CYCLIC_EXT(=2): cyclic extension as k,0,1,..,k,0 for indices 0,1,..,k
       * MIRROR_A(=3): for indices 0,1,..,k, extends as 0,0,1,..,k,k
         (good for cell interior values with the Neumann condition)
       * MIRROR_B(=4): for indices 0,1,..,k, extends as 1,0,1,..,k,k-1
         (good for cell boundary values with the Neumann condition)

    RETURN VALUE
    * O2nd_deriv_data (NArray): (s**2*z_{i+1} + (t**2 - s**2)*f_{i} - t**2*f_{i-1}) / (s*t*(s + t))


---cderiv(z, x, dim, bc=LINEAR_EXT)

    Derivate of (({z})) with respect to (({dim})) th dim using centeral 
    differenciation: (z_{i+1} - z_{i-1}) / (x_{i+1} - x_{i-1})

    ARGUMENTS
    * z (NArray): a NArray which you want to derivative.
    * x (NArray): a NArray represents the dimension which derivative respect 
      to. z.rank must be 1.
    * dim (Numeric): a Numeric represents the dimention which derivative 
      respect to. you can give number count backward (((<dim>))<0), but 
      ((<z.rank ¡Üdim>)) must be > 0. 
    * bc (Numeric) : a Numeric to represent boundary condition.
      See ((<threepoint_O2nd_deriv>)) for supported conditions.

    RETURN VALUE
    * cderiv_data (NArray): (z_{i+1} - z_{i-1}) / (x_{i+1} - x_{i-1})

---deriv2nd(z, x, dim, bc=LINEAR_EXT)

    2nd Derivate of (({z})) with respect to (({dim}))-th dim
    covering non-uniform grids. Based on:
      ( (z_{i+1}-z_{i})/(x_{i+1}-x_{i}) - (z_{i}-z_{i-1})/(x_{i}-x_{i-1}) )
      / ((x_{i+1}-x_{i-1})/2)

    ARGUMENTS
    * z (NArray): a NArray which you want to derivative.
    * x (NArray): a NArray represents the dimension which derivative respect 
      to. z.rank must be 1.
    * dim (Numeric): a Numeric represents the dimention which derivative 
      respect to. you can give number count backward (((<dim>))<0), but 
      ((<z.rank ¡Üdim>)) must be > 0. 
    * bc (Numeric) : a Numeric to represent boundary condition.
      See ((<threepoint_O2nd_deriv>)) for supported conditions.

    RETURN VALUE
    * cderiv_data (NArray): (z_{i+1} - z_{i-1}) / (x_{i+1} - x_{i-1})

---b_expand_linear_ext(z, dim)

    expand boundary with linear value. extend array with 1 grid at each 
    boundary with ((<dim>)) th dimension, and assign th value which diffrential
    value between a grid short of boundary and boundary grid in original array.
    (on other wards, 2*z_{0}-z_{1} or 2*z_{n-1}-z_{n-2}: now _{i} represents the 
     suffix of {i} th element in the ((<dim>)) th dimension of array. ).


    ARGUMENTS
    * z (NArray): a NArray which you want to expand boundary.
    * dim (Numeric): a Numeric represents the dimention which derivative 
      respect to. you can give number count backward (((<dim>))<0), but 
      ((<z.rank ¡Üdim>)) must be > 0. 

    RETURN VALUE
    * expand_data (NArray): 

---cdiff(x, dim)

    Diffrence operater. return an NArray which a difference ((<x>)) 
    ( in other wards, (x_{i+1} - x_{i-1}): now _{i} represents the suffix of 
    {i} th element in the ((<dim>)) th dimension of array. ).

    ARGUMENTS
    * x (NArray): a NArray which you want to get difference.
    * dim (Numeric): a Numeric representing the dimention which derivative 
      respect to. you can give number count backward (((<dim>))<0), but 
      ((<z.rank ¡Üdim>)) must be > 0. 

    RETURN VALUE
    * cdiff_data (NArray): (x_{i+1} - x_{i-1})

=end
############################################################

module NumRu

  module Derivative

    module_function 

    #<<module constant>>
    LINEAR_EXT = 1
    CYCLIC_EXT = 2
    MIRROR_A = 3
    MIRROR_B = 4

    def threepoint_O2nd_deriv(z, x, dim, bc=LINEAR_EXT)
      dim += z.rank if dim<0
      if dim < 0 || dim >= z.rank
        raise ArgumentError,"dim value(#{dim}) must be between 0 and (#{z.rank-1}"
      end
      raise ArgumentError,"rank of x (#{x.rank}) must be 1" if x.rank != 1
      # <<expand boundaries>>
      ze = b_expand(z,dim,bc)
      xe = b_expand_linear_ext(x,0)                 # always linear extention
      # <<differenciation>>
      to_rankD = [1]*dim + [true] + [1]*(ze.rank-1-dim) # to exand 1D to rank D
      dx = xe[1..-1] - xe[0..-2]                    # x_{i} - x_{i-1} (for i=0..n-2)
      dx2 = dx**2
      s = dx[0..-2]                                 # x_{i} - x_{i-1} (for i=0..n-3)
      t = dx[1..-1]                                 # x_{i+1} - x_{i} (for i=0..n-3)
      s2 = dx2[0..-2].reshape(*to_rankD)            # s**2
      t2 = dx2[1..-1].reshape(*to_rankD)            # t**2
      numerator =     ze[ *([true]*dim+[2..-1,false]) ] *  s2\
                    + ze[ *([true]*dim+[1..-2,false]) ] * (t2-s2) \
                    - ze[ *([true]*dim+[0..-3,false]) ] *  t2
      denominator = (s*t*(s+t)).reshape(*to_rankD)
      dzdx = numerator / denominator
      return dzdx
    end


    def cderiv(z, x, dim, bc=LINEAR_EXT)
      dim += z.rank if dim<0
      raise ArgumentError,"dim value (#{dim}) must be smaller than z.rank and >= 0" if dim >= z.rank || dim<0
      raise ArgumentError,"rank of x (#{x.rank}) must be 1" if x.rank != 1
      # <<expand boundary>>
      ze = b_expand(z,dim,bc)
      xe = b_expand_linear_ext(x,0)                 # expand boundary of axis.
      # <<difference operation>>
      dz = cdiff(ze,dim)
      dx = cdiff(xe,0)
      if dx.rank != dz.rank                         # make dx.rank == dz.rank
	dx = dx.reshape(*([1]*dim + [true] + [1]*(dz.rank-1-dim))) 
      end
      dzdx = dz/dx
      return dzdx
    end

    # 2nd derivative covering uniform grids
    def deriv2nd(z, x, dim, bc=LINEAR_EXT)
      dim += z.rank if dim<0
      if dim < 0 || dim >= z.rank
        raise ArgumentError,"dim value(#{dim}) must be between 0 and (#{z.rank-1}"
      end
      raise ArgumentError,"rank of x (#{x.rank}) must be 1" if x.rank != 1
      # <<expand boundaries>>
      ze = b_expand(z,dim,bc)
      xe = b_expand_linear_ext(x,0)                 # always linear extention
      # <<differenciation>>
      to_rankD = [1]*dim + [true] + [1]*(ze.rank-1-dim) # to exand 1D to rank D
      dx20 = xe[2..-1] - xe[0..-3]          # x_{i+1} - x_{i-1} (for i=1..-2)
      dx21 = xe[2..-1] - xe[1..-2]          # x_{i+1} - x_{i}   (for i=1..-2)
      dx10 = xe[1..-2] - xe[0..-3]          # x_{i} - x_{i-1}   (for i=1..-2)
      a2 = 2/(dx21*dx20).reshape(*to_rankD)
      a1 = (-2)/(dx21*dx10).reshape(*to_rankD)
      a0 = 2/(dx10*dx20).reshape(*to_rankD)
      d2zdx2    =     ze[ *([true]*dim+[2..-1,false]) ] *  a2 \
                    + ze[ *([true]*dim+[1..-2,false]) ] *  a1 \
                    + ze[ *([true]*dim+[0..-3,false]) ] *  a0
      return d2zdx2
    end


    def b_expand(z,dim,bc)
      case bc
      when LINEAR_EXT
        ze = b_expand_linear_ext(z,dim)             # linear extention
      when CYCLIC_EXT
        ze = b_expand_cyclic(z,dim)
      when MIRROR_A
        ze = b_expand_mirror_A(z,dim)
      when MIRROR_B
        ze = b_expand_mirror_B(z,dim)
      else
        raise ArgumentError,"unsupported boundary condition: #{bc}."
      end
      ze
    end
    
    def b_expand_linear_ext(z,dim)
      raise ArgumentError,"Len of #{dim}th dim (#{z.shape[dim]}) must be >= 2" if z.shape[dim] < 2

      val0  = z[*([true]*dim +  [0] + [false])]    # first
      val1  = z[*([true]*dim +  [1] + [false])]    # second
      valm1 = z[*([true]*dim + [-1] + [false])]    # last 
      valm2 = z[*([true]*dim + [-2] + [false])]    # one before last

      # expand boundary
      ze = z[*([true]*dim   + [[0,0..(z.shape[dim]-1),0]]  + [false])]  
      ze[*([true]*dim + [0]  + [false])] = 2*val0-val1      
      ze[*([true]*dim + [-1] + [false])] = 2*valm1-valm2    
      return ze
    end
    
    def b_expand_cyclic(z,dim)
      k = z.shape[dim]-1
      z[*([true]*dim   + [[k,0..k,0]]  + [false])]  
    end
    
    def b_expand_mirror_A(z,dim)
      k = z.shape[dim]-1
      z[*([true]*dim   + [[0,0..k,k]]  + [false])]  
    end
    
    def b_expand_mirror_B(z,dim)
      raise ArgumentError,"Len of #{dim}th dim (#{z.shape[dim]}) must be >= 2" if z.shape[dim] < 2
      k = z.shape[dim]-1
      z[*([true]*dim   + [[1,0..k,k-1]]  + [false])]  
    end
    
    def cdiff(z,dim)
      z1 = z[*([true]*dim   + [2..-1] + [false])]   
      z2 = z[*([true]*dim   + [0..-3] + [false])]   
      cz = z1-z2                                 # cz[i] = cz[n+1] - cz[n-1]
      return cz
    end
    
  end
  
end

######################################################
## < test >
if $0 == __FILE__

  include NumRu
  include NMath
  
  def test1(x1)
    f1 = sin(x1)
    dfdx1 = Derivative::cderiv(f1, x1, 0)
    dfdx2 = cos(x1)
    p(dfdx1) if $VERBOSE
    diff = (dfdx1 - dfdx2)[1..-2].abs
    err = diff.mean
    print "dfdx - kaiseki_kai (except boundary): "
    print err, "\t", diff.max,"\n"
    err
  end

  def test2(x1)
    f1 = sin(x1)
    dfdx1 = Derivative::threepoint_O2nd_deriv(f1, x1, 0)
    dfdx2 = cos(x1)
    p(dfdx1) if $VERBOSE
    diff = (dfdx1 - dfdx2)[1..-2].abs
    err = diff.mean
    print "dfdx - kaiseki_kai (except boundary): "
    print err, "\t", diff.max,"\n"
    err
  end

  def test3
    nx = 21
    x = 2*PI*NArray.float(nx).indgen!/nx
    f = sin(2*PI*NArray.float(nx,nx,nx).indgen!/nx)
    dfdx1 = Derivative::cderiv(f, x, 0)
    dfdx2 = Derivative::threepoint_O2nd_deriv(f, x, 0)
    diff = (dfdx1 - dfdx2).abs
    print "cderiv - o2deriv: "
    print diff.mean, "\t", diff.max,"\n"
    dfdx1 = Derivative::cderiv(f, x, 1)
    dfdx2 = Derivative::threepoint_O2nd_deriv(f, x, 1)
    diff = (dfdx1 - dfdx2).abs
    print "cderiv - o2deriv: "
    print diff.mean, "\t", diff.max,"\n"
    dfdx1 = Derivative::cderiv(f, x, 2)
    dfdx2 = Derivative::threepoint_O2nd_deriv(f, x, 2)
    diff = (dfdx1 - dfdx2).abs
    print "cderiv - o2deriv: "
    print diff.mean, "\t", diff.max,"\n"
  end

  def test4
    x = NArray.to_na([-1.0, 0.0, 2.0, 3.0])
    f = NArray.to_na([1.0,  0.0, 4.0, 4.0])
    dfdx = Derivative::threepoint_O2nd_deriv(f, x, 0)
    dfdx_anal = NArray.to_na([-1.0, 0.0, 2.0/3.0, 0.0])
    print "o2deriv - analytic: "
    diff = (dfdx - dfdx_anal).abs
    print diff.mean, "\t", diff.max,"\n"
  end
  
  def test5(x1)
    f1 = sin(x1)
    dfdx1 = Derivative::cderiv(f1, x1, 0, Derivative::CYCLIC_EXT)
    dfdx2 = cos(x1)
    p(dfdx1) if $VERBOSE
    diff = (dfdx1 - dfdx2).abs
    err = diff.mean
    print "dfdx - kaiseki_kai: "
    print err, "\t", diff.max,"\n"
    err
  end

  def gen_x(nx)
    2*PI*NArray.float(nx).indgen!/(nx-1)
  end
  def gen_xc(nx)
    2*PI*NArray.float(nx).indgen!/nx
  end
  def gen_x2(nx)
    2*PI*exp(-NArray.float(nx).indgen!/(nx-1))
  end


  print "**** single-D ****\n"

  print "**** equally spaced grid ****\n"
  er1 = test1( gen_x(11) )
  er2 = test1( gen_x(21) )
  print "error change from nx=11->21: ", er2/er1,"\n"

  print "**** equally spaced grid ****\n"
  er1 = test2( gen_x(11) )
  er2 = test2( gen_x(21) )
  print "error change from nx=11->21: ", er2/er1,"\n"

  print "**** equally spaced grid (cyclic) ****\n"
  er1 = test1( gen_xc(80) )
  er1 = test5( gen_xc(80) )

  print "**** multi-D ****\n"
  test3

  print "**** non-uniform grid ****\n"
  p 'x(11):',gen_x2(11),'x(21):',gen_x2(21)
  er1 = test1( gen_x2(11) )
  er2 = test1( gen_x2(21) )
  print "error change from nx=11->21: ", er2/er1,"\n"

  print "**** non-uniform grid (2nd order) ****\n"
  er1 = test2( gen_x2(11) )
  er2 = test2( gen_x2(21) )
  print "error change from nx=11->21: ", er2/er1,"\n"

  print "**** non-uniform grid (analytic test) ****\n" 
  test4

end
