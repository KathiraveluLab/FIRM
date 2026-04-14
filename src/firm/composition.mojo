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
    var cache: MemoCache
    
    fn __init__(inout self) raises:
        self.steps = DynamicVector[CompositionStep]()
        self.cache = MemoCache()

    fn add_step(inout self, step: CompositionStep):
        self.steps.push_back(step)

    fn execute(inout self, inout registry: ServiceRegistry, invoker: ServiceInvoker, session_id: String = "anon_session") raises:
        print("FIRM [Composition]: Starting execution for session", session_id)
        
        for i in range(len(self.steps)):
            let step = self.steps[i]
            print("FIRM [Composition]: Step", i+1, "dispatched.")
            
            for j in range(len(step.services)):
                # Here we simulate the logic where we'd lookup a service by name
                # and use its host/port.
                let service_name = step.services[j].name
                let payload = "COMPOSITION_DATA_CHUNK"
                
                # 1. Check Cache (Memoization)
                let cached_val = self.cache.get(service_name, payload)
                if cached_val != None:
                    print("FIRM [Memo]: Cache Hit for", service_name, "-> SKIPPING Invocation")
                    continue
                
                # 2. Get Service from Registry with Session Affinity
                let actual_service = registry.find(service_name, session_id)
                
                # 3. Invoke (Real Networking)
                let result = invoker.invoke(actual_service, payload)
                print("FIRM [Step", i+1, "]:", service_name, "returned result.")
                
                # 4. Update Cache
                self.cache.set(service_name, payload, result.payload)
                
        print("FIRM [Composition]: Workflow finished.")
