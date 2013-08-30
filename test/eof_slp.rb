require "numru/gphys"
require "numru/ganalysis"
require "numru/ggraph"
include NumRu

slp = GPhys::IO.open("slp.mon.mean.nc","slp") # ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis.derived/surface/slp.mon.mean.nc
slp = slp.cut("lat"=>30..90) # 北緯30度以北のデータを使用する
slp = slp[{0..-1,4},{0..-1,2},true] # 経度, 緯度について4, 2点おきに読む
                                    # 計算時間を速めるため（∴不要）
nt = slp.shape[2]
mon = NArray.sint(12,nt/12).indgen #=> [ [0,1,..,11], [12,13,..,23], .. ]
mon = mon[[0,1,11],true] # [0,1,11]: Jan,Feb,Dec (use [0] to include only Jan)
mon = mon.reshape!(mon.total) # to 1D (list of months to use)
slp = slp[true,true,mon] # 12,1,2月のデータを切取り

vec,val = slp.eof("time","norder"=>2) # EOF第2モードまで計算する

DCL::gropn(4)
GGraph.set_fig("itr"=>32)
eof = vec[true,true,0]
if eof.cut("lat"=>90).mean > 0
  eof = -eof # 北極における値がが負になるようにする
end
GGraph.tone(eof, true, "min"=>-7.0, "max"=>7.0)
GGraph.contour(eof,false, "min"=>-7.0, "max"=>7.0)
GGraph.map("coast_world"=>true)

DCL::grcls
