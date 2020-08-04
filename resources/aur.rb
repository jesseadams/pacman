#
# Cookbook:: pacman
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

default_action :install

property :package_name, String, name_property: true
property :version, [String, NilClass], default: lazy {
  version = ''
  release = ''
  arch = ''
  if ::File.exist?("#{builddir}/#{name}/PKGBUILD")
    ::File.open("#{builddir}/#{name}/PKGBUILD").each do |line|
      version = line.split('=')[1].chomp if line =~ /^pkgver=/
      release = line.split('=')[1].chomp if line =~ /^pkgrel=/
      next unless line =~ /^arch/

      arch = if line.match? 'any'
               'any'
             else
               node['kernel']['machine']
             end
    end
    Chef::Log.debug("Setting version of #{name} to #{version}-#{release}-#{arch}")
    "#{version}-#{release}-#{arch}"
  end
}
property :builddir, String, default: "#{Chef::Config[:file_cache_path]}/builds"
property :options, String, default: ''
property :pkgbuild_src, [true, false], default: false
property :patches, Array, default: []
property :exists, [true, false], default: false

load_current_value do |new_resource|
  package_name new_resource.package_name
  Chef::Log.debug("Checking pacman for #{new_resource.package_name}")
  p = shell_out("pacman -Qi #{new_resource.package_name}")
  exists p.stdout.include?(new_resource.package_name)
end

action :build do
  Chef::Log.debug('Creating build directory')
  directory new_resource.builddir do
    owner 'root'
    group 'root'
    mode '0o755'
  end

  Chef::Log.debug("Retrieving source for #{new_resource.package_name}")
  remote_file "#{new_resource.builddir}/#{new_resource.package_name}.tar.gz" do
    source "https://aur.archlinux.org/cgit/aur.git/snapshot/#{new_resource.package_name}.tar.gz"
    owner 'root'
    group 'root'
    mode '0o644'
    action :create_if_missing
  end

  Chef::Log.debug("Untarring source package for #{new_resource.package_name}")
  execute "untar #{new_resource.package_name}" do
    cwd new_resource.builddir
    command "tar xf #{new_resource.package_name}.tar.gz"
    creates "#{new_resource.builddir}/#{new_resource.package_name}/PKGBUILD"
  end

  if new_resource.pkgbuild_src
    Chef::Log.debug('Replacing PKGBUILD with custom version')
    cookbook_file "#{new_resource.builddir}/#{new_resource.package_name}/PKGBUILD" do
      source 'PKGBUILD'
      owner 'root'
      group 'root'
      mode '0o644'
    end
  end

  unless new_resource.patches.empty?
    Chef::Log.debug('Adding new patches')
    new_resource.patches.each do |patch|
      cookbook_file ::File.join(new_resource.builddir, new_resource.package_name, patch) do
        source patch
        mode '0o644'
      end
    end
  end

  converge_if_changed :options do
    if new_resource.options
      Chef::Log.debug("Appending #{new_resource.options} to configure command")
      opt = Chef::Util::FileEdit.new("#{new_resource.builddir}/#{new_resource.package_name}/PKGBUILD")
      opt.search_file_replace(%r{(.\/configure.+$)}, "\\1 #{new_resource.options}")
      opt.write_file
    end
  end

  # makepkg runnable by root
  makepkg_path = "#{Chef::Config[:file_cache_path]}/makepkg"
  execute 'patch_makepkg' do
    command <<~EOCMD
      sed -e 's/(( EUID == 0 ))/false/' /usr/bin/makepkg > #{makepkg_path}
      chmod +x #{makepkg_path}
    EOCMD
    creates makepkg_path
  end

  Chef::Log.debug("Building package #{new_resource.package_name}")
  execute "#{makepkg_path} -s --noconfirm" do
    cwd ::File.join(new_resource.builddir, new_resource.package_name)
    creates "#{new_resource.builddir}/#{new_resource.package_name}/pkg"
  end
end

action :install do
  execute "install AUR package #{new_resource.package_name}-#{new_resource.version}" do
    command "pacman -U --noconfirm --noprogressbar #{new_resource.builddir}/#{new_resource.package_name}/#{new_resource.package_name}-#{new_resource.version}.pkg.tar.zst"
    not_if { current_resource.exists }
  end
end
