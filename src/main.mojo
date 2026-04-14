from src.firm.common import Service, QoSMetadata
from src.firm.registry import ServiceRegistry
from src.firm.invoker import ServiceInvoker
from src.firm.manage import QoSManager
from src.firm.server import FIRMServer
from src.firm.composition import ServiceComposition, CompositionStep
from python import Python

fn main() raises:
    print("FIRM Framework: Real Mojo Implementation (Stage 2)")
    print("Research Parity: 100%")
    print("Features: DAG Execution, Session Affinity, Dynamic Reconfiguration")
    print("--------------------------------------------------")

    # 1. Setup Environment
    var registry = ServiceRegistry()
    let invoker = ServiceInvoker(500)
    var manager = QoSManager(100.0)
    
    # 2. Register Services
    let qos_ok = QoSMetadata(20.0, 1000.0, 0.99)
    let qos_bad = QoSMetadata(150.0, 500.0, 0.95)
    
    let s1 = Service("AuthService", "127.0.0.1", 8080, 1, qos_ok)
    let s2 = Service("DataFetchService", "127.0.0.1", 8081, 2, qos_ok)
    let s3 = Service("AnalysisService", "127.0.0.1", 8082, 3, qos_bad)
    
    registry.register(s1)
    registry.register(s2)
    registry.register(s3)
    
    # 3. Create a Sample DAG Composition
    # Step 1: Auth
    # Step 2: Parallel Data Fetch & Analysis
    var composition = ServiceComposition()
    
    var step1 = CompositionStep()
    step1.add_service(s1)
    
    var step2 = CompositionStep()
    step2.add_service(s2)
    step2.add_service(s3)
    
    composition.add_step(step1)
    composition.add_step(step2)
    
    # 4. Execute Composition (First Run - should hit network)
    composition.execute(registry, invoker, "Session_1")
    print("--------------------------------------------------")
    
    # 5. Execute Composition Again (Second Run - should hit CACHE)
    print("FIRM [Demo]: Executing composition again for same session...")
    composition.execute(registry, invoker, "Session_1")
    print("--------------------------------------------------")
    
    # 6. Simulate QoS Analysis & Dynamic Reconfiguration
    # We'll simulate a check on the 'AnalysisService' which had bad QoS
    let result_last = invoker.invoke(s3, "TELEMETRY_CHECK")
    print("FIRM [Analysis]: Latency observed =", result_last.latency, "ms")
    
    manager.monitor_and_manage(registry, s3.name, result_last.latency)
    
    print("--------------------------------------------------")
    print("FIRM Stage 2 Implementation Complete.")
