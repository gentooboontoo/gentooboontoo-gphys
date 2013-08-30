# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lib/numru/gphys/version'

Gem::Specification.new do |gem|
  gem.name          = "gentooboontoo-gphys"
  gem.version       = GPhys::VERSION
  gem.authors           = ["Takeshi Horinouchi", "Ryo Mizuta",\
    "Daisuke Tsukahara", "Seiya Nishizawa", "Shin-ichi Takehiro"]
  gem.email         = ["eriko@gfd-dennou.org"]
  gem.description      = %q{comprehensive library for self-descriptive gridded physical data (in NetCDF, GrADS, or on memory) with graphicsgraphicsgraphicsgraphics.}
  gem.summary          = %q{a multi-purpose class to handle Gridded Physical quantities}
  gem.homepage         = 'http://www.gfd-dennou.org/arch/ruby/products/gphys/'

  gem.files         = Dir["lib/**/*",
                          "bin/*",
                          "ChangeLog",
                          "doc/**/*",
                          "extconf.rb",
                          "ext/*.c",
                          "LICENSE.txt",
                          "README",
                          "sample/**/*",
                          "test/*",
                          "testdata/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.extensions << "ext/extconf.rb"

  gem.required_ruby_version = Gem::Requirement.new(">= 1.8")

  gem.add_runtime_dependency(%q<narray>, [">= 0.5.7"])
  gem.add_runtime_dependency(%q<numru-misc>, [">= 0.1.0"])
  gem.add_runtime_dependency(%q<numru-units>, [">= 1.7"])
  gem.add_runtime_dependency(%q<narray_miss>, [">= 1.2.4"])
  gem.add_runtime_dependency(%q<ruby-netcdf>, [">= 0.6.6"])
  gem.add_runtime_dependency(%q<ruby-dcl>, [">= 1.6.1"])
  gem.add_runtime_dependency(%q<ruby-fftw3>, [">= 0.3"])
  gem.add_runtime_dependency(%q<gsl>, [">= 1.14"])
  gem.add_runtime_dependency(%q<ruby-lapack>, [">= 1.5"])
  gem.add_development_dependency(%q<rb-grib>, [">= 0.2.0"])
end
