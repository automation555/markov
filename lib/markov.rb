$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'markov/core_ext'

class Markov
  private
  attr_accessor :data
  
  public
  def initialize
    @data = {}
  end
  
  def reset
    @data = {}
  end
  
  def add(*items)
    raise ArgumentError, 'at least one argument required' if items.empty?
    items.each { |item|  data[item] ||= [] }
    items[0..-2].zip(items[1..-1]).each { |a, b|  data[a].push(b) }
  end
  
  def generate(length = 1.0/0)
    result = []
    items  = data.keys
    while !items.empty? and result.length < length
      item = items.random
      result.push item
      items = data[item]
    end
    result
  end
end
