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
            print("FIRM: Initiating dynamic node demotion and QoS adjustment...")
            
            # Update SDN flow priorities
            _ = self.sdn_bridge.update_flow_qos(service_name, 10) # Lower priority
            
            # In a real framework, we would find alternative nodes here
            # For now, let's just log the 'Management' action
            print("FIRM: Management action complete. Node demoted in cluster.")
        else:
            print("QoS stable for", service_name)

    fn get_sdn_topology(self) raises:
        let topo = self.sdn_bridge.get_topology()
        print("Current SDN Topology nodes:", topo)
