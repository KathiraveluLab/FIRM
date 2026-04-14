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
    
    fn __init__(inout self) raises:
        self.steps = DynamicVector[CompositionStep]()

    fn add_step(inout self, step: CompositionStep):
        self.steps.push_back(step)

    fn execute(inout self, inout registry: ServiceRegistry, invoker: ServiceInvoker, inout cache: MemoCache, session_id: String = "anon_session") raises -> InvocationResult:
        print("FIRM [Composition]: Starting execution for session", session_id)
        
        var aggregated_payload = String("Result Set: ")
        var total_latency = 0.0
        
        for i in range(len(self.steps)):
            let step = self.steps[i]
            print("FIRM [Composition]: Step", i+1, "dispatched.")
            
            for j in range(len(step.services)):
                let service_name = step.services[j].name
                let payload = "DATA"
                
                # 1. Check Global Cache (Memoization)
                let cached_val = cache.get(service_name, payload)
                if cached_val != None:
                    print("FIRM [Memo]: Global Cache Hit for", service_name, "-> REUSING RESULT")
                    aggregated_payload += String(cached_val) + "; "
                    continue
                
                # 2. Get Service from Registry with Session Affinity
                let actual_service = registry.find(service_name, session_id)
                
                # 3. Invoke (Real Networking)
                let result = invoker.invoke(actual_service, payload)
                print("FIRM [Step", i+1, "]:", service_name, "returned result.")
                
                # 4. Update Global Cache & Aggregate
                aggregated_payload += result.payload + "; "
                total_latency += result.latency
                cache.set(service_name, payload, result.payload)
                
        print("FIRM [Composition]: Workflow finished.")
        return InvocationResult(aggregated_payload, total_latency, 200, True)
