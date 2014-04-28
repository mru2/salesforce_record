# Module allowing a class to wrap a salesforce object
# Define accessors and finder methods

# Usage :
# class Lead
#   is_salesforce_model :Lead
#   include SalesforceRecord
#   sf_adapter    salesforce_adapter
#   sf_attributes :ConvertedAccountId, :Street
#   sf_attribute  :owner_email,             :from => 'Owner.Email'
#   sf_attribute  :Date_saisie_CB__c,       :type => :date
# end
# 
# lead = Lead.find('my_lead_id', rforce_salesforce_adapter)
# lead.owner_email # => "my@email.tld"

require 'salesforce_record/version'

require 'salesforce_record/base'
require 'salesforce_record/attributes'
require 'salesforce_record/finder'
require 'salesforce_record/persistence'

module SalesforceRecord

  def self.included(base)
    # Include dependencies
    base.send :include, SalesforceRecord::Base
    base.send :include, SalesforceRecord::Attributes
    base.send :include, SalesforceRecord::Finder
    base.send :include, SalesforceRecord::Persistence
  end

end
