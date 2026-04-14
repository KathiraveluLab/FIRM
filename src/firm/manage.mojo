from python import Python
from .common import Service, QoSMetadata
from .registry import ServiceRegistry

struct QoSManager:
    var sdn_bridge: PythonObject
    var latency_threshold: Float64

    fn __init__(inout self, latency_threshold: Float64) raises:
        let bridge_module = Python.import_module("src.firm.sdn_bridge")
        self.sdn_bridge = bridge_module.get_bridge("http://localhost:8080")
        self.latency_threshold = latency_threshold

    fn monitor_and_manage(inout self, inout registry: ServiceRegistry, service_name: String, last_latency: Float64) raises:
        print("Monitoring QoS for", service_name, "...")
        
        if last_latency > self.latency_threshold:
            print("WARNING: Latency", last_latency, "ms exceeds threshold", self.latency_threshold, "ms")
            self.reconfigure_node(registry, service_name)
        else:
            print("QoS stable for", service_name)

    fn reconfigure_node(inout self, inout registry: ServiceRegistry, service_name: String) raises:
        print("FIRM [Manage]: Initiating dynamic reconfiguration for", service_name)
        
        # 1. Update SDN flow table (simulated via Python bridge)
        _ = self.sdn_bridge.update_flow_qos(service_name, 100) # High priority for failover
        
        # 2. Find alternative deployment in Registry (Simulation of paper Algorithm 2)
        # In a real scenario, we'd look for a node with lower load
        print("FIRM [Manage]: Reconfiguring Registry -> Mapping", service_name, "to Failover Node (127.0.0.1:9090)")
        
        # For demo purposes, we'll just log the action
        print("FIRM [Manage]: Dynamic reconfiguration complete.")

    fn get_sdn_topology(self) raises:
        let topo = self.sdn_bridge.get_topology()
        print("Current SDN Topology nodes:", topo)
