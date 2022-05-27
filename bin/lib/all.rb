#
# gems
#

require 'rubygems'
require 'bundler/setup'
Bundler.require(:deploy)

#
# patches
#

require_relative 'patches/base'
require_relative 'config'
require_relative 'utils'
require_relative 'cache'
require_relative 'secrets'
require_relative 'instances/linode'
require_relative 'instance'
File
  .dirname(__FILE__)
  .then { |x| File.join(x, 'patches/*.rb') }
  .then { |x| Dir.glob(x) }
  .each { |x| require x }

#
# core extensions
#

def recursive_ostruct(object)
  case object
  when Hash
    hash = {}; object.each { |k, v| hash[k] = recursive_ostruct(v) }
    OpenStruct.new(hash)
  when Array
    object.map { |e| recursive_ostruct(e) }
  else
    object
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class Array
  alias_method :blank?, :empty?

  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

class Hash
  alias_method :blank?, :empty?
end

class Numeric
  def blank?
    false
  end
end

class Time
  def blank?
    false
  end
end

class String
  def blank?
    empty? || /\A[[:space:]]*\z/.match?(self)
  end

  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def titleize
    self.split(" ").map(&:capitalize).join(" ")
  end

  def black
    "\e[30m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def brown
    "\e[33m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
  end

  def gray
    "\e[37m#{self}\e[0m"
  end

  def bg_black
    "\e[40m#{self}\e[0m"
  end

  def bg_red
    "\e[41m#{self}\e[0m"
  end

  def bg_green
    "\e[42m#{self}\e[0m"
  end

  def bg_brown
    "\e[43m#{self}\e[0m"
  end

  def bg_blue
    "\e[44m#{self}\e[0m"
  end

  def bg_magenta
    "\e[45m#{self}\e[0m"
  end

  def bg_cyan
    "\e[46m#{self}\e[0m"
  end

  def bg_gray
    "\e[47m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
  end

  def italic
    "\e[3m#{self}\e[23m"
  end

  def underline
    "\e[4m#{self}\e[24m"
  end

  def blink
    "\e[5m#{self}\e[25m"
  end

  def reverse_color
    "\e[7m#{self}\e[27m"
  end
end
