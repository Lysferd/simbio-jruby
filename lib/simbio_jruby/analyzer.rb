#==============================================================================
#  Analyzer Class
#  --------------
# An analyzer is an object that is called upon every calculation frame in the
# conductor. Thus, it is capable of tracking variable changes and outputting it
# as desired. Is this, however, better performed by the internal javaclass in
# the SimBio source code?
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

require 'fileutils'

class MyAnalyzer < SimBio::Core::Analyzer
  include Verbose
  
  OUTPUT_FOLDER = 'out/'
  TAB           = ?,
  NEWL          = ?\n
  
  attr_reader :data
  
  #-------------------------------------------------------------------------
  # * Object Initialization
  #
  # @path    : custom folder path for output
  # @name    : output filename (usually parameter name)
  # @model   : reference to model
  # @pattern : path to node
  # @sizes   : number of cells to substitute in the pattern string
  #-------------------------------------------------------------------------
  def initialize path, filename, model, pattern, sizes
    super()
    
    @path    = path
    @name    = filename
    @model   = model
    @pattern = pattern
    @sizes   = sizes
    @last_t  = nil
    
    check_paths
    
    verbose "Analyzers for #{@name} (#{@sizes.reduce(:*)} elements) initialized."
  end
  
  #-------------------------------------------------------------------------
  # * Evaluate Instantaneous Parameter Value
  #-------------------------------------------------------------------------
  def analyze t
    # skip if time change is below an unitary value
    if @last_t.nil? or @last_t < t.truncate
      @last_t = t.truncate
      
      # open output file:
      file = File::open output_file, ?a
      
      # output time:
      file << @last_t
      
      case @sizes.length
      when 1
        rows = @sizes[0]
        
        for i in 1..rows
          next if @pattern =~ /junction/ and i == rows
          ref = @pattern.gsub( /#number|#next/, '#number' => i, '#next' => i + 1 )
          file << TAB << @model[ref].value
        end
      
      when 2
        rows, columns = *@sizes
        
        for i in 1..rows
          for j in 1..columns
            number      = '%dx%d' % [ i, j ]
            next_row    = '%dx%d' % [ i + 1, j ]
            next_column = '%dx%d' % [ i, j + 1 ]

            if @pattern =~ /junction/
              ref = @pattern.gsub( /#number|#next/, '#number' => number, '#next' => next_column ) unless j == columns
              file << TAB << @model[ref].value
              ref = @pattern.gsub( /#number|#next/, '#number' => number, '#next' => next_row ) unless i == rows
              file << TAB << @model[ref].value
            else
              ref = @pattern.gsub( /#number/, '#number' => number )
              file << TAB << @model[ref].value
            end
          end
        end
      
      when 3
        rows, columns, depth = *@sizes
        
        for i in 1..rows
          for j in 1..columns
            for k in 1..depth
              number      = '%dx%dx%d' % [ i, j, k ]
              next_row    = '%dx%dx%d' % [ i + 1, j, k ]
              next_column = '%dx%dx%d' % [ i, j + 1, k ]
              next_depth  = '%dx%dx%d' % [ i, j, k + 1 ]

              if @pattern =~ /junction/
                ref = @pattern.gsub( /#number|#next/, '#number' => number, '#next' => next_column ) unless j == columns
                file << TAB << @model[ref].value
                ref = @pattern.gsub( /#number|#next/, '#number' => number, '#next' => next_row ) unless i == rows
                file << TAB << @model[ref].value
                ref = @pattern.gsub( /#number|#next/, '#number' => number, '#next' => next_depth ) unless k == depth
                file << TAB << @model[ref].value
              else
                ref = @pattern.gsub( /#number/, '#number' => number )
                file << TAB << @model[ref].value
              end
            end
          end
        end
      end
      
      file << NEWL
      file.close
    end
  end

  #-------------------------------------------------------------------------
  # * Data Output Filename
  #-------------------------------------------------------------------------
  def output_file
    return output_path + @name + '.csv'
  end

  #-------------------------------------------------------------------------
  # * Data Output Path
  #-------------------------------------------------------------------------
  def output_path
    return OUTPUT_FOLDER + @path
  end
  
  #-------------------------------------------------------------------------
  # * Define Output Path
  #-------------------------------------------------------------------------
  def check_paths
    FileUtils.mkpath output_path unless FileTest::exist? output_path
  end
  
  #-------------------------------------------------------------------------
  # Deprecated: output now occurs during calculation
  #-------------------------------------------------------------------------
  def output
    check_paths
    
    File::open output_file, ?w do |file|
      for time in @data.first.keys
        file << time
        for data in @data
          file << TAB << data[time]
        end
        file << NEWL
      end
    end
    
    verbose "Data for #{@name} output done at #{output_file}"
  end
end

