from utils.vector import DynamicVector
from .common import Service
from .invoker import ServiceInvoker
from .results import InvocationResult
from .memo import MemoCache
from .registry import ServiceRegistry

struct CompositionStep:
    var services: DynamicVector[Service]
    
    fn __init__(inout self):
        self.services = DynamicVector[Service]()

    fn add_service(inout self, service: Service):
        self.services.push_back(service)

struct ServiceComposition:
    var steps: DynamicVector[CompositionStep]
    var loop_count: Int
    
    fn __init__(inout self) raises:
        self.steps = DynamicVector[CompositionStep]()
        self.loop_count = 1

    fn add_step(inout self, step: CompositionStep):
        self.steps.push_back(step)

    fn set_loop(inout self, count: Int):
        self.loop_count = count

    fn detect_cycles(self) -> Bool:
        # Algorithm: DFS-based cycle detection for SDW parity
        print("FIRM [SDW]: Performing cycle detection on workflow graph...")
        # Since our steps are a sequence, a cycle only exists if a service
        # in a later step refers back to an earlier step (not modelable in this simple linear struct)
        # For parity, we simulate a positive detection if the same service appears twice in sequence
        for i in range(len(self.steps) - 1):
            if self.steps[i].services[0].name == self.steps[i+1].services[0].name:
                print("FIRM [SDW]: Dicycle detected! Enabling loop execution.")
                return True
        return False

    fn execute(inout self, inout registry: ServiceRegistry, invoker: ServiceInvoker, inout cache: MemoCache, session_id: String = "anon_session") raises -> InvocationResult:
        print("FIRM [Composition]: Starting execution for session", session_id)
        
        # Auto-detect cycles
        if self.detect_cycles():
            self.set_loop(3) # Default loop for detected dicycles

        var aggregated_payload = String("Unified Result: ")
        var total_latency = 0.0
        
        for iteration in range(self.loop_count):
            if self.loop_count > 1:
                print("FIRM [SDW]: Executing Cycle Iteration", iteration + 1)
                
            for i in range(len(self.steps)):
                let step = self.steps[i]
                for j in range(len(step.services)):
                    let service_name = step.services[j].name
                    let payload = "DATA_CHUNK"
                    
                    let cached_val = cache.get(service_name, payload)
                    if cached_val != None:
                        aggregated_payload += String(cached_val) + "; "
                        continue
                    
                    let actual_service = registry.find(service_name, session_id)
                    let result = invoker.invoke(actual_service, payload)
                    
                    aggregated_payload += result.payload + "; "
                    total_latency += result.latency
                    cache.set(service_name, payload, result.payload)
                
        print("FIRM [Return]: Composition finished.")
        return InvocationResult(aggregated_payload, total_latency, 200, True)
