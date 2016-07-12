#!/usr/bin/env ruby
# Encoding: UTF-8
#==============================================================================
#  Simulate Cablixes
#  -----------------
# This script iterates and simulates series of one-dimensional cable-like
# structures (cablix) of ventricular cells. This script does not accept
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
$stdout.reopen "out/cablix/log (#{Time::now.strftime('%Y-%m-%d')})", ?w
$stderr.reopen "out/cablix/error (#{Time::now.strftime('%Y-%m-%d')})", ?w

input = -5e3

[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000, 2000, 3000, 4000, 5000 ].each do | grid |
  loop do
    puts
    puts '-=-=-=-=-=-=-=-=-=-'
    puts "Running simulation for grid size: %i, input current: %.1e" % [ grid, input ]
    
    begin
      t = Tissue::new cell_count: [grid.to_i],
                      input_current: input,
                      output_path: "cablix/1.8/#{grid}-cell/#{input}/",
                      model_name: 'out/cablix/cablix_model.xml'
      if t.update
        break
      else
        input += -5e3
      end
      
    rescue RangeError
      puts $!
      next # in case of range error (NaN/infinity) just continue iterating
    end
  end
end
