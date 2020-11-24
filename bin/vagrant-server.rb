require_relative '../proto/gen/plugin_pb'
require_relative '../proto/gen/plugin_services_pb'

require 'grpc'
require 'grpc/health/checker'
require 'grpc/health/v1/health_services_pb'
require 'openssl'
require 'optparse'

class ProviderService < Hashicorp::Vagrant::Sdk::Provider::Service
  def documentation(req, _unused_call)
    
  end

  def configure(req, _unused_call)
    
  end

  def config_struct(req, _unused_call)

  end
end

def main
  s = GRPC::RpcServer.new
  # Listen on port 24000 on all interfaces. Update for production use.
  s.add_http2_port('[::]:10001', :this_port_is_insecure)

  s.handle(ProviderService.new)

  health_checker = Grpc::Health::Checker.new
  health_checker.add_status(
    "Hashicorp::Vagrant::Sdk::Provider::ProviderService",
    Grpc::Health::V1::HealthCheckResponse::ServingStatus::SERVING)
  s.handle(health_checker)

  t = Thread.new {
    s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT', 'SIGINT'])
  }

  threads = [
    t,
    Thread.new {
      STDOUT.puts "1|1|tcp|127.0.0.1:10001|grpc"
      STDOUT.flush
    }
  ]

  threads.each { |tr| tr.join }

  catch :ctrl_c do
    t.exit
    abort("goodbye")
  end
end

trap("SIGINT") { throw :ctrl_c }

main()
