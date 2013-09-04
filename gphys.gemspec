# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "gentooboontoo-gphys"
  gem.version       = '0.6.1.2'
  gem.authors           = ["Takeshi Horinouchi", "Ryo Mizuta",\
    "Daisuke Tsukahara", "Seiya Nishizawa", "Shin-ichi Takehiro"]
  gem.email         = ["julien.sanchez@gmail.com"]
  gem.description      = %q{a multi-purpose class to handle Gridded Physical quantities.}
  gem.summary          = %q{GPhys fork compatible with Rubygems}
  gem.homepage         = 'https://github.com/gentooboontoo/gentooboontoo-gphys'

  gem.files         = Dir["lib/**/*",
                          "bin/*",
                          "ChangeLog",
                          "doc/**/*",
                          "LICENSE.txt",
                          "README",
                          "sample/**/*",
                          "test/*",
                          "testdata/*"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = Gem::Requirement.new(">= 1.8")

  gem.add_runtime_dependency(%q<narray>, [">= 0.5.7"])
  gem.add_runtime_dependency(%q<numru-misc>, [">= 0.1.0"])
  gem.add_runtime_dependency(%q<numru-units>, [">= 1.7"])
  gem.add_runtime_dependency(%q<narray_miss>, [">= 1.2.4"])
  gem.add_runtime_dependency(%q<ruby-netcdf>, [">= 0.6.6"])
  gem.add_runtime_dependency(%q<ruby-fftw3>, [">= 0.3"])
  gem.add_runtime_dependency(%q<ruby-lapack>, [">= 1.5"])
  gem.add_development_dependency(%q<rb-grib>, [">= 0.2.0"])
end
