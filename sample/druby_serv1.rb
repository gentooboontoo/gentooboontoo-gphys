=begin
=druby_serv1.rb

a sample dRuby server

==USAGE

To start the server:

     % ruby druby_serv1.rb

This will print the address of the server such as
druby://[hostname]:[port] (For exaple druby://horihost:39391

Then run the client as (if the address is druby://horihost:39391):

     % ruby druby_cli1.rb druby://horihost:39391
=end

require "drb/drb"
require "numru/gphys"
include NumRu

file = NetCDF.open("../testdata/T.jan.nc")
gp = GPhys::NetCDF_IO.open(file,"T")

DRb.start_service(nil, gp)
puts 'URI: '+DRb.uri
puts '[return] to exit'
gets
