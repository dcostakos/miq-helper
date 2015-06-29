var search_data = {"index":{"searchIndex":["miqhlp","common","inspector","objectwalker","call_rhevm()","default_dropdown_setup()","dumpassociations()","dumpattributes()","dumpcurrentobject()","dumpemscluster()","dumpemscluster()","dumpextmanagementsystem()","dumphost()","dumpmiqgroup()","dumpmiqserver()","dumpmiqgroup()","dumpmiqserver()","dumproot()","dumpservice()","dumpservicetemplate()","dumpstorage()","dumptags()","dumpuser()","dumpvirtualcolumns()","dumpvm()","dump_association()","dump_associations()","dump_associations()","dump_attributes()","dump_attributes()","dump_current_object()","dump_ems_cluster()","dump_ext_management_system()","dump_host()","dump_methods()","dump_miq_group()","dump_miq_server()","dump_object()","dump_root()","dump_service()","dump_service_template()","dump_storage()","dump_tags()","dump_user()","dump_virtual_columns()","dump_virtual_columns()","dump_vm()","get_auth_token()","get_aws_object()","get_fog_object()","get_management_url()","get_vcenter_savon_obj()","get_vm_from_evm_root()","get_vmdb_object()","inspectme()","inspect_me()","is_plural?()","log()","log_err()","process_tags()","retry_method()","run_linux_admin()","type()","vcenter_logout()","walk_object()"],"longSearchIndex":["miqhlp","miqhlp::common","miqhlp::inspector","miqhlp::objectwalker","miqhlp::common#call_rhevm()","miqhlp::common#default_dropdown_setup()","miqhlp::inspector#dumpassociations()","miqhlp::inspector#dumpattributes()","miqhlp::inspector#dumpcurrentobject()","miqhlp::inspector#dumpemscluster()","miqhlp::inspector#dumpemscluster()","miqhlp::inspector#dumpextmanagementsystem()","miqhlp::inspector#dumphost()","miqhlp::inspector#dumpmiqgroup()","miqhlp::inspector#dumpmiqserver()","miqhlp::inspector#dumpmiqgroup()","miqhlp::inspector#dumpmiqserver()","miqhlp::inspector#dumproot()","miqhlp::inspector#dumpservice()","miqhlp::inspector#dumpservicetemplate()","miqhlp::inspector#dumpstorage()","miqhlp::inspector#dumptags()","miqhlp::inspector#dumpuser()","miqhlp::inspector#dumpvirtualcolumns()","miqhlp::inspector#dumpvm()","miqhlp::objectwalker#dump_association()","miqhlp::inspector#dump_associations()","miqhlp::objectwalker#dump_associations()","miqhlp::inspector#dump_attributes()","miqhlp::objectwalker#dump_attributes()","miqhlp::inspector#dump_current_object()","miqhlp::inspector#dump_ems_cluster()","miqhlp::inspector#dump_ext_management_system()","miqhlp::inspector#dump_host()","miqhlp::objectwalker#dump_methods()","miqhlp::inspector#dump_miq_group()","miqhlp::inspector#dump_miq_server()","miqhlp::objectwalker#dump_object()","miqhlp::inspector#dump_root()","miqhlp::inspector#dump_service()","miqhlp::inspector#dump_service_template()","miqhlp::inspector#dump_storage()","miqhlp::inspector#dump_tags()","miqhlp::inspector#dump_user()","miqhlp::inspector#dump_virtual_columns()","miqhlp::objectwalker#dump_virtual_columns()","miqhlp::inspector#dump_vm()","miqhlp::common#get_auth_token()","miqhlp::common#get_aws_object()","miqhlp::common#get_fog_object()","miqhlp::common#get_management_url()","miqhlp::common#get_vcenter_savon_obj()","miqhlp::common#get_vm_from_evm_root()","miqhlp::common#get_vmdb_object()","miqhlp::inspector#inspectme()","miqhlp::inspector#inspect_me()","miqhlp::objectwalker#is_plural?()","miqhlp::common#log()","miqhlp::common#log_err()","miqhlp::common#process_tags()","miqhlp::common#retry_method()","miqhlp::common#run_linux_admin()","miqhlp::objectwalker#type()","miqhlp::common#vcenter_logout()","miqhlp::objectwalker#walk_object()"],"info":[["MiqHlp","","MiqHlp.html","",""],["MiqHlp::Common","","MiqHlp/Common.html","",""],["MiqHlp::Inspector","","MiqHlp/Inspector.html","",""],["MiqHlp::ObjectWalker","","MiqHlp/ObjectWalker.html","",""],["call_rhevm","MiqHlp::Common","MiqHlp/Common.html#method-i-call_rhevm","(ext_mgt_system, uri, type=:get, payload=nil)","\n<pre>Generic wrapper around call to RHEVM</pre>\n<p>@example\n\n<pre>response = MiqHlp.call_rhevm(mgt_system, &quot;/api/clusters/#{cluster_id}/affinitygroups&quot;, ...</pre>\n"],["default_dropdown_setup","MiqHlp::Common","MiqHlp/Common.html#method-i-default_dropdown_setup","(hash, sort_by=\"description\", sort_order=\"ascending\", data_type=\"string\", required=\"true\", default_value=nil)","<p>Convenience method for setting up default dropdown list\n<p>@example\n\n<pre>default_dropdown_setup(value_hash)</pre>\n"],["dumpAssociations","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpAssociations","(object_type, object)",""],["dumpAttributes","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpAttributes","(object_type, object)",""],["dumpCurrentObject","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpCurrentObject","()",""],["dumpEMSCluster","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpEMSCluster","()",""],["dumpEmsCluster","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpEmsCluster","()",""],["dumpExtManagementSystem","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpExtManagementSystem","()",""],["dumpHost","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpHost","()",""],["dumpMIQGroup","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpMIQGroup","()",""],["dumpMIQServer","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpMIQServer","()",""],["dumpMiqGroup","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpMiqGroup","()",""],["dumpMiqServer","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpMiqServer","()",""],["dumpRoot","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpRoot","()",""],["dumpService","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpService","()",""],["dumpServiceTemplate","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpServiceTemplate","()",""],["dumpStorage","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpStorage","()",""],["dumpTags","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpTags","(object_type, object)",""],["dumpUser","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpUser","()",""],["dumpVirtualColumns","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpVirtualColumns","(object_type, object)",""],["dumpVm","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dumpVm","()",""],["dump_association","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_association","(object_string, association, associated_objects, indent_string)",""],["dump_associations","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_associations","(object_type, object)",""],["dump_associations","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_associations","(object_string, this_object, this_object_class, indent_string)",""],["dump_attributes","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_attributes","(object_type, object)",""],["dump_attributes","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_attributes","(object_string, this_object, indent_string)",""],["dump_current_object","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_current_object","()",""],["dump_ems_cluster","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_ems_cluster","()","<p>Cluster Information\n"],["dump_ext_management_system","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_ext_management_system","()","<p>Provider Information\n"],["dump_host","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_host","()","<p>Host Information\n"],["dump_methods","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_methods","(object_string, this_object, indent_string)",""],["dump_miq_group","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_miq_group","()","<p>Group Information\n"],["dump_miq_server","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_miq_server","()","<p>CloudForms Server Information\n"],["dump_object","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_object","(object_string, this_object, indent_string)",""],["dump_root","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_root","()",""],["dump_service","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_service","()","<p>Service Information\n"],["dump_service_template","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_service_template","()","<p>CatalogItem Information\n"],["dump_storage","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_storage","()","<p>Storage Information\n"],["dump_tags","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_tags","(object_type, object)",""],["dump_user","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_user","()","<p>User Information\n"],["dump_virtual_columns","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_virtual_columns","(object_type, object)",""],["dump_virtual_columns","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-dump_virtual_columns","(object_string, this_object, this_object_class, indent_string)",""],["dump_vm","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-dump_vm","()","<p>VM Information\n"],["get_auth_token","MiqHlp::Common","MiqHlp/Common.html#method-i-get_auth_token","(conn)","<p>Get a keystone auth token from a connection object @example\n\n<pre>fog = MiqHlp.get_fog_object(vm.ext_mangaement_system, ...</pre>\n"],["get_aws_object","MiqHlp::Common","MiqHlp/Common.html#method-i-get_aws_object","(ext_mgt_system, type=\"EC2\")","<p>Get an AWS object from an ext_management_system object\n"],["get_fog_object","MiqHlp::Common","MiqHlp/Common.html#method-i-get_fog_object","(ext_mgt_system, type=\"Compute\", tenant=\"admin\", auth_token=nil, encrypted=false, verify_peer=false)","<p>Get a Fog Object from a ext_management system\n<p>@example\n\n<pre>ext_management_system = vm.ext_management_system ...</pre>\n"],["get_management_url","MiqHlp::Common","MiqHlp/Common.html#method-i-get_management_url","(conn)","<p>Get the management URL of the service a fog object is speaking to Useful if\nyou need to make REST calls …\n"],["get_vcenter_savon_obj","MiqHlp::Common","MiqHlp/Common.html#method-i-get_vcenter_savon_obj","(vcenter_mgt_system)","<p>Get a Ruby Savon client from an ext management system @example\n\n<pre>client = nil\nbegin\n  client = MiqHlp.get_vcenter_savon_obj(vm.ext_management_system) ...</pre>\n"],["get_vm_from_evm_root","MiqHlp::Common","MiqHlp/Common.html#method-i-get_vm_from_evm_root","()","<p>convenience method to get a VM objet from $evm.root\n<p>@example\n\n<pre>vm = MiqHlp.get_vm_from_evm_root</pre>\n"],["get_vmdb_object","MiqHlp::Common","MiqHlp/Common.html#method-i-get_vmdb_object","()","<p>Get a VMDB Object from $evm.root\n<p>@example\n\n<pre>miq_prov = MiqHlp.get_vmdb_object()</pre>\n"],["inspectMe","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-inspectMe","()",""],["inspect_me","MiqHlp::Inspector","MiqHlp/Inspector.html#method-i-inspect_me","()",""],["is_plural?","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-is_plural-3F","(astring)",""],["log","MiqHlp::Common","MiqHlp/Common.html#method-i-log","(level, message, update_message=false)","\n<pre>Log a message with using $evm.log and update vmdb_object property\nmessage if requested with the same ...</pre>\n"],["log_err","MiqHlp::Common","MiqHlp/Common.html#method-i-log_err","(err, update_message=false, update_reason=false, finish=false)","<p>Useful wrapper around #log to log error messages in a standard way\n<p>@example\n\n<pre>MiqHlp.log_err(exception)</pre>\n"],["process_tags","MiqHlp::Common","MiqHlp/Common.html#method-i-process_tags","( category, category_description, single_value, tag, tag_description )","<p>Method to create a new tag\n<p>@example\n\n<pre>tag_info = process_tags(&quot;new_category&quot;, &quot;My New Category&quot;, false, &quot;new_value&quot;, ...</pre>\n"],["retry_method","MiqHlp::Common","MiqHlp/Common.html#method-i-retry_method","(retry_time=1.minute)","<p>Standard retry method logic\n<p>@example\n\n<pre>MiqHlp.retry_method</pre>\n"],["run_linux_admin","MiqHlp::Common","MiqHlp/Common.html#method-i-run_linux_admin","(cmd, timeout=30)","\n<pre>Run a shell command (on whatever the current automation worker node is)</pre>\n<p>@example\n\n<pre>cmd = &quot;knife bootstrap ...</pre>\n"],["type","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-type","(object)",""],["vcenter_logout","MiqHlp::Common","MiqHlp/Common.html#method-i-vcenter_logout","(client)","\n<pre>Clean up a vcenter SOAP session</pre>\n<p>@example\n\n<pre>@example\n client = nil\n begin\n   client = MiqHlp.get_vcenter_savon_obj(vm.ext_management_system) ...</pre>\n"],["walk_object","MiqHlp::ObjectWalker","MiqHlp/ObjectWalker.html#method-i-walk_object","()","<p>Main method\n"]]}}