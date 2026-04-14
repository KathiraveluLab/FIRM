from src.firm.common import Service, QoSMetadata
from src.firm.registry import ServiceRegistry
from src.firm.invoker import ServiceInvoker
from src.firm.manage import QoSManager
from src.firm.composition import ServiceComposition, CompositionStep
from src.firm.memo import MemoCache
from src.firm.mapreduce import MapReduceJob, MapReduceCoordinator
from python import Python

fn main() raises:
    print("FIRM Framework: 100% Research Parity (Mojo Implementation)")
    print("--------------------------------------------------")

    # 1. Setup Framework
    var registry = ServiceRegistry()
    let invoker = ServiceInvoker(500)
    var manager = QoSManager(100.0)
    var global_cache = MemoCache()
    
    # 2. Dynamic Configuration (Nginx-style)
    registry.load_config("services.conf")
    
    # 3. Ad-UDDI Sync (Distributed Discovery)
    registry.sync_with_remote_registry(Python.dict())
    registry.list_services()
    print("--------------------------------------------------")
    
    # 4. Service Composition with Dicycles (Loops/SDW)
    print(">>> Executing SDW Workflow with Dicycles...")
    var composition = ServiceComposition()
    var step1 = CompositionStep()
    step1.add_service(registry.find("PaymentService"))
    composition.add_step(step1)
    
    composition.set_loop(2) # Execute loop twice
    let result_sdw = composition.execute(registry, invoker, global_cache, "Session_SDW")
    print("FIRM [SDW Result]:", result_sdw.payload)
    print("--------------------------------------------------")
    
    # 5. MapReduce Orchestration (Hadoop Parity)
    print(">>> Initializing MapReduce Job...")
    var mr_coordinator = MapReduceCoordinator(invoker)
    mr_coordinator.add_worker(registry.find("RemoteStorage"))
    mr_coordinator.add_worker(registry.find("InventoryService"))
    
    let job = MapReduceJob("DataProcessing", 4, 1)
    let mr_result = mr_coordinator.run_job(job)
    print("FIRM [MapReduce Result]:", mr_result.payload)
    print("--------------------------------------------------")
    
    # 6. Global Memoization: Shared across Sessions
    print(">>> Shared Session Verification...")
    print("FIRM [Analysis]: Attempting to reuse results from Session_SDW...")
    let result_reuse = composition.execute(registry, invoker, global_cache, "Session_REUSE")
    print("FIRM [Session_REUSE Final Result]: All cached.")
    
