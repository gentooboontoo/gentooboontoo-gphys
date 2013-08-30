# The root file to load the entire gphys package except GGraph.

begin
require "rubygems"
rescue LoadError
end
require 'numru/gphys/gphys'
require "numru/gphys/gphys_io"
require 'numru/gphys/gphys_fft'
require 'numru/gphys_ext'  # extension library
require 'numru/gphys/interpolate'
require 'numru/gdir'
# require 'numru/gphys/ep_flux' # Made optional. Require it explicitly if needed
