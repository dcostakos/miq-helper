
begin

  def get_role_ids_for_heat(conn)
    roles = []
    conn.list_roles[:body]["roles"].each { |role|
      roles.push(role) if role["name"] == "admin" || role["name"] == "heat_stack_owner" || role["name"] == "_member_"
    }
    return roles
  end

  require 'miq-helper'
  @hlp = MiqHelper.new()

  @hlp.log(:info, "Begin Automate Method")

  require 'fog'

  @hlp.inspector.dump_root

  @task = @hlp.get_vmdb_object
  @hlp.inspector.dump_attributes('service_template_provision_task', @task)

  @service = @task.destination
  @hlp.log(:info, "Detected Service:<#{@service.name}> Id:<#{@service.id}> Tasks:<#{@task.miq_request_tasks.count}>")

  # Get the OpenStack EMS from dialog_mid or grab the first one if it isn't set
  mid = $evm.root['dialog_mid']
  openstack = nil
  unless mid.nil?
    openstack = $evm.vmdb(:ems_openstack).find_by_id(mid)
  else
    openstack = $evm.vmdb(:ems_openstack).all.first
  end
  raise "Unable to get OpenStack MGT System" if openstack.nil?

  @hlp.log(:info, "Connecting to OpenStack EMS #{openstack[:hostname]}/#{mid}")
  conn = @hlp.get_fog_object(openstack, "Identity", "admin")
  @task.set_option(:fog_auth_token, conn.auth_token.to_s)

  # Get the tenant name from "dialog_tenant_name" or generate a random string if it isn't there
  name = $evm.root['dialog_tenant_name']
  name = "cftenant#{rand(36**10).to_s(36)}" if name.blank?
  description = "CloudForms Automate Tenant will be #{name}"

  # Create the new tenant
  tenant = conn.create_tenant({
    :description => description,
    :enabled => true,
    :name => name
  })[:body]["tenant"]
  @hlp.log(:info, "Successfully created tenant #{tenant.inspect}")

  # Get my keystone user information
  myuser = conn.list_users[:body]["users"].select { |user| user["name"] == "#{openstack.authentication_userid}" }.first
  @hlp.log(:info, "Got my user information: #{myuser.inspect}")

  # In IceHouse, the user must be a member of the right roles for Heat to work,
  # get those role ids, then assign them to the user in the new tenant
  myroles = get_role_ids_for_heat(conn)
  @hlp.log(:info, "Got Role IDs for Heat: #{myroles.inspect}")
  myroles.each { |role|
    conn.create_user_role(tenant["id"], myuser["id"], role["id"])
  }
  @hlp.log(:info, "User Roles Applied: #{conn.list_roles_for_user_on_tenant(tenant["id"], myuser["id"]).inspect}")

  # Set some custom attrs on the service so we can clean up later easily
  @service.custom_set("TENANT_ID", "#{tenant["id"]}")
  @service.custom_set("TENANT_NAME", "#{tenant["name"]}")

  # Create a tenant tag for the service so we know where that is too.
  @hlp.process_tags("cloud_tenants", "Cloud Tenants", false, tenant["name"], tenant["name"])
  @service.tag_assign("cloud_tenants/#{tenant["name"]}")
  @service.custom_set("STATUS", "Created Cloud Tenant #{tenant["name"]}")
  @hlp.log(:info, "Tagged Service: #{service.tags.inspect}")

  # Initiate a Refresh of the EMS
  openstack.refresh

  @hlp.log(:info, "End Automate Method")

rescue => err
  @hlp.log_err(err, true, true, true)
  if @task && @task.get_option(:remove_from_vmdb_on_fail)
    @service.remove_from_vmdb unless @service.nil?
  end
  exit MIQ_ABORT
end