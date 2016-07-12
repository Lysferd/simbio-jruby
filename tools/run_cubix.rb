#!/usr/bin/env ruby
# Encoding: UTF-8
#==============================================================================
#  Simulate Cubixes
#  ----------------
# This script iterates and simulates series of three-dimensional cubic
# structures (cubix) of ventricular cells. This script does not accept
# arguments, instead it has to be manually editted to fit one's necessities.
# Copyright 2016  Fábio Moritz de Almeida
#
# This file is part of SimBio-JRuby.
# SimBio-JRuby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SimBio-JRuby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SimBio-JRuby.  If not, see <http://www.gnu.org/licenses/>.
#==============================================================================

$LOAD_PATH.push "#{File.dirname(__FILE__)}/lib"
$LOAD_PATH.push "#{File.dirname(__FILE__)}/javalib"
require 'simbio_jruby'

$Verbose = true
$stdout.reopen "out/cubix/log (#{Time::now.strftime('%Y-%m-%d')})", ?w
$stderr.reopen "out/cubix/error (#{Time::now.strftime('%Y-%m-%d')})", ?w


input = -2.5e5

%w( 5x5x5 6x6x5 7x7x5 8x8x5 9x9x5 10x10x5 15x15x5 20x20x5 25x25x5 30x30x5 35x35x5 40x40x5 45x45x5 50x50x10 ).each do | grid |
  loop do
    puts
    puts '-=-=-=-=-=-=-=-=-=-'
    puts "Running simulation for grid size: %s, input current: %.1e" % [ grid, input ]
    
    begin
      t = Tissue::new cell_count: grid.split(?x).map(&:to_i),
                      input_current: input,
                      output_path: "cubix/1.8/#{grid}-cell/#{input}/",
                      model_name: 'out/cubix/cubix_model.xml'
      if t.update
        break
      else
        input += -5e4
      end
      
    rescue RangeError
      puts $!
      next # in case of range error (NaN/infinity) just continue iterating
    end
  end
end
