require 'logger'
require 'socket'
require 'hrr_rb_ssh'


logger = Logger.new STDOUT
logger.level = Logger::INFO
HrrRbSsh::Logger.initialize logger


# Authenticate with specified password
auth_password = HrrRbSsh::Authentication::Authenticator.new do |context|
  username = 'sss' #ENV['USER']
  password = '123123'
  context.verify username, password
end


options = {}

# Use the defined certificate
options['authentication_password_authenticator']  = auth_password

# SSH Handle the connection's internal processing with the default implementation handler
options['connection_channel_request_pty_req']       = HrrRbSsh::Connection::RequestHandler::ReferencePtyReqRequestHandler.new
options['connection_channel_request_env']           = HrrRbSsh::Connection::RequestHandler::ReferenceEnvRequestHandler.new
options['connection_channel_request_shell']         = HrrRbSsh::Connection::RequestHandler::ReferenceShellRequestHandler.new
options['connection_channel_request_exec']          = HrrRbSsh::Connection::RequestHandler::ReferenceExecRequestHandler.new
options['connection_channel_request_window_change'] = HrrRbSsh::Connection::RequestHandler::ReferenceWindowChangeRequestHandler.new


# Listen for connection on port 10022
server = TCPServer.new(10022)
puts "[+] Starting SSH server"
io = server.accept
begin
  ssh_server = HrrRbSsh::Server.new(io, options)
  ssh_server.start
rescue => exception
  puts exception
  retry 
end

