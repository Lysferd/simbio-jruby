#!/usr/bin/env ruby
# Encoding: UTF-8
#==============================================================================
#  Main Entry
#  ----------
# This file accepts various arguments in order to perform a single iteration of
# simulation.
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

BEGIN {
  $Verbose = false
  $Step = false
  cell_count = [ 1 ]
  output_path = ''
  input_current = -5.0e3
}

begin
  unless ARGV.empty?
    for parameter in ARGV
      case parameter 
      when /(?:-v|--verbose)/
        $Verbose = true
      when /(?:-s|--step)/
        $Step = true
      when /(?:-c|--count)\s?([\d+x?]+)/
        cell_count = $1.split(?x).map(&:to_i)
      when /(?:-i|--input)\s?([\d\.\-eE\+]+)/
        input_current = $1.to_f
        input_current = -input_current if input_current > 0.0 # fix possibility of typos in input current
      when /(?:-o|--out)\s?([\/\.\-\w\d]+)/
        output_path = $1
      when /(?:-m|--model)\s?([\.\w\d]+)/
        model_name = $1
      end
    end
  end
  
  t = Tissue::new(
    cell_count:    cell_count,
    input_current: input_current,
    output_path:   output_path,
    model_name:    model_name
  )
  
  puts t.update
end
