#
# Cookbook Name:: pacman
# Resource:: aur
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

actions :build, :install

default_action :install

attribute :package_name, :name_attribute => true
attribute :version, :default => nil
attribute :builddir, :default => "#{Chef::Config[:file_cache_path]}/builds"
attribute :options, :kind_of => String
attribute :pkgbuild_src, :default => false
attribute :patches, :kind_of => Array, :default => []
attribute :exists, :default => false
