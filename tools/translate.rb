#!/usr/bin/env ruby
# Encoding: UTF-8
#==============================================================================
#  Translate to CSV v1.2
#  ---------------------
# This script generates a series of CSV files containing axial coordinates and
# a given magnitude value, in order to be read in ParaView as a table of points
# and allow for an easier geometric analysis of phenomena.
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

INPUT = 'out/cubix/1.8/5x5x5-cell/-250000.0/cell_volt.csv'
OUTPUT = 'out/sim/voltage%03i.csv'

begin
  data = File::new INPUT, ?r
  
  for line in data.readlines
    time, *voltages = line.split(?,).map(&:to_f)
    
    File::open( OUTPUT % (time + 1), ?w ) do | file |
      file << "X-Axis,Y-Axis,Z-Axis,Voltage\n"
      
      # output order is k -> j -> i
      # depth, then column, then row
      for i in 0...5
        for j in 0...5
          for k in 0...5
            file << "%i,%i,%i,%f\n" % [   i,   j,   k, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [   i,   j, k+1, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [   i, j+1,   k, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [   i, j+1, k+1, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [ i+1,   j,   k, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [ i+1,   j, k+1, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [ i+1, j+1,   k, voltages[i] ]
            file << "%i,%i,%i,%f\n" % [ i+1, j+1, k+1, voltages[i] ]
          end
        end
      end
    end
  end
  
ensure
  data.close if data and not data.closed?
end
