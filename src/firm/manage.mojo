from .registry import ServiceRegistry
from .sdn_bridge import SDNBridge

struct QoSManager:
    var latency_limit: Float64
    var sdn: SDNBridge

    fn __init__(inout self, limit: Float64):
        self.latency_limit = limit
        self.sdn = SDNBridge()

    fn monitor_and_manage(inout self, inout registry: ServiceRegistry, service_name: String, current_latency: Float64) raises:
        print("FIRM [Manage]: Monitoring", service_name, "- Latency:", current_latency, "ms")
        
        # 1. Check for violation (Algorithm 2)
        if current_latency > self.latency_limit:
            print("FIRM [Manage]: QoS VIOLATION! Threshold of", self.latency_limit, "ms exceeded.")
            
            # 2. Blacklist the node in Registry
            registry.blacklist(service_name)
            
            # 3. Trigger SDN Reconfiguration
            self.sdn.reconfigure_node(service_name, "LOW_PRIORITY")
        
        # 4. Periodically Promote Nodes (Algorithm 3: Promoter Thread)
        registry.promote_random_node()
