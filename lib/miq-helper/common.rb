
class MiqHlp
  module Common

    # Log a message with using $evm.log and update vmdb_object property
    # message if requested with the same note
    #
    #@example Simple caill to log
    #   MiqHlp.log(:info, "This is a message")
    #
    #@example Example basic call to log but also update the service_template_provision_task message
    #   MiqHlp.log(:info, "Waiting for VM to Become Available", true)
    #
    #@param [String] The level at which to log ie :info, :debug, :warn
    #@param [String] The message to log
    #@param [Boolean] Should I also update message property? (default false)
    def log(level, message, update_message=false)
      $evm.log(level, "#{caller[0]} - #{message}")
      get_vmdb_object.message = "#{message}" rescue nil if update_message
    end

    # Useful wrapper around #log to log error messages in a standard way
    #
    # @example
    #    MiqHlp.log_err(exception)
    #
    # @example
    #    MiqHlp.log_err(exception, true, true, true)
    #
    # @param [StandardError] The error to log
    # @param [Boolean] Should I update object message property?
    # @param [Boolean] Should I update $evm.root['ae_reason']?
    # @param [Boolean] Should I also call finish on the vmdb object?
    def log_err(err, update_message=false, update_reason=false, finish=false)
      log(:error, "#{err.class} [#{err}]", update_message)
      log(:error, "#{err.backtrace.join("\n")}")
      if update_reason
        $evm.root['ae_result'] = 'error'
        $evm.root['ae_reason'] = "#{err.class} [#{err}]"
      end
      get_vmdb_object.finished("#{err.class} [#{err}]") rescue nil if finish
    end

    # Standard retry method logic
    #
    # @example
    #    MiqHlp.retry_method
    #
    # @example
    #    MiqHlp.retry_method("15.seconds")
    #
    # @param [String] The amount of time to sleep after retry
    def retry_method(retry_time=1.minute)
      log(:info, "Retrying in #{retry_time} seconds")
      $evm.root['ae_result']         = 'retry'
      $evm.root['ae_retry_interval'] = retry_time
      exit MIQ_OK
    end
    
    # Get a VMDB Object from $evm.root
    #
    # @example
    #    miq_prov = MiqHlp.get_vmdb_object()
    #
    # @return Drbd::Object
    def get_vmdb_object()
      object = $evm.root["#{$evm.root['vmdb_object_type']}"]
      log(:info, "Got object: #{object.class} #{object}")
      return object
    end

   
    # convenience method to get a VM objet from $evm.root
    #
    # @example
    #    vm = MiqHlp.get_vm_from_evm_root
    # @return [VM]
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
        log(:error, "Invalid $evm.root['vmdb_object_type']:<#{$evm.root['vmdb_object_type']}>. Skipping method.")
      end
      return nil
    end
    
    #
    # Method to create a new tag
    #
    # @example
    #    tag_info = process_tags("new_category", "My New Category", false, "new_value", "My New Value")
    #    vm.tag_assign("#{tag_info.first}/#{tag_info.last")
    # @param [String] The short category name for the tag
    # @param [String] The long human-readable category description for the tag
    # @param [Boolean] Whether the category is single value cateogry or may support multiple values
    # @param [String] The short tag name for the value of this tag
    # @param [String] The long human readable tag value
    # @return [Array] An array containing the normalized short category and tag name
    def process_tags( category, category_description, single_value, tag, tag_description )
      # Convert to lower case and replace all non-word characters with underscores
      category_name = category.to_s.downcase.gsub(/\W/, '_')
      tag_name = tag.to_s.downcase.gsub(/\W/, '_')
      tag_name = tag_name.gsub(/:/, '_')
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

    # Convenience method for setting up default dropdown list
    #
    # @example
    #    default_dropdown_setup(value_hash)
    #
    # @param [Hash] The id/value set of key/value pairs for the dynamic dropdown list
    # @param [String] The field to sort the hash by (default is "description")
    # @param [String] The sort order (ascending[default] or descending)
    # @param [String] data_type of the hash values, default is string
    # @param [String] whether the value is required to be set in the dialog (defaults to true)
    # @param [Object] the default value for the array
    def default_dropdown_setup(hash, sort_by="description", sort_order="ascending", data_type="string", required="true", default_value=nil)
      raise "Nil Value Hash Sent to default_dropdown_setup" if hash.nil?
      $evm.object["sort_by"]       = sort_by
      $evm.object["sort_order"]    = sort_order
      $evm.object["data_type"]     = data_type
      $evm.object["required"]      = required
      $evm.object["values"]        = hash
      $evm.object["default_value"] = default_value 
      log(:info, "Set dropdown has values to #{hash.inspect}")
    end

    # Get an AWS object from an ext_management_system object
    # 
    # 
    def get_aws_object(ext_mgt_system, type="EC2")
      require 'aws-sdk'
      AWS.config(
        :access_key_id => ext_mgt_system.authentication_userid,
        :secret_access_key => ext_mgt_system.authentication_password,
        :region => ext_mgt_system.provider_region
        )
      return Object::const_get("AWS").const_get("#{type}").new()
    end

    #
    # Get a Fog Object from a ext_management system
    #
    # @example
    #    ext_management_system = vm.ext_management_system
    #    conn = get_fog_object(ext_mangagement_system, "Network", "tenant")
    #
    # @param [ems_openstack] A MIQ ems_openstack object
    # @param [String] The type of service to retrieve that is supported by fog.  ie: "Orchestration" == "Heat", defaault = "Compute"
    # @param [String] The tenant to connect to
    # @param [String] The keystone authentication token to reuse
    # @param [Boolean] Is encrypted?  NOTE: this method will retry itself it it sees an encrypted connectin and encrypted == false
    # @param [Boolean] verify_peer: by default, let's not do any peer verification
    # @return Fog object of type "Fog::#{type}"
    def get_fog_object(ext_mgt_system, type="Compute", tenant="admin", auth_token=nil, encrypted=false, verify_peer=false)
      proto = "http"
      proto = "https" if encrypted
      require 'fog'
      begin
        return Object::const_get("Fog").const_get("#{type}").new({
          :provider => "OpenStack",
          :openstack_api_key => ext_mgt_system.authentication_password,
          :openstack_username => ext_mgt_system.authentication_userid,
          :openstack_auth_url => "#{proto}://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens",
          :openstack_auth_token => auth_token,
          :connection_options => { :ssl_verify_peer => verify_peer, :ssl_version => :TLSv1 },
          :openstack_tenant => tenant
          })
      rescue Excon::Errors::SocketError => sockerr
        raise unless sockerr.message.include?("end of file reached (EOFError)")
        log(:error, "Looks like potentially an ssl connection due to error: #{sockerr}")
        return get_fog_object(ext_mgt_system, type, tenant, auth_token, true, verify_peer)
      rescue => loginerr
        log(:error, "Error logging [#{ext_mgt_system}, #{type}, #{tenant}, #{auth_token rescue "NO TOKEN"}]")
        log_err(loginerr)
        log(:error, "Returning nil")
      end
      return nil
    end

    # Get a keystone auth token from a connection object
    # @example
    #    fog = MiqHlp.get_fog_object(vm.ext_mangaement_system, "Database")
    #    auth_token = MiqHlp.get_auth_token(fog)
    #    url = MiqHlp.get_management_url(fog)
    #
    # @param [Fog::Connection] A Fog OpenStack connection
    # @return [String] The current auth token
    def get_auth_token(conn)
      return conn.auth_token if conn.respond_to?("auth_token")
      return conn.instance_variable_get(:@auth_token)
    end

    # Get the management URL of the service a fog object is speaking to
    # Useful if you need to make REST calls to a service that fog does not yet support
    # @example
    #    fog = MiqHlp.get_fog_object(vm.ext_mangaement_system, "Database")
    #    auth_token = MiqHlp.get_auth_token(fog)
    #    url = MiqHlp.get_management_url(fog)
    #
    # @param [Fog::Connect] A fog OpenStack connection
    # @return [String] The URL this fog object is connected to
    def get_management_url(conn)
      return conn.instance_variable_get(:@openstack_management_url)
    end

    # Get a Ruby Savon client from an ext management system
    # @example
    #  client = nil
    #  begin
    #    client = MiqHlp.get_vcenter_savon_obj(vm.ext_management_system)
    #    ...
    #  ensure
    #    MiqHlp.vcenter_logout(client) unless client.nil?
    #  end
    #
    # @param [:ems_vmware] A VCenter Management System
    # @return [Savon::Client] A Savon SOAP client
    def get_vcenter_savon_obj(vcenter_mgt_system)
      require 'savon'
      client = Savon.client(
        :wsdl => "https://#{vcenter_mgt_system.ipaddress}/sdk/vim.wsdl",
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
            :userName => vcenter_mgt_system.authentication_userid,
            :password => vcenter_mgt_system.authentication_password,
            )
        end
        client.globals.headers({"Cookie" => result.http.headers["Set-Cookie"]})
        return client
      rescue => loginerr
        log_err(loginerr)
        return nil
      end
    end

    # Clean up a vcenter SOAP session
    #@example
    # @example
    #  client = nil
    #  begin
    #    client = MiqHlp.get_vcenter_savon_obj(vm.ext_management_system)
    #    ...
    #  ensure
    #    MiqHlp.vcenter_logout(client) unless client.nil?
    #  end
    #
    #@param [Savon::Client] the savon client to logout
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

    # Generic wrapper around call to RHEVM
    #
    #@example
    #  response = MiqHlp.call_rhevm(mgt_system, "/api/clusters/#{cluster_id}/affinitygroups", :post, new_affinity_group_payload)
    #
    #@param [:ems_redhat] RHEV management System
    #@param [String] The URI part of the URL to send the request to
    #@param [String] The type of request (:get, :post, :put, :delete)
    #@param [hash] The Hash Payload of the request
    def call_rhevm(ext_mgt_system, uri, type=:get, payload=nil)
      require 'rest-client'
      require 'json'

      params = {
        :method => type,
        :user => ext_mgt_system.authentication_userid,
        :password => ext_mgt_system.authentication_password,
        :url => "https://#{ext_mgt_system[:hostname]}#{uri}",
        :headers => { :accept => :json, :content_type => :json }
      }

      params[:payload] = JSON.generate(payload) unless payload.nil?

      log(:info, "[call_rhevm] Calling rhevm with #{params.inspect}")

      begin
        response = RestClient::Request.new(params).execute
      rescue => rheverr
        log(:error, "Error calling RHEV #{rheverr.response}")
        log(:error, "#{rheverr.backtrace.join("\n")}")
        return nil
      end
      if type == :delete
        return {}
      else
        return JSON.parse(response)
      end
    end

    # Run a shell command (on whatever the current automation worker node is)
    #
    #@example
    #    cmd = "knife bootstrap -x username -p password hostname"
    #    result = run_linux_admin(cmd, 60)
    #
    #@param [String] The command to run
    #@param [Integer] the timeout value for the command (default to 30)
    #@return [AwesomeSpawn::CommandResult]
    def run_linux_admin(cmd, timeout=30)
      require 'linux_admin'
      require 'timeout'
      begin
        Timeout::timeout(timeout) {
          log(:info, "Executing #{cmd} with timeout of #{timeout} seconds")
          result = LinuxAdmin.run(cmd)
          log(:info, "--> Inspecting output: #{result.output.inspect}")
          log(:info, "--> Inspecting error: #{result.error.inspect}") unless result.error.blank? 
          log(:info, "--> Inspecting exit_status: #{result.exit_status.inspect}")
          return result
        }
      rescue => timeout
        log(:error, "Error executing '#{cmd}'")
        log(:error, "'#{timeout.class}' '#{timeout}' \n#{timeout.backtrace.join("\n")}")
        return false
      end
    end

  end
end

