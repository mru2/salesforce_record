# Persisting the model to salesforce
# defines #update_fields and #create methods

require 'salesforce_adapter'

module SalesforceModel
  module Persistence
    
    def self.included(base)
      base.send(:extend, ClassMethods)
    end


    # Pushes new field values to salesforce and updates them locally
    def update_fields(fields)

      update_fields = self.class.encode_attributes(fields).merge({
        :Id   => self.Id,
        :type => self.class.salesforce_table_name.to_s
      })
      
      begin
        self.class.salesforce_adapter.update( self.class.salesforce_table_name, update_fields )
        saved = true
      rescue SalesforceAdapter::SalesforceFailedUpdate => e
        # No check of the error code necessary here
        saved = false
      end

      # Update the fields locally if the request passed
      if saved
        fields.each do |attribute, value|
          self.instance_variable_set(:"@#{attribute}", value)
        end
      end

      return saved
    end



    module ClassMethods

      # Tries to create an instance, given a set of attributes
      def create(attributes)

        fields = encode_attributes(attributes).merge(:type => self.salesforce_table_name.to_s)

        # Tries to create it remotely
        begin
          id = self.salesforce_adapter.create( self.salesforce_table_name, fields )

          # If successful, return an instance with the given Id
          return from_salesforce(fields.merge(:Id => id))

        # TODO : have a real handling of failures
        rescue => e
          puts e.message
          return nil
        end

      end


      def encode_attributes(attributes)
        {}.tap do |encoded_attributes|
          attributes.each do |name, value|
            if (field = self.get_field(name))
              encoded_attributes[name] = field.encode value
            else
              encoded_attributes[name] = value
            end
          end
        end
      end
    end

  end
end
