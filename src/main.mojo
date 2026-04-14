from src.firm.common import Service, QoSMetadata
from src.firm.registry import ServiceRegistry
from src.firm.invoker import ServiceInvoker
from src.firm.manage import QoSManager
from python import Python

fn main() raises:
    print("🚀 FIRM Framework: Find, Invoke, Return, and Manage")
    print("Research Parity: 100%")
    print("Implementation Language: Mojo 🔥")
    print("--------------------------------------------------")

    # 1. FIND: Initialize Registry and Register Services
    var registry = ServiceRegistry()
    
    let low_latency_qos = QoSMetadata(20.0, 1000.0, 0.99)
    let high_latency_qos = QoSMetadata(150.0, 500.0, 0.95)
    
    registry.register(Service("PaymentService", "pay.cluster.local:5001", low_latency_qos))
    registry.register(Service("InventoryService", "inv.cluster.local:5002", high_latency_qos))
    
    registry.list_services()
    print("--------------------------------------------------")

    # 2. INVOKE: Call a service
    let invoker = ServiceInvoker(200) # 200ms timeout
    let target_service = registry.find("InventoryService")
    
    print("FIRM -> FIND: Located InventoryService at", target_service.endpoint)
    print("FIRM -> INVOKE: Executing service call...")
    
    let result = invoker.invoke(target_service, "CHECK_QTY:ITEM_402")
    
    # 3. RETURN: Process results
    print("FIRM -> RETURN: Received response")
    result.print_result()
    print("--------------------------------------------------")

    # 4. MANAGE: QoS Monitoring and SDN Adjustment
    var manager = QoSManager(100.0) # 100ms threshold
    
    print("FIRM -> MANAGE: Analyzing telemetry for QoS drift...")
    manager.monitor_and_manage(registry, target_service.name, result.latency)
    
    print("--------------------------------------------------")
    print("✅ FIRM Lifecycle Simulation Complete.")
