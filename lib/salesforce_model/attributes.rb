# Attributes handling
# defines #new and #attributes
# also class methods for parsing / encoding attributes hash for salesforce

require 'salesforce_model/fields'

module SalesforceModel
  module Attributes

    def self.included(base)
      base.send(:extend, ClassMethods)

      base.instance_eval do
        # Store the attributes and aliases at the class level
        @salesforce_fields = {} # name  => field instance

        # The base attributes
        sf_attribute :Id, :type => :id
      end
    end


    module ClassMethods

      # The salesforce fields and options
      def salesforce_fields ; @salesforce_fields ; end

      # The attributes for this model
      def salesforce_attributes ; @salesforce_fields.keys ; end

      # Add salesforce attributes to the model
      def sf_attributes(*attrs)
        attrs.each do |attr|
          sf_attribute attr
        end
      end

      # Add a salesforce attribute to the model
      # Possible options : 
      # :from => the remote key to fetch to populate the field
      # :type => one of :date, :float, :integer, :boolean, :id
      def sf_attribute(attribute, opts={})

        case opts[:type]
        when :date
          @salesforce_fields[attribute] = Fields::DateField.new(attribute, opts)
        when :float
          @salesforce_fields[attribute] = Fields::FloatField.new(attribute, opts)
        when :integer
          @salesforce_fields[attribute] = Fields::IntegerField.new(attribute, opts)
        else
          @salesforce_fields[attribute] = Fields::BaseField.new(attribute, opts)
        end

        # Set its accessor
        attr_reader attribute
      end


      # Create an imported record from salesforce
      def from_salesforce(fields)
        new parse_salesforce_fields(fields)
      end

      # Parse fields coming from salesforce
      def parse_salesforce_fields(sf_fields)
        {}.tap do |parsed_fields|
          sf_fields.each do |name, value|
            parsed_field = parse_salesforce_field(name, value) unless value.nil?
            parsed_fields.merge! parsed_field if !parsed_field.nil?
          end
        end
      end

      # Encode fields for salesforce
      def encode_salesforce_fields(fields)
        {}.tap do |encoded_fields|
          fields.each do |name, value|
            encoded_field = encode_salesforce_field(name, value)
            encoded_fields.merge! encoded_field if !encoded_field.nil?
          end
        end
      end

      # Parse a field coming from salesforce (type)
      def parse_salesforce_field(name, value)
        # If existing, parse it depending on type
        if (field = get_field name)
          { field.local_name => field.parse(value) }

        # Else, try to find if it is an alias
        else
          find_matching_alias(name => value)
        end
      end

      # Encode a field from salesforce
      def encode_salesforce_field(name, value)
        # If existing, encode it depending on type and alias
        if (field = get_field name) && (!field.alias?)
          { field.remote_name => field.encode(value) }
        end
      end

      def get_field(name)
        self.salesforce_fields[name]
      end

      def has_field?(name)
        !!get_field(name)
      end

      def field_type(name)
        has_field?(name) && self.salesforce_fields[name].type
      end

      def field_remote_name(name)
        has_field?(name) && self.salesforce_fields[name].remote_name
      end


      # Tries to find a salesforce alias matching a nested hash. Returns the alias name and corresponding value if found
      def find_matching_alias(nested_hash)
        self.salesforce_fields.each do |name, field|
          if (value = field.is_alias_of(nested_hash))
            return parse_salesforce_field(name, value)
          end
        end
        return nil
      end

    end


    # Constructor
    def initialize(attributes = {})
      # Iterate over the salesforce attributes and sets them
      attributes.each do |name, value|
        instance_variable_set :"@#{name}", value
      end
    end


    # The attributes hash : name => parsed value
    def attributes
      Hash[*self.class.salesforce_attributes.map{|attr|[attr, self.send(attr)]}.flatten]
    end



  end
end
