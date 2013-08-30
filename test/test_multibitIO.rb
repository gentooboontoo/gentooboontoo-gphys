require "numru/gphys"
include NumRu
path = "../mltbit.dat"
mbio = MultibitIO.new("mltbit.dat")

10000.times{|i|
 na = mbio.read2D(12, 15, 100,100, 1,9,2, 1,7,3, nil, nil,
                        nil, nil)
 p(na) if i==0
 na = mbio.read2D(12, 15, 100,100, 
                        nil,nil,nil, 1,5,2, [0,5,3],nil, 0.1, 1000.0)
 p(na) if i==0

 na = mbio.read2D(12, 15, 100,100, 
                        nil,nil,nil, nil,nil,nil, [0,5,3],[90,80,5], nil, nil)
 p(na) if i==0
}


