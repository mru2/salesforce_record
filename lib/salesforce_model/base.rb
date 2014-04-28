# Base dependencies for the salesforce models
# Handles the attribute list, the salesforce adapter, ...

module SalesforceModel
  module Base

    # Bulding the class
    def self.included(base)
      base.send(:extend, ClassMethods)

      base.instance_eval do
        @salesforce_table_name = nil
        @salesforce_adapter    = nil
      end
    end


    module ClassMethods

      # Defines the salesforce table name
      def is_salesforce_model(table_name)
        @salesforce_table_name  = table_name
      end
      def salesforce_table_name ; @salesforce_table_name ; end


      # Defines the salesforce adapter
      def sf_adapter(adapter)
        @salesforce_adapter = adapter
      end
      def salesforce_adapter    ; @salesforce_adapter    ; end

    end

  end
end