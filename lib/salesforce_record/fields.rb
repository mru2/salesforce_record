# All the possible salesforce fields
# Responsible for parsing / encoding the values
# Also handle local and remote name, if different

module SalesforceRecord
  module Fields

    # The base class for the fields. No values parsing or encoding
    class BaseField

      attr_reader :local_name

      def initialize(name, opts)
        @local_name = name
        @remote_name = opts[:from]
      end

      # Parse : SF => local
      def parse(value)
        value
      end

      # Encode : local => SF
      def encode(value)
        value
      end

      def remote_name
        @remote_name || @local_name
      end

      def alias?
        !!@remote_name
      end

      # Find the value in a hash, handling nesting and aliases
      def find_value_in(hash)
        value = hash[remote_name] || deep_fetch(hash)

        value.nil? ? nil : parse(value)
      end


      private

      # Helper : fetch the value deep in a hash
      def deep_fetch(hash)
        keys = remote_name.to_s.split('.').map(&:to_sym)
        keys.inject(hash){|subhash, key| subhash.is_a?(Hash) && subhash[key] }
      end
    end


    # A date. YYYY-MM-DD on salesforce
    class DateField < BaseField
      def encode(value)
        value.strftime("%Y-%m-%d")
      end

      def parse(value)
        Date.parse(value)
      end
    end


    # A float
    class FloatField < BaseField
      def parse(value)
        value.to_f
      end
    end


    # An integer
    class IntegerField < BaseField
      def parse(value)
        value.to_i
      end
    end


  end
end