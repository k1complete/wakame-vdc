# encoding: utf-8
begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end 
require 'cucumber/formatter/unicode'

require 'rubygems'
require 'httparty'
#require 'step_helpers'
#require File.dirname(__FILE__) + "/step_helpers.rb"

#include RetryHelper
#include InstanceHelper

Before do
end

After do
end

def initiate_api_call_results
  @api_call_results = {
    "create" => {},
    "update" => {},
    "delete" => {},
    "get"    => {}
  }
end

def evaluate_argument arg
  result = arg.dup
  while not (registry_id = result[/<registry:([^>]+)>/, 1]).nil?
    @registry.has_key?(registry_id).should be_true
    result[/<registry:[^>]+>/] = @registry[registry_id]
  end
  result
end

Given /^(.+) exists in (.+)$/ do |uuid, suffix|
  APITest.get("/#{suffix}/#{uuid}").success?.should be_true
end

When /^we make an api (create|update|delete|get) call to (.+) with no options$/ do |call,arg_suffix|
  suffix = evaluate_argument(arg_suffix)

  initiate_api_call_results if @api_call_results.nil?
  @api_last_result = APITest.send(call,"/#{suffix}",{})
  @api_call_results[call][suffix] = @api_last_result
end

When /^we make an api (create|update|delete|get) call to (.+) with the following options$/ do |call,arg_suffix,options |
  suffix = evaluate_argument(arg_suffix)

  initiate_api_call_results if @api_call_results.nil?
  @api_last_result = APITest.send(call,"/#{suffix}",options.hashes.first)
  @api_call_results[call][suffix] = @api_last_result
end

Then /^from the previous api call save to registry (.+) the value for key (.+)$/ do |registry,key|
  @registry = {} if @registry.nil?
  @registry[registry] = @api_last_result[key]
end

Then /^the previous api call (should|should\snot) be successful$/ do |outcome|
  case outcome
    when "should"
      @api_last_result.success?.should == true
    when "should not"
      @api_last_result.success?.should == false
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

Then /^the (create|update|delete|get) call to the (.*) api (should|should\snot) be successful$/ do |call,arg_suffix,outcome|
  suffix = evaluate_argument(arg_suffix)

  case outcome
    when "should"
      @api_call_results[call][suffix].success?.should == true
    when "should not"
      @api_call_results[call][suffix].success?.should == false
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

# This test currently does not verify the correct type, e.g. strings
# and integers can both match an integer.
Then /^the previous api call (should|should\snot) have the key (.+) with (.+)$/ do |outcome,key,arg_value|
  value = evaluate_argument(arg_value)

  case outcome
    when "should"
      @api_last_result[key].to_s.should == value
    when "should\snot"
      @api_last_result[key].to_s.should_not == value
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

Then /^for (create|update|delete|get) on (.+) there (should|should\snot) be the key (.+) with (.+)$/ do |call,arg_suffix,outcome,key,arg_value|
  suffix = evaluate_argument(arg_suffix)
  value = evaluate_argument(arg_value)

  case outcome
    when "should"
      @api_call_results[call][suffix][key].to_s.should == value
    when "should\snot"
      @api_call_results[call][suffix][key].to_s.should_not == value
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

Then /^the previous api call results (should|should\snot) contain the key (.+) with (.+)$/ do |outcome,key,arg_value|
  value = evaluate_argument(arg_value)

  case outcome
    when "should"
      @api_last_result.first["results"].find { |itr|
         itr[key].to_s == value
      }.nil?.should == false
    when "should not"
      @api_last_result.first["results"].find { |itr|
         itr[key].to_s == value
      }.nil?.should == true
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

Then /^for (create|update|delete|get) on (.+) the results (should|should\snot) contain the key (.+) with (.+)$/ do |call,arg_suffix,outcome,key,arg_value|
  suffix = evaluate_argument(arg_suffix)
  value = evaluate_argument(arg_value)

  case outcome
    when "should"
      @api_call_results[call][suffix].first["results"].find { |itr|
         itr[key].to_s == value
      }.nil?.should == false
    when "should not"
      @api_call_results[call][suffix].first["results"].find { |itr|
         itr[key].to_s == value
      }.nil?.should == true
    else
      raise "Illegal outcome in .feature file: '#{outcome}'. Legal outcomes are 'should' and 'should not'"
  end
end

Then /^the created (.+) should reach state (.+) in (\d+) seconds or less$/ do |suffix,state,seconds|
  retry_until(seconds.to_f) do
    APITest.get("/#{suffix}/#{@api_call_results["create"][suffix]["id"]}")["state"] == state
  end
end