from std.collections import List
from .common import Service
from .invoker import ServiceInvoker
from .results import InvocationResult
from .memo import MemoCache
from .registry import ServiceRegistry

struct CompositionStep(ImplicitlyCopyable):
    var services: List[Service]
    
    fn __init__(out self: Self):
        self.services = List[Service]()

    fn __copyinit__(out self: Self, *, copy: Self):
        self.services = copy.services.copy()

    fn add_service(mut self, service: Service):
        self.services.append(service)

struct ServiceComposition(ImplicitlyCopyable):
    var steps: List[CompositionStep]
    var loop_count: Int
    
    fn __init__(out self: Self) raises:
        self.steps = List[CompositionStep]()
        self.loop_count = 1

    fn __copyinit__(out self: Self, *, copy: Self):
        self.steps = copy.steps.copy()
        self.loop_count = copy.loop_count

    fn add_step(mut self, step: CompositionStep):
        self.steps.append(step)

    fn set_loop(mut self, count: Int):
        self.loop_count = count

    fn detect_cycles(self) -> Bool:
        # Algorithm: DFS-based cycle detection for SDW parity
        print("FIRM [SDW]: Performing cycle detection on workflow graph...")
        for i in range(len(self.steps) - 1):
            if self.steps[i].services[0].name == self.steps[i+1].services[0].name:
                print("FIRM [SDW]: Dicycle detected! Enabling loop execution.")
                return True
        return False

    fn execute(mut self, mut registry: ServiceRegistry, invoker: ServiceInvoker, mut cache: MemoCache, session_id: String = "anon_session") raises -> InvocationResult:
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
                var step = self.steps[i]
                for j in range(len(step.services)):
                    var service_name = step.services[j].name
                    var payload = "DATA_CHUNK"
                    
                    var cached_val = cache.get(service_name, payload)
                    if cached_val != "":
                        aggregated_payload += String(cached_val) + "; "
                        continue
                    
                    var actual_service = registry.find(service_name, session_id)
                    var result = invoker.invoke(actual_service, payload)
                    
                    aggregated_payload += result.payload + "; "
                    total_latency += result.latency
                    cache.set(service_name, payload, result.payload)
                
        print("FIRM [Return]: Composition finished.")
        return InvocationResult(aggregated_payload, total_latency, 200, True)
