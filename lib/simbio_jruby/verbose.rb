#==============================================================================
#  Verbose
#  -------
# Control class for outputting regarding verbose level.
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

module Verbose
  
  ELAPSED_TIME_INTEL = 'Calculation process completed in %d days, %d hours, %d minutes and %d seconds!'
  
  #-------------------------------------------------------------------------
  # puts if in verbose mode
  def verbose str = ''
    puts str if $Verbose
  end
  
  #-------------------------------------------------------------------------
  # puts regardless of verbose mode
  def verbose! str
    puts str
  end
  
  #-------------------------------------------------------------------------
  def elapsed time
    mm, ss = (Time::now - time).divmod 60
    hh, mm = mm.divmod 60
    dd, hh = hh.divmod 24
    verbose! ELAPSED_TIME_INTEL % [ dd, hh, mm, ss ]
  end
end
