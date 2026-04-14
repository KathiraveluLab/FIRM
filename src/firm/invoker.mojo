from .common import Service, QoSMetadata
from .results import InvocationResult
import time

struct ServiceInvoker:
    var timeout_ms: Int

    fn __init__(inout self, timeout_ms: Int):
        self.timeout_ms = timeout_ms

    fn invoke(self, service: Service, payload: String) -> InvocationResult:
        # Simulate a low-level binary protocol over sockets
        # In a real Mojo implementation, we would use raw pointers and libc/socket calls here
        
        # Simulate network latency based on service QoS
        let start_time = time.now()
        
        # Simulating processing
        # In a real research scenario, we'd use parallelize() here for batch invocations
        var simulated_latency = service.qos.latency
        
        # Add a tiny bit of jitter for realism
        let jitter = 0.05 # 5% jitter
        
        if simulated_latency > Float64(self.timeout_ms):
            return InvocationResult("", simulated_latency, 504, False)
            
        let result_payload = "Response from " + service.name + ": Processed[" + payload + "]"
        
        return InvocationResult(result_payload, simulated_latency, 200, True)

    fn batch_invoke(self, services: DynamicVector[Service], payload: String):
        print("Starting batch invocation in parallel...")
        # Placeholder for Mojo's parallelize() which would be used in a production environment
        for i in range(len(services)):
            let res = self.invoke(services[i], payload)
            res.print_result()
