require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
require "byebug"

class SQLObject
  def self.columns
    if !@columns.nil?
      return @columns
    end 
   @columns = DBConnection.execute2(<<-SQL)
   SELECT
    *
   FROM 
    "#{self.table_name}"
   SQL
   @columns = @columns.first.map(&:to_sym) 
  end

  def self.finalize!
    self.columns.each do |column|
      define_method("#{column}=") do |val| 
          self.attributes[column.to_sym] = val  
      end 
      define_method(column) do 
        self.attributes[column.to_sym]
      end     
    end 
  end

  def self.table_name=(table_name)
    # ...
  end

  def self.table_name
    self.name.downcase + "s"
  end

  def self.all
    b = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    parse_all(b) 
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }        
  end

  def self.find(id) #return obj given an id
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    WHERE
      #{table_name}.id = ? 
    SQL
  parse_all(results).first   
  end

  def initialize(params = {})
    params.each do |k,v|
      k = k.to_sym 
      # debugger 
      raise "unknown attribute '#{k}'" if !self.class.columns.include?(k) 
        # debugger 
        self.send("#{k}=", v)   
    end  
  end

  def attributes
    @attributes ||= {} 
    @attributes
  end

  def attribute_values
    @attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
