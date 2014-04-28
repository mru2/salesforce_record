# All the possible salesforce fields
# Responsible for parsing / encoding the values
# Also handle local and remote name, if different

module SalesforceModel
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

      # Check if matching nested hash
      def is_alias_of(nested_hash)
        return false unless @remote_name
        deep_fetch(nested_hash, remote_name.split('.').map(&:to_sym))
      end

      private

      # Helper : fetch deep value from a hash
      def deep_fetch(hash, keys)
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