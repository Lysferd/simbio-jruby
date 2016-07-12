#==============================================================================
#  Observer JavaClass
#  ------------------
# Observers are objects that get called by the conductor once before, and once
# after the calculation process. No more, no less.
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

class MyObserver
  include SimBio::Core::CalculationObserver
  include Verbose
  
  #-------------------------------------------------------------------------
  def initialize
    super()
    
    @start_time  = Time::now
    
    verbose "CalculationObserver #{self} initialized."
  end
  
  #-------------------------------------------------------------------------
  def start
    # puts
    # puts '=' * 32
    verbose 'Calculation process initialized.'
  end
  
  #-------------------------------------------------------------------------
  def stop
    verbose "Calculation process finalized in #{Time::now - @start_time} seconds."
  end
end

