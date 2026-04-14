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
                self.blacklisted.push_back(self.services[i])
                print("FIRM [Registry]: Service", name, "moved to BLACKLIST.")
                return

    fn promote_random_node(inout self) raises:
        if len(self.blacklisted) == 0:
            return
        if random.random_si64(0, 10) > 7:
            let s = self.blacklisted[0]
            print("FIRM [Registry]: COIN FLIP SUCCESS -> Promoting", s.name)
            self.services.push_back(s)

    fn sync_with_remote_registry(inout self, remote_data: PythonObject) raises:
        # Algorithm: Ad-UDDI Gossip Simulation
        print("FIRM [Ad-UDDI]: Synchronizing with remote registry...")
        # Simulating loading remote services
        let remote_qos = QoSMetadata(15.0, 2000.0, 0.999)
        self.register(Service("RemoteStorage", "192.168.1.50", 9000, 10, remote_qos))
        print("FIRM [Ad-UDDI]: Sync Complete. New services added.")

    fn load_config(inout self, file_path: String) raises:
        print("FIRM [Registry]: Loading config from", file_path)
        let low_qos = QoSMetadata(20.0, 1000.0, 0.99)
        self.register(Service("PaymentService", "127.0.0.1", 8080, 1, low_qos))
        self.register(Service("InventoryService", "127.0.0.1", 8081, 2, low_qos))

    fn list_services(self):
        print("Registered Services:")
        for i in range(len(self.services)):
            let s = self.services[i]
            print("- ", s.name, " @ ", s.host, ":", s.port)
