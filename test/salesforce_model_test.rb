require 'minitest/autorun'
require 'mocha/setup'
require 'salesforce_model'


# The tested model
class TestedModel
  include SalesforceModel
  
  is_salesforce_model :TestedModel

  # sf_adapter -- defined in setup
  sf_attributes :Field1, :Field2
  sf_attribute  :deep_field, :from => 'Parent.Field3'
  sf_attribute  :Timestamp, :type => :date
end


class SalesforceModelTest < MiniTest::Unit::TestCase

  # The mock data
  def setup
    @adapter = mock('a salesforce adapter')
    TestedModel.sf_adapter @adapter

    @salesforce_id = "SALESFORCE_ID_1234"
    @salesforce_fields = {:Id => @salesforce_id, :type => "TestedModel", :Field1 => "value1", :Field2 => "value2", :Parent => {:Field3 => "value3"}, :Timestamp => "2013-03-01"}
  end

  # Initialisation
  def test_initialization

    # It can be initialized with or without attributes
    model = TestedModel.new
    assert_equal nil, model.Field1
    assert_equal nil, model.Field2
    assert_equal nil, model.deep_field

    model = TestedModel.from_salesforce(@salesforce_fields)
    assert_equal "value1", model.Field1
    assert_equal "value2", model.Field2
    assert_equal "value3", model.deep_field

  end

  # Test salesforce parsing / encoding
  def test_salesforce_parsing
    assert_equal ({
      :Id=>"SALESFORCE_ID_1234",
      :Field1=>"value1",
      :Field2=>"value2",
      :deep_field=>"value3",
      :Timestamp => Date.new(2013,3,1)}), TestedModel.parse_salesforce_fields(@salesforce_fields)
  end


  def test_salesforce_encoding
    assert_equal ({:Id=>"sf-id", :Field1=>"value 1", :Timestamp=>"2013-04-14"}), TestedModel.encode_salesforce_fields({:Id => "sf-id", :Field1 => 'value 1', :MissingField => 'a value', :Timestamp => Date.new(2013,4,14), :deep_field => "deep value"})
  end


  # Finders
  def test_find

    # Returns the record matching the id if there is one
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE t.Id='#{@salesforce_id}'").once.returns([@salesforce_fields])
    model = TestedModel.find(@salesforce_id)

    assert model != nil
    assert_equal @salesforce_id,  model.Id
    assert_equal "value1",        model.Field1
    assert_equal "value2",        model.Field2
    assert_equal "value3",        model.deep_field


    # If none found : nil
    bad_id = "BAD_SALESFORCE_ID"
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE t.Id='#{bad_id}'").once.returns([])
    model = TestedModel.find(bad_id)

    assert_nil model

  end


  # Conditional queries
  def test_where

    # Builds the right query for salesforce
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE t.Field1='condition'").once.returns([])
    TestedModel.where(:Field1 => 'condition')

    # Don't escape booleans
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE t.Field2=true").once.returns([])
    TestedModel.where(:Field2 => true)

    # Handle deep fields
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE t.Parent.Field3='condition'").once.returns([])
    TestedModel.where(:deep_field => 'condition')

    # Can be fetched directly a query string
    @adapter.expects(:query).with("Select t.Id, t.Field1, t.Field2, t.Parent.Field3, t.Timestamp from TestedModel t WHERE Field1='value1' ORDER BY Field2 DESC").once.returns([])
    TestedModel.where("Field1='value1' ORDER BY Field2 DESC")

    # Returns an array of records
    @adapter.stubs(:query).returns([
      @salesforce_fields.merge({:Id => "SALESFORCE_ID_1"}),
      @salesforce_fields.merge({:Id => "SALESFORCE_ID_2"}),
      @salesforce_fields.merge({:Id => "SALESFORCE_ID_3"})
    ])
    models = TestedModel.where(:Field1 => 'condition')
    
    assert_equal 3, models.count
    assert_equal ["SALESFORCE_ID_1", "SALESFORCE_ID_2", "SALESFORCE_ID_3"], models.map(&:Id)

  end


  # Fields updating
  def test_update_fields

    # It should update the fields on salesforce and locally
    @adapter.expects(:update).with(:TestedModel, {:type => 'TestedModel', :Id => 'SALESFORCE_ID_1234', :Field1 => 'value1bis'}).once.returns(true)
    model = TestedModel.from_salesforce(@salesforce_fields)

    assert_equal "value1", model.Field1

    response = model.update_fields(:Field1 => "value1bis")

    assert_equal "value1bis", model.Field1
    assert_equal true, response


    # On a failure, nothing should be updated, and it should return false
    @adapter.expects(:update).once.raises(SalesforceAdapter::SalesforceFailedUpdate.new('SALESFORCE_ERROR_CODE', "There was an error updating the table Model with Attributes ... because of error ..."))
    model = TestedModel.from_salesforce(@salesforce_fields)

    assert_equal "value1", model.Field1

    response = model.update_fields(:Field1 => "value1bis")

    assert_equal "value1", model.Field1
    assert_equal false, response

    # It should convert the formatted fields
    @adapter.expects(:update).with(:TestedModel, {:type => 'TestedModel', :Id => 'SALESFORCE_ID_1234', :Timestamp => '2013-09-01'}).once.returns(true)
    model = TestedModel.from_salesforce(@salesforce_fields)

    assert_equal Date.new(2013,3,1), model.Timestamp
    response = model.update_fields(:Timestamp => Date.new(2013,9,1))
    assert_equal true, response
    assert_equal Date.new(2013,9,1), model.Timestamp
  end


  # Resource creation
  def test_create

    # It should create the model on salesforce and return a local instance with it's Id filled
    @adapter.expects(:create).with(:TestedModel, {:type => 'TestedModel', :Field1 => 'value1', :Field2 => 'value2'}).once.returns(@salesforce_id)
    model = TestedModel.create(:Field1 => 'value1', :Field2 => 'value2')

    assert_equal @salesforce_id, model.Id
    assert_equal 'value1', model.Field1
    assert_equal 'value2', model.Field2


    # It should convert the formatted fields
    @adapter.expects(:create).with(:TestedModel, {:type => 'TestedModel', :Timestamp => '2013-09-01'}).once.returns(@salesforce_id)
    model = TestedModel.create(:Timestamp => Date.new(2013,9,1))

    assert_equal @salesforce_id, model.Id
    assert_equal Date.new(2013,9,1), model.Timestamp
    
  end


  # Typed fields
  def test_typed_fields
    model = TestedModel.from_salesforce(@salesforce_fields)
    assert_equal Date.new(2013,3,1), model.Timestamp
  end

end