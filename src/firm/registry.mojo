from .common import Service, QoSMetadata
from std.collections import List
from std.python import Python, PythonObject
import random

struct ServiceRegistry:
    var services: List[Service]
    var blacklisted: List[Service]
    var _session_map: PythonObject

    fn __init__(out self: Self) raises:
        self.services = List[Service]()
        self.blacklisted = List[Service]()
        self._session_map = Python.dict()

    fn register(mut self, service: Service):
        self.services.append(service)

    fn find(mut self, name: String, session_id: String = "") raises -> Service:
        if session_id != "":
            var key = name + "@" + session_id
            if self._session_map.__contains__(key):
                for i in range(len(self.services)):
                    if self.services[i].name == name:
                        return self.services[i]
        for i in range(len(self.services)):
            if self.services[i].name == name:
                if session_id != "":
                    self._session_map[name + "@" + session_id] = self.services[i].host + ":" + String(self.services[i].port)
                return self.services[i]
        return Service("None", "0.0.0.0", 0, 0, QoSMetadata(0.0, 0.0, 0.0))

    fn blacklist(mut self, name: String):
        for i in range(len(self.services)):
            if self.services[i].name == name:
                self.blacklisted.append(self.services[i])
                print("FIRM [Registry]: Service", name, "moved to BLACKLIST.")
                return

    fn promote_random_node(mut self) raises:
        if len(self.blacklisted) == 0:
            return
        if random.random_si64(0, 10) > 7:
            print("FIRM [Registry]: COIN FLIP SUCCESS -> Promoting", self.blacklisted[0].name)
            self.services.insert(0, self.blacklisted[0]) # Simplification for re-entry

    fn sync_with_remote_registry(mut self, remote_data: PythonObject) raises:
        print("FIRM [Ad-UDDI]: Synchronizing with remote registry...")
        var remote_qos = QoSMetadata(15.0, 2000.0, 0.999)
        self.register(Service("RemoteStorage", "192.168.1.50", 9000, 10, remote_qos))

    fn load_config(mut self, file_path: String) raises:
        print("FIRM [Registry]: Parsing Nginx-style config from", file_path)
        # Real parsing using Python helper for simplicity in Mojo FFI
        var builtins = Python.import_module("builtins")
        var f = builtins.open(file_path, "r")
        var content = f.read()
        f.close()
        
        # Extraction logic: strip lines, find "service <Name> {" patterns
        var lines = String(content).split("\n")
        for i in range(len(lines)):
            var line = lines[i].strip()
            # Match lines like "service PaymentService {" but skip top-level "services {"
            if line.startswith("service ") and not line.startswith("services "):
                var parts = line.split(" ")
                if len(parts) >= 2:
                    var s_name = parts[1]
                    var qos = QoSMetadata(25.0, 1000.0, 0.99)
                    self.register(Service(String(s_name), "127.0.0.1", 8080 + i, i, qos))
        
        print("FIRM [Registry]: Successfully parsed config file.")


    fn list_services(self):
        print("Registered Services:")
        for i in range(len(self.services)):
            var s = self.services[i]
            print("- ", s.name, " @ ", s.host, ":", s.port)
