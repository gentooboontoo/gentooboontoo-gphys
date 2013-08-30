=begin

=Reference manuals of the GPhys library

==Highlight
Core part of the GPhys class
  * ((<class NumRu::GPhys|URL:gphys.html>)) 
  * See also the entire ((<GPhys Core Part>)) section.
Visualization library
* ((<module NumRu::GGraph|URL:ggraph.html>))

((<Application Commands>))

---------------------------------------------------------------------

==GPhys and its components

====GPhys Core Part

A GPhys object has the following structure:

  -
             has 1
  a GPhys --------- array-like data (VArray)
           | has 1
           --------- grid (Grid)
                       |  has rank
                       ------------ axis (Axis)
                                     | has 1
                                     -------- 1D position data (VArray)
                                     | has 0..
                                     -------- ancillary data (VArray)

That is, a GPhys object consists of data (whose class is VArray) and
grid (whose class is Grid). The latter consists of axes (whose class is
Axis), which consist of VArray objects (such as ones that have
1-dimensional grid-point position data). To use GPhys, it is
useful to know these four classes.

* ((<class NumRu::VArray|URL:varray.html>)) :
  Virtual Array class, which holds multi-dimensional data of various
  format and media (on memory or in file).

  * ((<class NumRu::VArrayComposite|URL:varraycomposite.html>)) :
    Subclass of VArray to bundle multiple VArrays by "tiling".

* ((<class NumRu::Axis|URL:axis.html>)) : A class to represent a discretized physical coordinate.
* ((<class NumRu::Grid|URL:grid.html>)) : A class to represent discretized grids of physical quantities.
* ((<class NumRu::GPhys|URL:gphys.html>)) : Core part of the GPhys class

====Miscellaneous Extensions of GPhys

* ((<coordinate transformation|URL:coordtransform.html>)) :
  Extension of the NumRu::GPhys class for coordinate transformation.
* ((<FFT|URL:gphys_fft.html>)) :
  Extension of the NumRu::GPhys class 
  for the Fast Fourier Transformation and its applications
* ((<module NumRu::GPhys::Derivative|URL:derivative/index.html>)) :
  Module functions to make differentiation of GPhys objects.
* ((<module NumRu::GPhys::EP_Flux|URL:ep_flux/index.html>)) :
  Module functions to derive the Eliassen-Palm flux and related
  quantities (such as the residual circulation and its mass stream function).
* ((<interpolation|URL:interpolate/index.html>)) : Interpolation library
* ((<GAnalysis::Planet|URL:ganalysis_planet/index.html>)) : Library for spherical planets (default: Earth)
* ((<GAnalysis::Met|URL:ganalysis_met/index.html>)) : Meteorological analysis library

====Miscellaneous Dependent Libraries Distributed with GPhys

* ((<class NumRu::UNumeric|URL:unumeric.html>)) :
  Numeric with units (combination of Numeric and Units)
* ((<module NumRu::Derivative|URL:derivative/index.html>)) :
  Module functions to make differentiation using NArray.
* ((<class NumRu::SubsetMapping>)) : Sorry, yet to be written.
* ((<class NumRu::Attribute|URL:attribute.html>)) : A Hash class compatible with NetCDF attributes.
* ((<class NumRu::CoordMapping|URL:coordmapping.html>)) :
  * ((<class NumRu::LinearCoordMapping|URL:coordmapping.html>)) :
* ((<class NumRu::GrADS_Gridded|URL:grads_gridded.html>)) :
  Class to handle GrADS data.
* ((<class NumRu::Grib|URL:grib.html>)) :
  a class for GRIB datasets.
* ((<class NumRu::GDir::HtDir|URL:htdir.html>)) :
  A class to treat the URL of a "directory" as a directory (used in 
  GDir).
* ((<module NumRu::DCLExt|URL:derivative/dclext.html>)) :
  An extension of RubyDCL.

====External File Handlers of GPhys

* ((<module NumRu::GPhys::IO|URL:gphys_io.html>)) :
  GPhys file IO module for all file types.
* ((<module NumRu::GPhys::NetCDF_IO|URL:gphys_netcdf_io.html>)) :
  NetCDF data input/output.
* ((<module NumRu::NetCDF_Conventions, 
  module NumRu::NetCDF_Convention_Users_Guide etc.
  |URL:netcdf_convention.html>)) :
  NetCDF convention handler.
* ((<module NumRu::GPhys::GrADS_IO|URL:gphys_grads_io.html>)) :
  GrADS data input/output.
* ((<module NumRu::GPhys::Grib_IO|URL:gphys_grib_io.html>)) :
  GRIB data IO.

==Applications distributed with GPhys

To use the following, you have to ((|require|)) explicitly. 

* ((<module NumRu::GGraph|URL:ggraph.html>)) :
  A graphic library using GPhys.

* ((<class NumRu::GDir|URL:gdir.html>)) :
  A class to represent directories and data files for GPhys.

* ((<irb start-up program gdir_connect_ftp-like|URL:gdir_connect_ftp-like.html>)) A library to be required
  to interactively connect with a ((<gdir_server|URL:gdir_server.html>)).

==Application Commands

* ((<grads2nc_with_gphys|URL:grads2nc_with_gphys.html>)) file converter
  from the GrADS format to NetCDF
* ((<gdir_server|URL:gdir_server.html>)) A dRuby server with a GDir
  at the front end.
* ((<gdir_client|URL:gdir_client.html>)) : A client of gdir_server
  using irb with ((<gdir_connect_ftp-like|URL:gdir_connect_ftp-like.html>))

* ((<gpcat|URL:gpcat.html>)) Read a variable in multiple NetCDF files, concatenate and write them to a single netcdf file. 
* ((<gpcut|URL:gpcut.html>)) extract, slicing and thinning a GPhys variable
* ((<gplist|URL:gplist.html>)) print out variables and their dimensions
* ((<gpmath|URL:gpmath.html>)) operate a math function to a GPhys variable
* ((<gpmaxmin|URL:gpmaxmin.html>)) prints maximum and minimum values of a GPhys variable
* ((<gpprint|URL:gpprint.html>)) prints the values of a GPhys variable 
* ((<gpview|URL:gpview.html>)) visualizer (2D, 1D)

=end
