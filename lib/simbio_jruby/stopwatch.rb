
#==============================================================================
#  StopWatch JavaClass
#  -------------------
# StopWatch objects are also children of Analyzer, so iterating over all
# analyzers in a conductor also returns it. This is thus a mere workaround.
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
class SimBio::Simulator::Analyzer::StopWatch
  
  #-------------------------------------------------------------------------
  # * Do Nothing On Output
  #-------------------------------------------------------------------------
  def output
    return
  end
  
end

