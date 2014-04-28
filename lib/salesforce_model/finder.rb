# Finder methods
# defines #find and #where

module SalesforceModel
  module Finder

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

      # Returns the object matching a salesforce id
      def find(id)
        where(:Id => id).first
      end


      # Returns a list of object matching a specific query
      def where(query)

        # Build the matching query string
        query_string = query_string(query)

        # Run the query and get the results (always an array)
        sf_results = salesforce_adapter.query(query_string)

        # Create new objets with the results and return them
        sf_results.map{|sf_attributes| from_salesforce(sf_attributes)}

      end


      # Creates an soql query for the resource. The query matchers are the argument
      def query_string(query)

        # The first letter of the model used
        # i.e : Lead => l
        # Used in the query : Select l.Type_de_paiement__c from Lead l where Id='id-goes-here'
        key = 

        # Build the base query : select all the attributes in the model table (except "type" : returned but should not be queried)
        query_string = "Select "
        query_string << (salesforce_attributes - [:type]).map{|attribute| remote_attribute_name(attribute)}.join(", ")
        query_string << " from #{salesforce_table_name} #{salesforce_query_key}"

        # Add the selectors
        if query.is_a? String
          soql_selector = query
        else
          soql_selector = query.map{|attribute, value| format_where_clause(attribute, value)}.join(' AND ')
        end
        
        query_string << " WHERE #{soql_selector}"

        query_string

      end

      
      # The key used to namespace the salesforce queries : first character of the table name
      # i.e : Lead => l
      # Used in : Select l.Type_de_paiement__c from Lead l where Id='id-goes-here'        
      def salesforce_query_key
        self.salesforce_table_name.to_s[0, 1].downcase
      end

      # Aliases : the remote name for an attribute
      def remote_attribute_name(attribute)
        if (field = self.get_field attribute)
          name_without_alias = field.remote_name
        else
          name_without_alias = attribute
        end
        "#{salesforce_query_key}.#{name_without_alias}"
      end



      # Create the query string for an attribute/value pair
      # Returns something along the lines of "key.attribute='value'", to be injected in a WHERE clause
      def format_where_clause(attribute, value)
        q = "#{remote_attribute_name(attribute)}=" #exact match

        # No escaping boolean values
        if value.is_a?(TrueClass) || value.is_a?(FalseClass)
          q << value.to_s
        elsif value.is_a? Date
          q << value.strftime("%Y-%m-%d")
        elsif value.nil?
          q << "NULL"
        else
          q << "'#{value}'"
        end

        q
      end
    end

  end
end
