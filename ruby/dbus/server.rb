require 'dbus'

#bus = DBus::SessionBus.instance
bus = DBus.session_bus
service = bus.request_service("cucub.app")

class Test < DBus::Object
  dbus_interface "cucub.Interface" do

    dbus_signal :Something, "toto:s, tutu:s"

    dbus_method :hello do
      Test.handler.Something("bla", "blo")
      puts "hola"
    end
  end

  def self.handler
    return @@obj if defined? @@obj
    bus = DBus.session_bus
    service = bus.service("cucub.app")
    #obj = service.object("/cucub/Instance")
    #obj.introspect
    #obj.default_iface = "cucub.Interface"
    #obj
    @@obj = Test.new("/cucub/Instance")
    service.export(@@obj)
    @@obj
  end
end

obj = Test.new("/cucub/Instance")
service.export(obj)

cycle = DBus::Main.new
cycle << bus
cycle.run
