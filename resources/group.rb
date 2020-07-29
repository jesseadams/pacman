#
# Cookbook:: pacman
# Resource:: group
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

default_action :install

property :group_name, String, name_property: true
property :options, String, default: ''

load_current_value do |new_resource|
  group_name new_resource.group_name
end

action :install do
  execute "group install #{new_resource.group_name}" do
    command "pacman --sync --noconfirm --noprogressbar#{expand_options(new_resource.options)} #{new_resource.group_name}"
    environment('LC_ALL' => nil)
    not_if { shell_out("pacman -Qg #{new_resource.group_name}").stdout.include?(new_resource.group_name) }
  end
end

action :remove do
  execute "group uninstall #{new_resource.group_name}" do
    command "pacman --remove --noconfirm --noprogressbar#{expand_options(new_resource.options)} #{new_resource.group_name}"
    environment('LC_ALL' => nil)
    only_if { shell_out("pacman -Qg #{new_resource.group_name}").stdout.include?(new_resource.group_name) }
  end
end

action_class.class_eval do
  def expand_options(options)
    if options
      " #{options.is_a?(Array) ? Shellwords.join(options) : options}"
    else
      ''
    end
  end
end
