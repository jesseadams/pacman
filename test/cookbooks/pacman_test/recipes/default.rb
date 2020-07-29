#
# Cookbook:: pacman_test
# Recipe:: default
#
# Copyright:: 2020, Tomoya Kabe, All Rights Reserved.

pacman_aur 'memb' do
  action %i(build install)
end

pacman_aur 'tinydns' do
  version '0.3-1-any'
  action %i(build install)
end

pacman_group 'coin-or'

pacman_group 'coq'

pacman_group 'coq-uninstall' do
  group_name 'coq'
  action :remove
end
