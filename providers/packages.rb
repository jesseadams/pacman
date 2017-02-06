#
# Cookbook Name:: pacman
# Provider:: group
#
# Copyright:: 2010, Opscode, Inc <legal@opscode.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
require 'chef/mixin/command'
include Chef::Mixin::Command

action :install do
  run_command_with_systems_locale(
    :command => "pacman --sync --needed --noconfirm --noprogressbar #{@new_resource.options} #{@new_resource.packages.join(' ')}"
  )
  new_resource.updated_by_last_action(true)
end

action :remove do
  run_command_with_systems_locale(
    :command => "pacman --remove --noconfirm --noprogressbar #{@new_resource.options} #{@new_resource.packages.join(' ')}"
  )
  new_resource.updated_by_last_action(true)
end
