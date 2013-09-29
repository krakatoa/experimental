require 'dbus'

bus = DBus.session_bus
service = bus.service("cucub.app")
obj = service.object("/cucub/Instance")
obj.introspect
obj.default_iface = "cucub.Interface"

#Thread.new do
#  while true
    obj.on_signal("Something") do
      puts "Bla!"
    end
#  end
#end

sleep 4
obj.hello
sleep 4
obj.hello
sleep 4
obj.hello
