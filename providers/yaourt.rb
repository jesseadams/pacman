#
# Cookbook Name:: pacman
# Provider:: yaourt
#
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

# replaced aur.rb and uses https://wiki.archlinux.org/index.php/yaourt

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

action :install do
  unless @aurpkg.exists
    execute "install AUR package #{new_resource.name}-#{new_resource.version} with yaourt" do
      command "yaourt -Sbb --nocolor --noconfirm #{new_resource.name}-#{new_resource.version}"
    end
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  @aurpkg = Chef::Resource::PacmanYaourt.new(new_resource.name)
  @aurpkg.package_name(new_resource.package_name)

  Chef::Log.info("Checking pacman for #{new_resource.package_name}")
  package_details = shell_out("pacman -Qi #{new_resource.package_name}")
  package_details = package_details.stdout.split("\n")
  exists = package_details[0].split(":")[1].chomp.include?(@aurpkg.package_name)
  @aurpkg.exists(exists)
end
