#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'socket'

compile_master  = Socket.gethostname
environmentpath = ARGV[0]
environment     = ARGV[1]

# Get the short SHA1 commit ID from the control repository.
r10k_deploy_file_path = File.join(environmentpath, environment, '.r10k-deploy.json')
commit_id_short = JSON.parse(File.read(r10k_deploy_file_path))['signature'][0...11]

# Show the compiling master, environment name, and short commit ID.
puts "#{compile_master}-#{environment}-#{commit_id_short}"
