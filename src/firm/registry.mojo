from .common import Service, QoSMetadata
from utils.vector import DynamicVector
from python import Python

struct ServiceRegistry:
    var services: DynamicVector[Service]
    var _session_map: PythonObject

    fn __init__(inout self) raises:
        self.services = DynamicVector[Service]()
        self._session_map = Python.dict()

    fn register(inout self, service: Service):
        self.services.push_back(service)

    fn find(inout self, name: String, session_id: String = "") raises -> Service:
        # Check for affinity first
        if session_id != "":
            let key = name + "@" + session_id
            if self._session_map.__contains__(key):
                let host_port = String(self._session_map[key])
                print("FIRM [Registry]: Affinity Hit for session", session_id, "->", host_port)
                # In a real impl, we'd lookup by host_port. 
                # Here we just find the first matching service name for brevity.
        
        # Simple linear search for research parity
        for i in range(len(self.services)):
            let s = self.services[i]
            if s.name == name:
                # Pin session to this node if requested
                if session_id != "":
                    let key = name + "@" + session_id
                    self._session_map[key] = s.host + ":" + String(s.port)
                return s
        
        return Service("None", "0.0.0.0", 0, 0, QoSMetadata(0.0, 0.0, 0.0))

    fn list_services(self):
        print("Registered Services:")
        for i in range(len(self.services)):
            let s = self.services[i]
            print("- ", s.name, " @ ", s.host, ":", s.port, " [Channel:", s.amqp_channel, "]")
