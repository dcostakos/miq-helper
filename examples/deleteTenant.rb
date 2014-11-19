
begin

  require 'miq-helper'
  @hlp = MiqHelper.new()

  @hlp.log(:info, "Begin Automate Method")

  require 'fog'

  @hlp.inspector.dump_root

  service = @hlp.get_vmdb_object

  mid = mid = service.custom_get("MID")
  tenant_id = service.custom_get("TENANT_ID")

  raise "MID is nil from service attributes, cannot continue" if mid.nil?

  openstack = $evm.vmdb(:ems_openstack).find_by_id(mid)
  raise "OpenStack Management system with id #{mid} not found" if openstack.nil?

  raise "No tenant ID available from service.custom_get: #{tenant_id}" if tenant_id.nil?

  @hlp.log(:info, "Connecting to OpenStack EMS #{openstack[:hostname]}/#{mid}")
  conn = @hlp.get_fog_object(openstack, "Identity", "admin")

  @hlp.log(:info, "Deleting Tenant #{tenant_id} from OpenStack")

  response = conn.delete_tenant(tenant_id)
  @hlp.log(:info, "Delete Response #{response.inspect}")

  @hlp.log(:info, "Fully retiring service")
  service.remove_from_vmdb
  openstack.refresh
  @hlp.log(:info, "Retired")
  @hlp.log(:info, "End Automate Method")

rescue => err
  @hlp.log_err(err, true, true, true)
  if @task && @task.get_option(:remove_from_vmdb_on_fail)
    @service.remove_from_vmdb unless @service.nil?
  end
  exit MIQ_ABORT
end