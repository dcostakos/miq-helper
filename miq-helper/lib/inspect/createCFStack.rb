 
begin

  @task = nil
  @service = nil

  # Simple logging method
  def log(level, msg, update_message=false)
    $evm.log(level, msg)
    @task.message = msg if update_message && @task
  end

  # Error logging convenience
  def log_err(err, update_message=false, update_reason=false)
    log(:error, "#{err.class} #{err}")
    log(:error, "#{err.backtrace.join("\n")}")
    @task.message = "#{err.class} #{err}" if update_message && @task
    $evm.root['ae_reason'] = "#{err.class} #{err}" if update_reason
    $evm.root['ae_status'] = 'error' if update_reason
  end

  # standard dump of $evm.root
  def dump_root()
    log(:info, "Root:<$evm.root> Begin $evm.root.attributes")
    $evm.root.attributes.sort.each { |k, v| log(:info, "Root:<$evm.root> Attribute - #{k}: #{v}")}
    log(:info, "Root:<$evm.root> End $evm.root.attributes")
    log(:info, "")
  end

  # convenience method to get an AWS::RDS Object using
  # the AWS EVM Management System
  def get_cf_from_management_system(ext_management_system)
    AWS.config(
      :access_key_id => ext_management_system.authentication_userid,
      :secret_access_key => ext_management_system.authentication_password,
      :region => ext_management_system.name
    )
    return AWS::CloudFormation.new()
  end

  # Get the AWS Management System from teh various options available
  def get_mgt_system()
    aws_mgt = nil
    if @task
      if @task.get_option(:mid)
        aws_mgt = $evm.vmdb(:ems_amazon).find_by_id(@task.get_option(:mid))
        log(:info, "Got AWS Mgt System from @task.get_option(:mid)")
      end
    elsif $evm.root['vm']
      vm = $evm.root['vm']
      aws_mgt = vm.ext_management_system
      log(:info, "Got AWS Mgt System from VM #{vm.name}")
    else
      aws_mgt = $evm.vmdb(:ems_amazon).first
      log(:info, "Got First Available AWS Mgt System from VMDB")
    end
    return aws_mgt
  end

  # Get the Relevant RDS Options from the available
  # Service Template Provisioning Task Options
  def get_cf_options_hash()
    options_regex = /^rds_(.*)/
    options_hash = {}
    @task.options.each {|key, value|
      if options_regex =~ key
        newkey = "#{key}"
        newkey.sub! "cf_", ""
        integer_regex = /^\d+$/
        options_hash[:"#{newkey}"] = value
        options_hash[:"#{newkey}"] = value.to_i if integer_regex =~ value
        log(:info, "Set :#{newkey} => #{value}")
      end
    }
    log(:info, "Returning Options Hash: #{options_hash.inspect}")
    return options_hash
  end

  # BEGIN MAIN #

  log(:info, "Begin Automate Method")

  dump_root
 
  # Get the task object from root
  @task = $evm.root['service_template_provision_task']
  if @task
    # List Service Task Attributes
    @task.attributes.sort.each { |k, v| log(:info, "#{@method} - Task:<#{@task}> Attributes - #{k}: #{v}")}

    # Get destination service object
    @service = @task.destination
    log(:info,"Detected Service:<#{@service.name}> Id:<#{@service.id}>")
  end

  require 'aws-sdk'

  # get the AWS Management System Object
  aws_mgt = get_mgt_system
  log(:info, "AWS Mgt System is #{aws_mgt.inspect}")

  cf = get_cf_from_management_system(aws_mgt)
  log(:info, "Got AWS CloudFormation instance: #{cf.inspect}")

  options_hash = get_cf_options_hash
  log(:info, "Got CloudFormation options: #{options_hash.inspect}")

  raise "Just Testing"


rescue => err
  log_err(err, true, true)
  @service.remove_from_vmdb if @service && @task && @task.get_option(:remove_from_vmdb_on_fail)
  exit MIQ_ABORT
end