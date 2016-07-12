#==============================================================================
#  Link JavaClass
#  --------------
# A link in SimBio is merely a means to connect various parameters and
# variables in the model with the same calculated values. Thing is, links are
# treated differently internally, so this workaround is necessary to ease
# the handling of links from JRuby's side.
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

class SimBio::Core::Link
  
  #-------------------------------------------------------------------------
  # * Retrieve Value from Linked Node
  #-------------------------------------------------------------------------
  def value
    return self.parent.get_node(self.value_string).value
  end
  
  def set_value new_value
    self.parent.get_node(self.value_string).set_value new_value
  end
  
  def relink ref
    self.set_value_string ref
    self.set_links
  end
end

