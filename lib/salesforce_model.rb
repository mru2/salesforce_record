# Module allowing a class to wrap a salesforce object
# Define accessors and finder methods

# Usage :
# class Lead
#   is_salesforce_model :Lead
#   include SalesforceModel
#   sf_adapter    salesforce_adapter
#   sf_attributes :ConvertedAccountId, :Street
#   sf_attribute  :owner_email,             :from => 'Owner.Email'
#   sf_attribute  :Date_saisie_CB__c,       :type => :date
# end
# 
# lead = Lead.find('my_lead_id', rforce_salesforce_adapter)
# lead.owner_email # => "my@email.tld"

require 'salesforce_model/version'

require 'salesforce_model/base'
require 'salesforce_model/attributes'
require 'salesforce_model/finder'
require 'salesforce_model/persistence'

module SalesforceModel

  def self.included(base)
    # Include dependencies
    base.send :include, SalesforceModel::Base
    base.send :include, SalesforceModel::Attributes
    base.send :include, SalesforceModel::Finder
    base.send :include, SalesforceModel::Persistence
  end

end
