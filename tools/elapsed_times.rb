#!/usr/bin/env ruby
# Encoding: UTF-8
#==============================================================================
#  Output Elapsed Times v1.0
#  -------------------------
# This script reads through the logs and outputs the time taken for each
# simulation iteration to finalize.
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

Dir['cablix/log*'].each { |n|
  File::open(n,?r) { |f|
    f.readlines.each { |l|
      if l =~ /size: ([\dx]+)/
        print($1+"\t")
      elsif l =~ /(\d+) days, (\d+) hours, (\d+) minutes and (\d+) seconds/
        print("%02i:%02i:%02i\n"%[$1.to_i*24+$2.to_i, $3.to_i, $4.to_i])
      end
    }
  }
}
