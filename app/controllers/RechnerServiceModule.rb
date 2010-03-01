module RechnerServiceModule
InterfaceNS = 'http://FreebieSMS.co.uk'
Methods=[['SendSms','FromName','FromNumber','ToNumber','Message','locale']]

def RechnerServiceModule.add_method(drv)
Methods.each do |method, *param|
drv.add_method_with_soapaction(method, InterfaceNS+"/#{ method }", *param)
end
end
end

