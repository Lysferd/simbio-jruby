#==============================================================================
#  SimBio Module
#  -------------
# This script creates a container module for the Java-based SimBio library.
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

require 'java'
require 'simbio_jruby/jars'
require 'builder'

# Short names for commonly used Java packages
module SimBio
  SIMBIO = 'org.simBio'
end

# Make a selection of key SimBio classes available in a convenient module
module SimBio
  
  # java_import org.simBio.Composer
  # java_import org.simBio.Entry
  # java_import org.simBio.ResultGenerator
  # java_import org.simBio.Run
  # java_import org.simBio.RunGUI
  # java_import org.simBio.XmlGenerator
  
  module Bio
    #java_import org.simBio.bio.matsuoka_et_al_2003
  end
  
  module Core
    java_import org.simBio.core.Analyzer
    java_import org.simBio.core.AnalyzerList
    java_import org.simBio.core.CalculationObserver
    java_import org.simBio.core.Component
    java_import org.simBio.core.Composite
    java_import org.simBio.core.Conductor
    java_import org.simBio.core.Initializer
    java_import org.simBio.core.IResetBeforeCalc
    java_import org.simBio.core.Link
    java_import org.simBio.core.Node
    java_import org.simBio.core.NodeList
    java_import org.simBio.core.Parameter
    java_import org.simBio.core.Reactor
    java_import org.simBio.core.ReactorList
    java_import org.simBio.core.Variable
    java_import org.simBio.core.VariableList
    java_import org.simBio.core.Visitor
    
    module Integrator
      java_import org.simBio.core.integrator.Concentration
      java_import org.simBio.core.integrator.Euler
      java_import org.simBio.core.integrator.EulerList
      java_import org.simBio.core.integrator.Positive
      java_import org.simBio.core.integrator.PositiveRK
      java_import org.simBio.core.integrator.Probability
      java_import org.simBio.core.integrator.RungeKutta
      java_import org.simBio.core.integrator.RungeKuttaList
    end
  end
  
  module Serialize
    java_import org.simBio.serialize.Collector
    java_import org.simBio.serialize.Serializer
    java_import org.simBio.serialize.SerializerFactory
    
    module XML
      java_import org.simBio.serialize.xml.Encoder
      java_import org.simBio.serialize.xml.LogSax2
      java_import org.simBio.serialize.xml.Parser
      java_import org.simBio.serialize.xml.Updater
      java_import org.simBio.serialize.xml.XMLSerializer
    end
  end
  
  module Util
    java_import org.simBio.util.CsvHandler
    java_import org.simBio.util.DevelopmentMode
    java_import org.simBio.util.FileHandler
    java_import org.simBio.util.NodeHandler
    
    module Numerial
      java_import org.simBio.util.numerical.MathFunction
      java_import org.simBio.util.numerical.MathMultivariableFunction
      java_import org.simBio.util.numerical.MathUnivariableFunction
      
      module Methods
        java_import org.simBio.util.numerical.methods.BroydenMethod
        java_import org.simBio.util.numerical.methods.LUdecomposition
        java_import org.simBio.util.numerical.methods.SecantMethod
      end
    end
    
    module Taglets
      # java_import org.simBio.util.taglets.EnOff
      # java_import org.simBio.util.taglets.EnOn
      # java_import org.simBio.util.taglets.JaOff
      # java_import org.simBio.util.taglets.JaOn
      # java_import org.simBio.util.taglets.Languages
    end
  end
  
  module Simulator
    module Analyzer
      
      java_import org.simBio.sim.analyzer.StopWatch
      java_import org.simBio.sim.analyzer.VisualizeAnalyzer
      
      module CSV
        java_import org.simBio.sim.analyzer.csv.ALaCarte
        java_import org.simBio.sim.analyzer.csv.CsvMaker
        java_import org.simBio.sim.analyzer.csv.Siblings
        java_import org.simBio.sim.analyzer.csv.Total
        
        module Result
          java_import org.simBio.sim.analyzer.csv.result.AbstractAppender
          java_import org.simBio.sim.analyzer.csv.result.ALaCarte
        end
      end
      
      module Graph
        java_import org.simBio.sim.analyzer.graph.AbstractGraph
        
        module Results
          java_import org.simBio.sim.analyzer.graph.results.TimeSeriesValues
        end
      end
      
      module Measure
      end
    end
    
    module DM
    end
    
    module GUI
    end
    
    module PS
    end
  end
end

%w( version tissue verbose stopwatch ).each { | f | require "simbio_jruby/#{f}" }
