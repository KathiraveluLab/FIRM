from .registry import ServiceRegistry
from std.python import Python, PythonObject

struct QoSManager:
    var latency_limit: Float64
    var sdn: PythonObject

    fn __init__(out self: Self, limit: Float64) raises:
        self.latency_limit = limit
        # Importing sdn_bridge.py as a Python module
        var sys = Python.import_module("sys")
        sys.path.append("src/firm")
        self.sdn = Python.import_module("sdn_bridge").SDNBridge()

    fn monitor_and_manage(mut self, mut registry: ServiceRegistry, service_name: String, current_latency: Float64) raises:
        print("FIRM [Manage]: Monitoring", service_name, "- Latency:", current_latency, "ms")
        
        # 1. Check for violation (Algorithm 2)
        if current_latency > self.latency_limit:
            print("FIRM [Manage]: QoS VIOLATION! Threshold of", self.latency_limit, "ms exceeded.")
            
            # 2. Blacklist the node in Registry
            registry.blacklist(service_name)
            
            # 3. Trigger SDN Reconfiguration
            _ = self.sdn.reconfigure_node(service_name, "LOW_PRIORITY")
        
        # 4. Periodically Promote Nodes (Algorithm 3: Promoter Thread)
        registry.promote_random_node()
