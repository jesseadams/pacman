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

# AUR doesn't track package versions, only current version is hosted on AUR.
# See: https://wiki.archlinux.org/index.php/downgrading_packages#AUR_packages
# Yaourt will also resolve packages from AUR or standard pacman repos.
action :install do
  unless @aurpkg.exists
    execute "installing package #{new_resource.name} with yaourt" do
      command "yaourt -S --nocolor --noconfirm #{new_resource.name}"
    end
    new_resource.updated_by_last_action(true)
  end
end

def load_current_resource
  @aurpkg = Chef::Resource::PacmanYaourt.new(new_resource.name)
  @aurpkg.package_name(new_resource.package_name)

  Chef::Log.info("Checking if #{new_resource.package_name} is installed")
  # pacman -Qqs will only return things if the package is currently installed
  # if nothing (nil) is returned due to error, package doesn't exist locally
  package_installed = system("pacman -Qqs #{new_resource.package_name}")
  @aurpkg.exists(package_installed)
end
