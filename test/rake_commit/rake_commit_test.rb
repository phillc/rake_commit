require File.dirname(__FILE__) + "/../test_helper"

class RakeCommitTest < Test::Unit::TestCase  
  def test_it_is_ok_to_check_in_when_CCRB_RSS_not_defined
    assert_equal false, RakeCommit.const_defined?(:CCRB_RSS)
    assert_equal true, RakeCommit.ok_to_check_in?
  end
  
  def test_ok_to_check_in_when_CCRB_RSS_is_defined_and_build_is_failing_and_not_sure
    RakeCommit.const_set(:CCRB_RSS, "http://some_url/")
    RakeCommit.expects(:are_you_sure?).returns(false)
    cruise_status = stub
    cruise_status.expects(:pass?).returns(false)
    cruise_status.expects(:failures).returns([])
    CruiseStatus.stubs(:new).returns(cruise_status)
    assert_equal false, RakeCommit.ok_to_check_in?
  ensure
    RakeCommit.send(:remove_const, :CCRB_RSS) if RakeCommit.const_defined?(:CCRB_RSS)
  end
  
  def test_ok_to_check_in_when_CCRB_RSS_is_defined_and_build_is_failing_and_sure
    RakeCommit.const_set(:CCRB_RSS, "http://some_url/")
    RakeCommit.expects(:are_you_sure?).returns(true)
    cruise_status = stub
    cruise_status.expects(:pass?).returns(false)
    cruise_status.expects(:failures).returns([])
    CruiseStatus.stubs(:new).returns(cruise_status)
    assert_equal true, RakeCommit.ok_to_check_in?
  ensure
    RakeCommit.send(:remove_const, :CCRB_RSS) if RakeCommit.const_defined?(:CCRB_RSS)
  end
  
  def test_ok_to_check_in_when_CCRB_RSS_is_defined_and_build_is_passing
    RakeCommit.const_set(:CCRB_RSS, "http://some_url/")
    RakeCommit.expects(:are_you_sure?).returns(true)
    cruise_status = stub
    cruise_status.expects(:pass?).returns(false)
    cruise_status.expects(:failures).returns([])
    CruiseStatus.stubs(:new).returns(cruise_status)
    assert_equal true, RakeCommit.ok_to_check_in?
  ensure
    RakeCommit.send(:remove_const, :CCRB_RSS) if RakeCommit.const_defined?(:CCRB_RSS)
  end
end