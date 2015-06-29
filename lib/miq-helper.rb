# 
# This class consists of a set of helper methods
# usable inside a ManageIQ or CloudForms Management Engine
# Automation workflow engine
# Reference http://www.manageiq.org
#
# Author:: Dave Costakos (mailto:david.costakos@redhat.com)
# Copyright:: Copyright (c) 2015 Red Hat, Inc.
# License:: GPL
# 

require "miq-helper/common"
require "miq-helper/inspector"

class MiqHlp
  extend Common
  include Common
  extend Inspector
  include Inspector
end