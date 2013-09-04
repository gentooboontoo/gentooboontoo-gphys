## from [dennou-ruby:002690] by koshiro
## Sample of axis-drwaing options: 'xmaplabel', 'ymaplabel' in GGraph,
## which labels axes bettern than in the default drwaing when itr==10
## uses 90E, 90W, etc instead of 90, 270, etc.

require 'numru/ggraph'
include NumRu

wsn = ( ARGV[0] ? ARGV[0].to_i : 1 )

path = '../testdata/T.jan.nc'
var = 'T'
gp = GPhys::IO.open(path,var)

DCL.swpset('ldump',true) if wsn == 4
DCL.gropn(wsn)
DCL.sldiv('y',3,2)
#DCL.uzfact(0.8)
DCL.sgpset('lcntl',false)

GGraph.set_map('coast_world'=>true)

gpjpn = gp.cut(110..160,10..70,false)

itr = 10

# contour
GGraph.next_fig('itr'=>itr)
GGraph.contour(gp, true,'map_axes'=>true,'title'=>'default axes')

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
GGraph.contour(gp, true,'map_axes'=>true,'title'=>'lon/lat axes')

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat','xtickint'=>30, 'ytickint'=>10, 'xlabelint'=>90, 'ylabelint'=>30)
GGraph.contour(gp, true,'map_axes'=>true,'title'=>'lon/lat axes (set interval)')

# tone
GGraph.next_fig('itr'=>itr)
GGraph.tone(gp, true,'map_axes'=>true,'title'=>'default axes')

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
GGraph.tone(gp, true,'map_axes'=>true,'title'=>'lon/lat axes')

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat','xtickint'=>30, 'ytickint'=>10, 'xlabelint'=>90, 'ylabelint'=>30)
GGraph.tone(gp, true,'map_axes'=>true,'title'=>'lon/lat axes (set interval)')


# tone & contour
GGraph.next_fig('itr'=>itr)
GGraph.tone(gpjpn, true,'map_axes'=>true,'title'=>'default axes')
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
GGraph.tone(gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes')
GGraph.contour( gpjpn, false )

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat','xtickint'=>10, 'ytickint'=>10, 'xlabelint'=>30, 'ylabelint'=>30)
GGraph.tone(gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes (set interval)')
GGraph.contour( gpjpn, false )


# vector ('flow_vect'=>false)
GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'default axes','flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes','flow_vect'=>false,'unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat','xtickint'=>10, 'ytickint'=>10, 'xlabelint'=>30, 'ylabelint'=>30)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes (set interval)','flow_vect'=>false,'unit_vect'=>true)

# vector ('flow_vect'=>true)
GGraph.next_fig('itr'=>itr)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'default axes','unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat')
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes','unit_vect'=>true)

GGraph.next_fig('itr'=>itr)
GGraph.next_axes('xmaplabel'=>'lon','ymaplabel'=>'lat','xtickint'=>10, 'ytickint'=>10, 'xlabelint'=>30, 'ylabelint'=>30)
GGraph.vector(gpjpn,gpjpn, true,'map_axes'=>true,'title'=>'lon/lat axes (set interval)','unit_vect'=>true)

DCL.grfrm
DCL.grfrm
DCL.grfrm

### DCLExt::lon_ax, DCLExt::lat_ax

DCL.grfrm
DCL.grswnd(0.0, 360.0, -90.0, 90.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(1)
DCL.grstrf
DCLExt.lon_ax
DCLExt.lat_ax
DCLExt.lon_ax('cside'=>'t')
DCLExt.lat_ax('cside'=>'r')

DCL.grfrm
DCL.grswnd(0.0, 360.0, -90.0, 90.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(1)
DCL.grstrf
DCLExt.lon_ax('dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('dtick1'=>10, 'dtick2'=>30)
DCLExt.lon_ax('cside'=>'t', 'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('cside'=>'r', 'dtick1'=>10, 'dtick2'=>30)

DCL.grfrm
DCL.grswnd(-90.0, 90.0, 0.0, 360.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(1)
DCL.grstrf
DCLExt.lon_ax('yax'=>true,'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('xax'=>true,'dtick1'=>10, 'dtick2'=>30)
DCLExt.lon_ax('yax'=>true,'cside'=>'r', 'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('xax'=>true,'cside'=>'t', 'dtick1'=>10, 'dtick2'=>30)

DCL.grfrm
DCL.grswnd(90.0, -90.0, 360.0, 0.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(1)
DCL.grstrf
DCLExt.lon_ax('yax'=>true,'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('xax'=>true,'dtick1'=>10, 'dtick2'=>30)
DCLExt.lon_ax('yax'=>true,'cside'=>'r', 'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('xax'=>true,'cside'=>'t', 'dtick1'=>10, 'dtick2'=>30)

DCL.grfrm
DCL.grswnd(-90.0, 90.0, 1000.0, 1.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(2)
DCL.grstrf
DCL.ulpset('iytype',3)
DCL.ulylog('l', 3, 9)
DCL.ulylog('r', 3, 9)
DCLExt.lat_ax('xax'=>true,'dtick1'=>10, 'dtick2'=>30)
DCLExt.lat_ax('xax'=>true,'cside'=>'t', 'dtick1'=>10, 'dtick2'=>30)

DCL.grfrm
DCL.grswnd(-180.0, 180.0, -90.0, 90.0)
DCL.grsvpt(0.15, 0.95, 0.3, 0.7)
DCL.grstrn(1)
DCL.grstrf
DCLExt.lon_ax('dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('dtick1'=>10, 'dtick2'=>30)
DCLExt.lon_ax('cside'=>'t', 'dtick1'=>30, 'dtick2'=>90)
DCLExt.lat_ax('cside'=>'r', 'dtick1'=>10, 'dtick2'=>30)

DCL.grcls
