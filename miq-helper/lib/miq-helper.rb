# This class consists of a set of helper methods
# usable inside a ManageIQ or CloudForms Management Engine
# Automation workflow engine
#
# Author:: Dave Costakos (mailto:david.costakos@redhat.com)
# Copyright:: Copyright (c) 2014 Red Hat, Inc.
# License:: GPL

# Generic class wrapper around all basic functions

class MiqHelper

  attr_writer :method
  attr_writer :inspector
  attr_accessor :inspector

  require 'inspect/InspectMe'

  # Default initialization routine

  def initialize(method="MiqHelper")
    @method = method
    @inspector = InspectMe.new(self)
  end

  def logi(msg)
    log(:info, msg, false)
  end

  def log(level, message, update_message=false)
    $evm.log(level, "#{@method} - #{message}")
    get_vmdb_object.message = "#{message}" rescue nil if update_message
  end

  def log_err(err, update_message=false, update_reason=false, finish=false)
    log(:error, "#{err.class} [#{err}]", update_message)
    log(:error, "#{err.backtrace.join("\n")}")
    if update_reason
       $evm.root['ae_result'] = 'error'
       $evm.root['ae_reason'] = "#{err.class} [#{err}]"
    end
    get_vmdb_object.finished("#{err.class} [#{err}]") rescue nil if finish
  end

  # basic retry logic
  def retry_method(retry_time=1.minute)
    log(:info, "Retrying in #{retry_time} seconds")
    $evm.root['ae_result']         = 'retry'
    $evm.root['ae_retry_interval'] = retry_time
    exit MIQ_OK
  end
   
  def to_s()
    return "MiqHelper for #{@method}"
  end

  def get_vmdb_object()
    object = $evm.root["#{$evm.root['vmdb_object_type']}"]
    log(:info, "Got object: #{object.class} #{object}")
    return object
  end

  def get_vm_from_evm_root()
    case $evm.root['vmdb_object_type']
    when 'miq_provision'
      prov = $evm.root['miq_provision']
      log(:info, "Provision:<#{prov.id}> Request:<#{prov.miq_provision_request.id}> Type:<#{prov.type}>")
      vm = prov.vm
      log(:info, "Found VM from provision object: #{vm.inspect}")
      return prov.vm
    when 'vm'
      vm = $evm.root['vm']
      log(:info, "VM: #{vm.inspect}")
      return vm
    else
      log(:info, "Invalid $evm.root['vmdb_object_type']:<#{$evm.root['vmdb_object_type']}>. Skipping method.")
    end
    return nil
  end

  def inspect_me()
    @inspector = InspectMe.new(self)
    @inspector.inspect_me
  end

    # process_tags - Dynamically create categories and tags
  def process_tags( category, category_description, single_value, tag, tag_description )
    # Convert to lower case and replace all non-word characters with underscores
    category_name = category.to_s.downcase.gsub(/\W/, '_')
    tag_name = tag.to_s.downcase.gsub(/\W/, '_')
    log(:info, "Converted category name:<#{category_name}> Converted tag name: <#{tag_name}>")
    # if the category exists else create it
    unless $evm.execute('category_exists?', category_name)
      log(:info, "Category <#{category_name}> doesn't exist, creating category")
      $evm.execute('category_create', :name => category_name, :single_value => single_value, :description => "#{category_description}")
    end
    # if the tag exists else create it
    unless $evm.execute('tag_exists?', category_name, tag_name)
      log(:info, "Adding new tag <#{tag_name}> description <#{tag_description}> in Category <#{category_name}>")
      $evm.execute('tag_create', category_name, :name => tag_name, :description => "#{tag_description}")
    end

    return [ category_name, tag_name ]
  end

  def default_dropdown_setup(hash, sort_by="description", sort_order="ascending", data_type="string", required="true")
    raise "Nil Value Hash Sent to default_dropdown_setup" if hash.nil?
    $evm.object["sort_by"] = sort_by
    $evm.object["sort_order"] = sort_order
    $evm.object["data_type"] = data_type
    $evm.object["required"] = required
    $evm.object["values"] = hash
    log(:info, "Set dropdown has values to #{hash.inspect}")
  end

  def get_aws_object(ext_mgt_system, type="EC2")
    require 'aws-sdk'
    AWS.config(
      :access_key_id => ext_mgt_system.authentication_userid,
      :secret_access_key => ext_mgt_system.authentication_password,
      :region => ext_mgt_system.provider_region
      )
      return Object::const_get("AWS").const_get("#{type}").new()
  end

  def get_fog_object(ext_mgt_system, type="Compute", tenant="admin", auth_token=nil, verify_peer=false)
    require 'fog'
    begin
      return Object::const_get("Fog").const_get("#{type}").new({
        :provider => "OpenStack",
        :openstack_api_key => ext_mgt_system.authentication_password,
        :openstack_username => ext_mgt_system.authentication_userid,
        :openstack_auth_url => "http://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens",
        :openstack_auth_token => auth_token,
        :openstack_tenant => tenant
        })
    rescue => loginerr
      log(:error, "Error logging [#{ext_mgt_system}, #{type}, #{tenant}, #{auth_token rescue "NO TOKEN"}]")
      log_err(loginerr)
    end
    return nil
  end

  def get_vivim(ext_mgt_system)
    begin
      ext_mgt_system.object_send('instance_eval', '
        def get_vivim()
          with_provider_object { |viVim| return viVim }
        end
      ')
      return ext_mgt_system.object_send('get_vivim')
    rescue => vivimerr
      log_err(vivimerr)
    end
    return nil
  end

  def get_vcenter_savon_obj(servername, username, password)
    require 'savon'
    client = Savon.client(
      :wsdl => "https://#{servername}/sdk/vim.wsdl",
      :endpoint => "https://#{servername}/sdk/",
      :ssl_verify_mode => :none,
      :ssl_version => :TLSv1,
      :log_level => :info,
      :log => false,
      :raise_errors => false
    )

    begin
      result = client.call(:login) do 
        message(
          :_this => "SessionManager",
          :userName => username,
          :password => password
          )
      end
      client.globals.headers({"Cookie" => result.http.headers["Set-Cookie"]})
      return client
    rescue => loginerr
      log_err(loginerr)
      return nil
    end
  end

  def vcenter_logout(client)
    require 'savon'
    begin
      client.call(:logout) do
        message(:_this => "SessionManager")
      end
    rescue => logouterr
      log_err(logouterr)
    end
  end

  def filter_tenants_by_provscope(tenant_list, user=nil, group=nil, use_union=false)

    user  = $evm.root['user']  if user.nil?
    group = user.current_group if group.nil?

    group_scope_tags = get_tags_from_obj(group, "prov_scope")
    user_scope_tags  = get_tags_from_obj(user, "prov_scope")

    group_scope_tags = user_scope_tags  if group_scope_tags.nil? || group_scope_tags.length == 0
    user_scope_tags  = group_scope_tags if user_scope_tags.nil?  || user_scope_tags.length == 0

    group_scope_tags = [] if group_scope_tags.nil?
    user_scope_tags  = [] if user_scope_tags.nil?

    log(:info, "Group prov_scope tags: #{group_scope_tags.inspect rescue "nil -- 0 tags"}")
    log(:info, "User prov_scope tags: #{user_scope_tags.inspect rescue "nil -- 0 tags"}")

    if group_scope_tags.length == 0 && user_scope_tags.length == 0
      log(:info, "User and Group are not tagged with prov_scope, returning all tenants")
      return tenant_list
    end

    all_tags = nil
    if use_union
      all_tags = group_scope_tags | user_scope_tags
    else
      all_tags = group_scope_tags & user_scope_tags
    end

    return tenant_list.select { |key, value|
      ems_id = value.ems_id
      ems = $evm.vmdb(:ems_openstack).all.detect {|_ems| _ems.id == ems_id }
      found_tag = false
      all_tags.each { |tag|
        if ems.tagged_with?(tag)
          found_tag = true
          break
        end
      }
      found_tag
    }

  end

  def get_eligible_cloud_tenants(ext_mgt_system=nil, user=nil, group=nil, use_union=false)

    user = $evm.root['user'] if user.nil?
    group = user.current_group if group.nil?

    start_string = $evm.object["tenant_category_name"]
    start_string = "cloud_tenants" if start_string.nil?

    user_tags = get_tags_from_obj(user, start_string)
    log(:info, "User Tenant-related Tags: #{user_tags.inspect}")

    group_tags = get_tags_from_obj(group, start_string)
    log(:info, "Group Tenant-related Tags: #{group_tags.inspect}")

    group_tags = user_tags  if group_tags.nil? || group_tags.length <= 0
    user_tags  = group_tags if user_tags.nil?  || user_tags.length  <= 0

    user_tags  = [] if user_tags.nil?
    group_tags = [] if group_tags.nil?

    all_tags = nil
    if group_tags.length > 0 && user_tags.length > 0
      unless use_union
        all_tags = group_tags & user_tags
      else
        all_tags = group_tags | user_tags
      end
      log(:info, "Intersection of Group and User Tags (these are the tenants available to this user: #{all_tags.inspect}")
    else
      log(:info, "User and Group are not tagged with tenants, allowing access to all tenants for this user")
    end

    eligible_tenants = {}

    $evm.vmdb(:cloud_tenant).all.each { |tenant|

      # if there was a management system specifically assigned,
      # first limit based on this tenant being a member of that
      # system
      if ext_mgt_system
        next unless tenant.ems_id == ext_mgt_system.id
      end

      # next, ensure that the tags assigned to the user and group
      # include the tenant
      if all_tags
        next unless all_tags.include?("#{start_string}/#{tenant.name}")
      end
ex
      log(:info, "Tenant #{tenant.name} is in the tag list and on the selected system")

      if ext_mgt_system
        eligible_tenants["#{tenant.name}"] = tenant
      else
        all_systems = $evm.vmdb(:ems_openstack).all
        unless all_systems.length == 1
          mgt_system = $evm.vmdb(:ems_openstack).all.detect { |system| system.id == tenant.ems_id }
          eligible_tenants["#{tenant.name} on #{mgt_system.name}"] = tenant
          log(:info, "Added #{tenant.name} on #{mgt_system.name} to list")
        else
          eligible_tenants["#{tenant.name}"] = tenant
          log(:info, "Added #{tenant.name} as there is only 1 EMS")
        end
      end

    }

    log(:info, "Returning #{eligible_tenants.inspect}")
    return eligible_tenants

  end

  private
    def get_tags_from_obj(obj, match_string)
    return obj.tags.select {
      |tag| tag.to_s.starts_with?("#{match_string}")
    }
    end

end
