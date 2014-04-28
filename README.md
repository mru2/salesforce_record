# SalesforceModel

ActiveRecord-like mixin for querying, fetching and updating Salesforce models

## Installation

Add this line to your application's Gemfile:

    gem 'salesforce_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install salesforce_model

## Usage

```
require 'salesforce_adapter'
require 'salesforce_model'

$salesforce = SalesforceAdapter::Base.new(
  :url        => 'https://test.salesforce.com/services/Soap/u/16.0',
  :login      => 'your_salesforce_login',
  :password   => 'your_salesforce_password'
)

class MyLeadModel
  include SalesforceModel

  is_salesforce_model :Lead
  sf_adapter          $salesforce
  sf_attributes       :Company, :FirstName, :LastName
end

# Finders
> lead = MyLeadModel.find('00Qg000000ORDER66')
=> #<MyLeadModel:0x007fe47983b700 @Id="00Qg000000ORDER66", @Company="JEDI inc", @FirstName="Mace", @LastName="Windu">

# Attribute getters
> lead.Company
=> "JEDI inc"

# Remote setters
> lead.update_fields(:Company => 'One-arm support group')
=> true

# Record creation
> new_lead = MyLeadModel.create(:LastName => 'Binks', :FirstName => 'Jar-Jar', :Company => 'Lobby for a new Autocracy')
=> #<MyLeadModel:0x007fe4798e1970 @Id="00Qg0000002DUMBASS", @Company="Unwilling Dictatorship Lobby", @FirstName="Jar-Jar", @LastName="Binks">

# Queries
> results = MyLeadModel.where(:LastName => 'Windu')
=> [#<MyLeadModel:0x007fe47991bee0 @Id="00Qg000000ORDER66", @Company="One-arm support group", @FirstName="Mace", @LastName="Windu">]
```


## Contributing

1. Fork it ( http://github.com/<my-github-username>/salesforce_model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
