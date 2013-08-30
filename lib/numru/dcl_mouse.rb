require "numru/dcl"

module NumRu

  class DCLMousePt
    @@t_thres = 0.05  # threshold of time delay [in sec] to judge interaction
    def initialize
      ta = Time.now
      wx = wy = nil
      while(true)
        wx, wy, mb = DCL.swqpnt
        tb = Time.now
        if (tb-ta > @@t_thres)   # OK if it takes a short time 
          break 
        else     # Too fast. It must be due to previous clicks. Take one again.
          ta = tb
        end
      end
      @rx, @ry = NumRu::DCL.stiwtr(wx, wy)
      @vx, @vy = NumRu::DCL.stipr2(rx, ry) 
      @ux, @uy = NumRu::DCL.stitrf(vx, vy)
      @wx = wx
      @wy = wy
    end

    attr_accessor :ux, :uy, :vx, :vy, :rx, :ry, :wx, :wy

    def uxy
      [@ux, @uy]
    end

    def vxy
      [@vx, @vy]
    end

    def rxy
      [@rx, @ry]
    end

    def mark(type=2,index=1,size=0.02)
      DCL.uumrkz([@ux], [@uy], type, index, size)
    end
  end

  class DCLMouseLine
    def initialize(num=2)
      raise("Number of points must be 2 or greater") if num<2
      @p = Array.new
      num.times{@p.push(DCLMousePt.new)}
      @ux = @p.collect{|p| p.ux}
      @uy = @p.collect{|p| p.uy}
      @vx = @p.collect{|p| p.vx}
      @vy = @p.collect{|p| p.vy}
      @rx = @p.collect{|p| p.rx}
      @ry = @p.collect{|p| p.ry}
      @wx = @p.collect{|p| p.wx}
      @wy = @p.collect{|p| p.wy}
    end

    attr_accessor :ux, :uy, :vx, :vy, :rx, :ry, :wx, :wy
      
    # Drawn in the V coordinate so that it will be a straight line
    # on the display
    def draw(type=1,index=1)
      DCL.sgplzv(vx,vy,type,index)
    end

  end

end

