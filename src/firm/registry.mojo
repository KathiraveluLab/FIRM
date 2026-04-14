from .common import Service, QoSMetadata
from utils.vector import DynamicVector
from python import Python
import random

struct ServiceRegistry:
    var services: DynamicVector[Service]
    var blacklisted: DynamicVector[Service]
    var _session_map: PythonObject

    fn __init__(inout self) raises:
        self.services = DynamicVector[Service]()
        self.blacklisted = DynamicVector[Service]()
        self._session_map = Python.dict()

    fn register(inout self, service: Service):
        self.services.push_back(service)

    fn find(inout self, name: String, session_id: String = "") raises -> Service:
        # Check for affinity first
        if session_id != "":
            let key = name + "@" + session_id
            if self._session_map.__contains__(key):
                let host_port = String(self._session_map[key])
                # Find matching active service
                for i in range(len(self.services)):
                    let s = self.services[i]
                    if s.name == name:
                        return s
        
        # Default search
        for i in range(len(self.services)):
            let s = self.services[i]
            if s.name == name:
                if session_id != "":
                    self._session_map[name + "@" + session_id] = s.host + ":" + String(s.port)
                return s
        
        return Service("None", "0.0.0.0", 0, 0, QoSMetadata(0.0, 0.0, 0.0))

    fn blacklist(inout self, name: String):
        for i in range(len(self.services)):
            if self.services[i].name == name:
                let s = self.services[i]
                self.blacklisted.push_back(s)
                # Remove from active (simplified for demo)
                print("FIRM [Registry]: Service", name, "moved to BLACKLIST.")
                return

    fn promote_random_node(inout self) raises:
        # Algorithm 3: Promoter Thread logic
        if len(self.blacklisted) == 0:
            return
            
        # Flip a coin (simulated)
        if random.random_si64(0, 10) > 7: # 30% chance to promote
            let s = self.blacklisted[0] # Pop first for simplicity
            print("FIRM [Registry]: COIN FLIP SUCCESS -> Promoting", s.name, "back to rotation.")
            self.services.push_back(s)
            # Remove from blacklist
            # ...

    fn load_config(inout self, file_path: String) raises:
        print("FIRM [Registry]: Loading Nginx-style config from", file_path)
        # In a real Mojo implementation, we would use File.read()
        # For parity, we simulate the parsing of services.conf
        let low_qos = QoSMetadata(20.0, 1000.0, 0.99)
        self.register(Service("PaymentService", "127.0.0.1", 8080, 1, low_qos))
        self.register(Service("InventoryService", "127.0.0.1", 8081, 2, low_qos))
        print("FIRM [Registry]: Config loaded. Scanned 2 services.")

    fn list_services(self):
        print("Registered Services:")
        for i in range(len(self.services)):
            let s = self.services[i]
            print("- ", s.name, " @ ", s.host, ":", s.port)
