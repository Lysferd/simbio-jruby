#==============================================================================
#  Conductor JavaClass
#  -------------------
# Every instance of this class is a runnable thread that performs the 
# simulation calculi for biological models. This JRuby implementation is a
# runtime modification in order to expand usage possibilities of the original
# class in a JRuby environment. Thank you so much JRuby.
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

class SimBio::Core::Conductor
  include Verbose
  
  # -=-=-=-=-=-
  # Include modules to make typing easier:
  include SimBio::Core
  include SimBio::Core::Integrator
  
  # -=-=-=-=-=-
  # Allow readmode access to `ArrayList' objects originally
  # marked as `private' in the JavaClass code:
  field_reader :variables, :reactors, :analyzers, :nodes,
               :calculationObservers, :endTime
  field_accessor :isCalculate, :elapsedTime, :timeStep
  
  #-------------------------------------------------------------------------
  # * Object Initialization
  # The JavaClass code for the Conductor class does not contain
  # constructors, however just in case one is ever called, this method
  # might help notifying so: with an error, because histeria.
  #-------------------------------------------------------------------------
  def initialize
    fail NotImplementedError, 'Conductor constructor called!'
  end
  
  #-------------------------------------------------------------------------
  # * Object Update
  # This method replaces Java method `run', and must be called every frame
  # in order to perform the whole integration step by step.
  #-------------------------------------------------------------------------
  def update
    return unless calculating?
    verbose "Integrating for time #@t and step #@dt..."
    integrate
    
    # inb4 confused: if the calculating flag is false after performing the
    # integration, it means that it has finished.
    unless calculating?
      self.calculationObservers.each &:stop
      self.end
      return @successful
    end
  end
  
  #-------------------------------------------------------------------------
  # * Prepares Model for Integration
  #-------------------------------------------------------------------------
  alias :java_prepare :prepare
  def prepare
    
    # thing is, i dont get to know if the system actually contracted with the
    # given input current, so here i guess i'll need to create some amateur-ish
    # way to track it.
    @successful = false
    if self['cell 1/Vm']
      @first_cell = self['cell 1/Vm']
    elsif self['cell 1x1/Vm']
      @first_cell = self['cell 1x1/Vm']
    elsif self['cell 1x1x1/Vm']
      @first_cell = self['cell 1x1x1/Vm']
    end
    
    # from #run
    self.accept self
    self.set_links
    self.calculationObservers.each &:start
    
    # from #integrate
    self.isCalculate = true
    # @end_time = self.endTime
    @t        = self.elapsedTime.value
    @dt       = 0
    
    # original prepare
    java_prepare
  end
  
  #-------------------------------------------------------------------------
  # * Integrate Step by Step
  # This method is originally built in the Java library, but it has the
  # terrible fact that it performs the whole integration process within a
  # while loop, rendering it useless for the purpose of step-by-step calculi.
  # Anyway this is an override and thank the JRuby gods overrides work.
  #
  # Regardless, here is the old integration method for academic purposes:
  #
  # self.prepare
  # t  = self.elapsedTime.value
  # dt = 0
  # while dt > 0 and t < self.endTime and self.isCalculate
  #  self.reactors.calculate t
  #  self.analyzers.analyze t
  #  dt = self.variables.update t
  #  t += dt
  #  self.timeStep.value = dt
  #  self.elapsedTime.value = t
  # end
  # self.isCalculate = false
  #-------------------------------------------------------------------------
  alias :java_integrate :integrate
  def integrate
    # workaround to call original method (just in case)
    #java_integrate; return
    
    # self.reactors.calculate @t
    for reactor in self.reactors
      reactor.calculate @t
      fail RangeError if reactor.value.nan? or reactor.value.infinite? # stop calculation
    end
    
    @successful = true if @first_cell.value > 0.0
    
    self.analyzers.analyze @t
    @dt = self.variables.update @t
    @t += @dt
    self.timeStep.value = @dt
    self.elapsedTime.value = @t
    
    self.stop if @t > self.endTime or not @dt > 0.0
  end
  
  #-------------------------------------------------------------------------
  # * Insert objects in one of the Conductor's lists.
  # Checks for the object type and inserts it in the right list.
  #-------------------------------------------------------------------------
  def << *ary
    ary.flatten.each do |o|
      case o
      when Composite, Reactor, Analyzer, Euler, RungeKutta
        self.visit o
      when CalculationObserver
        self.add_calculation_observer o
      else
        fail ArgumentError
      end
    end
  end
  
  #-------------------------------------------------------------------------
  # * Retrieve Node
  # Iterates over all nodes in search of one whose name matches `ref'.
  #
  # [!] `result' is a terribly named variable that means "result from
  #     iterating over the children elements of this parent". If its
  #     value is nil, then no matches were found.
  #-------------------------------------------------------------------------
  def [] ref, iterator = self.nodes_iterator
    iterator.each do |node|
      # Return found object to last iterator:
      return node if node.name =~ /#{ref}$/i
      
      if defined? node.nodes_iterator
        result = self[ ref, node.nodes_iterator ]
        
        # Return matched object from child iterator to caller:
        return result if result
        
        # No matches were found in the children, continuing iteration:
        next
      end
    end
  end
  
  #-------------------------------------------------------------------------
  # * Calculation Flag
  # Basic helper method to make everything sassier to the eyes.
  #-------------------------------------------------------------------------
  def calculating?
    return self.isCalculate
  end
end

