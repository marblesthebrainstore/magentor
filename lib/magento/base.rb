# Base Magento model handles basic crud operations and stores connection to magento instance.
# It has the following class attributes:
#
# * <tt>connection</tt>: the Magento::Connection to use
# 
# And the following instance attributes:
# * <tt>attributes</tt>: the attributes of the magento object
#
module Magento
  class Base
    attr_accessor :attributes
    class << self; attr_accessor :connection end
    
    module ClassMethods
      # Uses the classes name and method to make an rpc call through connection
      def commit(method, *args)
        method = "#{to_s.split('::').last.underscore.downcase}.#{method}"
        Magento::Base.connection.call(method, *args)
      end
      
      def first
        # return nil unless respond_to?(:list)
        #         n = 0
        #         while list(n)[0] == nil
        #           n+=1
        #         end
        #         return list(n)[0]
      end
      
      def list(*args)
        commit("list", *args)
      end

      def create(*args)
        commit("create", *args)
      end
      
      def info(*args)
        commit("info", *args)
      end
      
      def update(*args)
        commit("update", *args)
      end
      
      def delete(*args)
        commit("delete", *args)
      end
      
      def find(*args)
        attrs = info(*args)
        new(attrs)
      end
    end
    
    module InstanceMethods
      def initialize(attributes = {})
        @attributes = attributes.dup
      end

      def object_attributes=(new_attributes)
        return if new_attributes.nil?
        attributes = new_attributes.dup
        attributes.stringify_keys!
        attributes.each do |k, v|
          send(k + "=", v)
        end
      end

      def method_missing(method, *args)
        return nil unless @attributes
        @attributes[method.to_s]
      end
    end
    
    include InstanceMethods
    extend ClassMethods
  end
end