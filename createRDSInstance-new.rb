require 'miq-helper'

begin

  @task = nil
  @service = nil

  # Get the AWS Management System from teh various options available
  def get_mgt_system()
    aws_mgt = nil
    if @task
      if @task.get_option(:mid)
        aws_mgt = $evm.vmdb(:ems_amazon).find_by_id(@task.get_option(:mid))
        MiqHlp.log(:info, "Got AWS Mgt System from @task.get_option(:mid)")
      end
    elsif $evm.root['vm']
      vm = $evm.root['vm']
      aws_mgt = vm.ext_management_system
      MiqHlp.log(:info, "Got AWS Mgt System from VM #{vm.name}")
    else
      aws_mgt = $evm.vmdb(:ems_amazon).first
      MiqHlp.log(:info, "Got First Available AWS Mgt System from VMDB")
    end
    return aws_mgt
  end

  # Get the Relevant RDS Options from the available
  # Service Template Provisioning Task Options
  def get_rds_options_hash()
    options_regex = /^rds_(.*)/
    options_hash = {}
    @task.options.each {|key, value|
      if options_regex =~ key
        newkey = "#{key}"
        newkey.sub! "rds_", ""
        integer_regex = /^\d+$/
        options_hash[:"#{newkey}"] = value
        options_hash[:"#{newkey}"] = value.to_i if integer_regex =~ value
        MiqHlp.log(:info, "Set :#{newkey} => #{value}")
      end
    }
    MiqHlp.log(:info, "Returning Options Hash: #{options_hash.inspect}")
    return options_hash
  end

  # BEGIN MAIN #
  MiqHlp.log(:info, "Begin Automate Method")

  MiqHlp.dump_root
 
  # Get the task object from root
  @task = $evm.root['service_template_provision_task']
  if @task
    # List Service Task Attributes
    MiqHlp.dump_attributes('service_template_provision_task', @task)
    # Get destination service object
    @service = @task.destination
    MiqHlp.log(:info,"Detected Service:<#{@service.name}> Id:<#{@service.id}>")
  end

  # get the AWS Management System Object
  aws_mgt = get_mgt_system
  MiqHlp.log(:info, "AWS Mgt System is #{aws_mgt.inspect}")


  # Get an RDS Client Object via the AWS SDK
  client = MiqHlp.get_aws_object(aws_mgt, "RDS").client 
  MiqHlp.log(:info, "Got AWS-SDK RDS Client: #{client.inspect}")

  # Get the relevant RDS Options hash from the provisioning task
  # these will be passed unchanged to create_db_instance.  It is up to
  # the catalog item initialization to validate and process these into
  # options on the task item
  options_hash = get_rds_options_hash
  MiqHlp.log(:info, "Creating RDS Instace with options: #{options_hash.inspect}")
  db_instance = client.create_db_instance(options_hash)
  MiqHlp.log(:info, "DB Instance Created: #{db_instance.inspect}")
  
  # The instance is now in creating state, set some attributes on the service object
  @service.custom_set("rds_db_instance_identifier", db_instance[:db_instance_identifier])
  @service.custom_set("rds_preferred_backup_window", db_instance[:preferred_backup_window])
  @service.custom_set("rds_engine", "#{db_instance[:engine]} #{db_instance[:engine_version]}")
  @service.custom_set("rds_db_instance_class", db_instance[:db_instance_class])
  @service.custom_set("rds_publicly_accessible", db_instance[:publicly_accessible].to_s)
  @service.custom_set("MID", "#{aws_mgt.id}")

  # Make sure these options are available so they can be used for notification later
  # (if needed)
  @task.set_option(:rds_engine_version, db_instance[:engine_version])
  @task.set_option(:rds_engine, db_instance[:engine])

  # End this automate method
  MiqHlp.log(:info, "End Automate Method")

  # END MAIN #

rescue => err
  require 'miq-helper'
  MiqHlp.log_err(err, true, true))
  @service.remove_from_vmdb if @service && @task && @task.get_option(:remove_from_vmdb_on_fail)
  exit MIQ_ABORT
end
