#==============================================================================
#  Ventricular Tissue Model
#  ------------------------
# Container class for a SimBio-based model ventricular cell.
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
java_import org.xml.sax.InputSource

require 'conductor'
require 'link'
require 'myobserver'
require 'analyzer'

class Tissue
  include SimBio
  include Verbose
  
  attr_reader :status

  # -=-=-=-=-=-
  # Standard model XML file as String:
  BASE_MODEL_BEFORE   = File::new('xml/model_before.xml').read
  BASE_MODEL_AFTER    = File::new('xml/model_after.xml').read
  
  EXTERNAL_MODEL_BEFORE = File::new('xml/external_before.xml').read
  EXTERNAL_MODEL_AFTER  = File::new('xml/external_after.xml').read
  
  CELL_MODEL          = File::new('xml/cell.xml').read
  CURRENT_CLAMP_MODEL = File::new('xml/current_clamp.xml').read
  GAP_JUNCTION_MODEL  = File::new('xml/gap_junction.xml').read
  STOP_WATCH_MODEL    = File::new('xml/stop_watch.xml').read
  
  # Analyzers for GapJunction Model:
  OBSERVERS = { main: MyObserver::new }
  ANALYZERS = {
    
    # electrical parameters
    'cell_volt'                      => 'cell #number/Vm',
    'cell_current'    => 'cell #number/current',   # becomes NaN
    'cell_current_k'  => 'cell #number/currentK',  # becomes NaN
    'cell_current_na' => 'cell #number/currentNa', # becomes +infinity
    'cell_current_ca' => 'cell #number/currentCa', # becomes -infinity
    
    # ionic currents
    # 'cell_INa' => 'cell #number/INa',
    # 'cell_ICaL' => 'cell #number/ICaL',
    # 'cell_ICaT' => 'cell #number/ICaT',
    # 'cell_IKr' => 'cell #number/IKr',
    # 'cell_IKs' => 'cell #number/IKs',
    # 'cell_Ito' => 'cell #number/Ito',
    # 'cell_INaK' => 'cell #number/INaK',
    # 'cell_LCCa' => 'cell #number/ILCCa',
    # 'cell_IKATP' => 'cell #number/IKATP',
    # 'cell_IKpl' => 'cell #number/IKpl',
    # 'cell_IbNSC' => 'cell #number/IbNSC',
    # 'cell_ICab' => 'cell #number/ICab',
    
    # ionic/metabolic concentrations
    # 'cell_na_concentration'               => 'cell #number/Na',
    # 'cell_k_concentration'                => 'cell #number/K',
    # 'cell_ca_concentration'               => 'cell #number/Ca',
    # 'cell_ca_total_concentration'         => 'cell #number/CaTotal',
    # 'cell_atp_total_concentration'        => 'cell #number/ATPtotal',
    # 'cell_adp_total_concentration'        => 'cell #number/ADPtotal',
    # 'cell_phospho_creatine_concentration' => 'cell #number/PhosphoCreatine',
    
    # metabolism
    #'cell_ph' => 'cell #number/pH',
    
    # mechanical parameters
    'cell_sarcomere_length'          => 'cell #number/crossBridge/halfsarcomerelength',
    'cell_force'                     => 'cell #number/crossBridge/forceCB',
    
    # junction parameters
    'junction_voltage'               => 'gap junction #number-#next/conductance/gj/Vj',
    'junction_current'               => 'gap junction #number-#next',
    'junction_conductance'           => 'gap junction #number-#next/conductance',
  }
  
  #-------------------------------------------------------------------------
  # * Object Initialization
  #  Instantiates the cell model object. Arguments are used to overwrite
  # default parameter values.
  #-------------------------------------------------------------------------
  def initialize args = Hash[ ]
    
    # -=-=-=-=-=-
    # Evaluate parameters:
    observers      = args[:observers]  || OBSERVERS
    @analyzers     = args[:analyzers]  || ANALYZERS
    @cell_count    = args[:cell_count]
    @input_current = args[:input_current]
    @output_path   = args[:output_path]
    @model_name    = args[:model_name]
    
    # -=-=-=-=-=-
    # Generate model XML from its parts, then instantiate cell model object:
    verbose! "Building model..."
    start_time = Time::now
    build
    input = InputSource::new(@model_name)
    @model = Serialize::SerializerFactory.get_serializer(input).read
    verbose! "Model built! Process took #{Time::now - start_time} seconds!"
    
    # -=-=-=-=-=-
    # Appending observers... or not, cuz they dont do much to begin with.
    #verbose! "Appending observers..."
    #start_time = Time::now
    #@model << observers.values
    #verbose! "Observers appended! Process took #{} seconds!"
    
    # -=-=-=-=-=-
    # Appending analyzers:
    verbose! "Appending analyzers..."
    start_time = Time::now
    @model << generate_analyzers.compact
    t = Time::now - start_time
    verbose! "Analyzers appended! Process took #{t} seconds!"
    
    @model.prepare # pray while it prepares
  end
  
  #-------------------------------------------------------------------------
  # * Run Model Calculation.
  #-------------------------------------------------------------------------
  def update
    verbose! 'Starting calculation process...'
    time = Time::now
    
    # matz-chan hates this kind of loop but it does look nice...
    begin
      @status = @model.update
      $stdin.getc if $Step # perform step by step
    end until finalized?
    
    elapsed time
    
    return @status
  end
  
  #-------------------------------------------------------------------------
  # * Build Model XML
  # Ruby-esque approach to build the XML file used as base model.
  #
  # Regarding 1D/2D Models:
  #   Cable Model (1D) is a simple array of cells arranged side-by-side,
  #  connected by a gap junction.
  #   Matrix Model (2D) is a grid of cells arranged symetrically,
  #  yet connected by gap junctions.
  #   Cubix Model (3D) is like a cube of cells.
  #-------------------------------------------------------------------------
  def build
    return File::open @model_name, ?w do |file|
      file << BASE_MODEL_BEFORE
      file << EXTERNAL_MODEL_BEFORE
      file << CURRENT_CLAMP_MODEL.gsub( /#first|#input/, '#first' => @cell_count.join( ?x ), '#input' => @input_current.to_s )
      
      case @cell_count.size
      # Cable of cells (1D Model):
      when 1
        rows = @cell_count.first
        for i in 1..rows
          file << CELL_MODEL.gsub( /#number/, i.to_s )

          if rows > 1 and i < rows
            next_cell = i + 1
            file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => i, '#next' => next_cell )
          end
        end
        
      # Matrix of cells (2D Model):
      when 2
        rows, columns = *@cell_count
        for i in 1..rows
          for j in 1..columns
            number      = '%dx%d' % [ i, j ]
            next_column = '%dx%d' % [ i, j + 1 ]
            next_row    = '%dx%d' % [ i + 1, j ]
            
            file << CELL_MODEL.gsub( /#number/, number )
            file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => number, '#next' => next_column ) unless j == columns
            file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => number, '#next' => next_row ) unless i == rows
          end
        end
      
      # Cube of cells (3D Model):
      when 3
        rows, columns, depth = *@cell_count
        for i in 1..rows
          for j in 1..columns
            for k in 1..depth
              number      = '%dx%dx%d' % [ i, j, k ]
              next_column = '%dx%dx%d' % [ i, j + 1, k ]
              next_row    = '%dx%dx%d' % [ i + 1, j, k ]
              next_depth  = '%dx%dx%d' % [ i, j, k + 1 ]
              
              file << CELL_MODEL.gsub( /#number/, number )
              file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => number, '#next' => next_column ) unless j == columns
              file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => number, '#next' => next_row ) unless i == rows
              file << GAP_JUNCTION_MODEL.gsub( /#number|#next/, '#number' => number, '#next' => next_depth ) unless k == depth
            end
          end
        end
      end
      
      file << EXTERNAL_MODEL_AFTER
      file << STOP_WATCH_MODEL
      file << BASE_MODEL_AFTER
    end
  end

  #-------------------------------------------------------------------------
  # * Generate Analyzers
  # Humble method to initialize all the analyzers needed to track the
  # calculation process.
  # Humble is really ironic since this method is the most memory and time
  # consuming piece of trash in this whole code.
  # So this means a new implementation is necessary.
  # 
  # Instead of creating a shitload of arrays with shitload sizes, send the
  # original pattern-like string and the number of nodes per axis to the
  # analyzer. The analyzer shall take care of iterating over all possible
  # nodes matching the given pattern string and output directly to file.
  # Meaning no more arrays! Hurray!
  #-------------------------------------------------------------------------
  def generate_analyzers
    return Array::new @analyzers.size do |index|
      filename, pattern = *@analyzers.to_a[index]
      MyAnalyzer::new( @output_path, filename, @model, pattern, @cell_count )
    end
  end
  
  #-------------------------------------------------------------------------
  def finalized?
    return !@model.calculating?
  end
  
  #-------------------------------------------------------------------------
  def elapsed_time
    return @model['elapsedTime'].value
  end
  
  #-------------------------------------------------------------------------
  def voltage
    return @model['cell/Vm'].value
  end
  
  #-------------------------------------------------------------------------
  def current
    return @model['cell/current'].value
  end
  
  #-------------------------------------------------------------------------
  def resistance
    return voltage / current
  end
  
  #-------------------------------------------------------------------------
  def conductance
    return 1.0 / resistance
  end
  
  #-------------------------------------------------------------------------
  def clamp_current
    return @model['current clamp/current'].value
  end
  
end
