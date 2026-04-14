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
        print("FIRM [SDW]: Dicycle detected. Loop iteration count set to", count)

    fn execute(inout self, inout registry: ServiceRegistry, invoker: ServiceInvoker, inout cache: MemoCache, session_id: String = "anon_session") raises -> InvocationResult:
        print("FIRM [Composition]: Starting execution for session", session_id)
        
        var aggregated_payload = String("Unified Result: ")
        var total_latency = 0.0
        
        for iteration in range(self.loop_count):
            if self.loop_count > 1:
                print("FIRM [SDW]: Executing Loop Iteration", iteration + 1)
                
            for i in range(len(self.steps)):
                let step = self.steps[i]
                
                for j in range(len(step.services)):
                    let service_name = step.services[j].name
                    let payload = "DATA_CHUNK"
                    
                    # 1. Check Global Cache
                    let cached_val = cache.get(service_name, payload)
                    if cached_val != None:
                        aggregated_payload += String(cached_val) + "; "
                        continue
                    
                    # 2. Get Service with Affinity
                    let actual_service = registry.find(service_name, session_id)
                    
                    # 3. Invoke
                    let result = invoker.invoke(actual_service, payload)
                    
                    # 4. Aggregation & Cache Update
                    aggregated_payload += result.payload + "; "
                    total_latency += result.latency
                    cache.set(service_name, payload, result.payload)
                
        print("FIRM [Return]: Composing final response.")
        return InvocationResult(aggregated_payload, total_latency, 200, True)
