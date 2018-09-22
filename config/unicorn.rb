# worker_processes Integer(ENV["WEB_CONCURRENCY"] || 5)
# timeout 30
# preload_app true
#
# before_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
#     Process.kill 'QUIT', Process.pid
#   end
#   DB.disconnect if defined?(DB)
# end
#
# after_fork do |server, worker|
#   Signal.trap 'TERM' do
#     puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
#   end
#   DB = Sequel.connect(ENV['TAB_DATABASE'] || 'postgres://TABINC:hfphf,jnrf98@127.0.0.1:5432/TABINC') if !defined?(DB)
# end
#

worker_processes 2
timeout 24
