# druby_cli1.rb -- a sample dRuby client
#
# USAGE
#   See ./druby_serv1.rb

require "drb/drb"
require "numru/gphys"
include NumRu

DRb.start_service
uri = ARGV.shift || raise("Usage: % #{$0} uri")
gp = DRbObject.new(nil, uri)

p gp.class, gp.name, gp.rank, gp.length
p gp.grid.axis(0).pos.name

gps = gp[0,true,true]
p gps.class, gps.name, gps.rank, gps.length
p gps.grid.axis(0).pos.name

gpmean = gp[true,true,0].mean(0)
p gpmean.class, gpmean.name, gpmean.rank, gpmean.length
p gpmean.grid.axis(0).pos.name
