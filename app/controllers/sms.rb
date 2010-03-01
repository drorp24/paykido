require "soap/rpc/driver"
require "RechnerServiceModule"
include RechnerServiceModule

server = 'http://www.freebiesms.co.uk/sendsms.asmx'

wiredump_dev=STDERR

service = SOAP::RPC::Driver.new(server, RechnerServiceModule::InterfaceNS)
service.wiredump_dev=wiredump_dev

service.default_encodingstyle = SOAP::EncodingStyle::ASPDotNetHandler::Namespace
RechnerServiceModule::add_method(service)

result = service.SendSms("Bob","00972547722442","0044784412348","Hello From Ruby","en-GB")
