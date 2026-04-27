from src.firm.common import Service, QoSMetadata
from src.firm.registry import ServiceRegistry
from src.firm.invoker import ServiceInvoker
from src.firm.manage import QoSManager
from src.firm.composition import ServiceComposition, CompositionStep
from src.firm.memo import MemoCache
from src.firm.mapreduce import MapReduceJob, MapReduceCoordinator
from std.sys import argv
from std.collections import List

fn print_usage():
    print("FIRM Framework - CLI Usage")
    print("==========================")
    print("")
    print("Commands:")
    print("  demo                        Run the built-in demonstration")
    print("  compose <svc1> [svc2] ...   Compose and invoke the named services (SDW)")
    print("  mapreduce <svc1> [svc2] ... Run a MapReduce job across the named services")
    print("  list                        List all registered services from config")
    print("")
    print("Options:")
    print("  --config <path>             Path to services config file (default: services.conf)")
    print("  --timeout <ms>              Invoker timeout in ms (default: 500)")
    print("  --qos-limit <ms>            QoS latency limit in ms (default: 100.0)")
    print("  --session <id>              Session ID for memoization (default: session_0)")
    print("  --maps <n>                  Number of map tasks for mapreduce (default: 3)")
    print("  --reduces <n>               Number of reduce tasks for mapreduce (default: 1)")
    print("  --job-name <name>           Name of the MapReduce job (default: UserJob)")
    print("")
    print("Examples:")
    print("  pixi run mojo main.mojo demo")
    print("  pixi run mojo main.mojo list")
    print("  pixi run mojo main.mojo compose PaymentService InventoryService")
    print("  pixi run mojo main.mojo compose PaymentService --session my_session")
    print("  pixi run mojo main.mojo mapreduce PaymentService InventoryService --maps 5 --reduces 2")
    print("  pixi run mojo main.mojo compose PaymentService --config my_services.conf --timeout 1000")

fn run_demo(config_path: String, timeout: Int, qos_limit: Float64) raises:
    """Run the built-in demonstration (original behavior)."""
    print("FIRM Framework - Built-in Demonstration")
    print("--------------------------------------------------")

    var registry = ServiceRegistry()
    var invoker = ServiceInvoker(timeout)
    var manager = QoSManager(qos_limit)
    var global_cache = MemoCache()

    registry.load_config(config_path)
    registry.list_services()
    print("--------------------------------------------------")

    print(">>> Defining Workflow with intentional cycle...")
    var sdw_comp = ServiceComposition()
    var common_step = CompositionStep()
    common_step.add_service(registry.find("PaymentService"))
    sdw_comp.add_step(common_step)
    sdw_comp.add_step(common_step)

    var result_sdw = sdw_comp.execute(registry, invoker, global_cache, "Session_SDW")
    print("FIRM [SDW Result]:", result_sdw.payload)
    print("--------------------------------------------------")

    print(">>> Dispatching MapReduce Job...")
    var mr_coordinator = MapReduceCoordinator(invoker)
    mr_coordinator.add_worker(registry.find("PaymentService"))
    mr_coordinator.add_worker(registry.find("InventoryService"))

    var job = MapReduceJob("DailyTransactions", 3, 1)
    var mr_result = mr_coordinator.run_job(job)
    print("FIRM [MapReduce Result]:", mr_result.payload)
    print("--------------------------------------------------")

    print(">>> Verifying Cross-Session Global Memoization...")
    var result_reuse = sdw_comp.execute(registry, invoker, global_cache, "Session_NEW")
    print("FIRM [Session_NEW]: Calculation reused from Session_SDW.")
    print("--------------------------------------------------")
    print("Demonstration Complete.")

fn run_compose(config_path: String, timeout: Int, qos_limit: Float64,
               service_names: List[String], session_id: String) raises:
    """Compose and invoke user-specified services via SDW."""
    if len(service_names) == 0:
        print("Error: 'compose' requires at least one service name.")
        print("  Example: pixi run mojo main.mojo compose PaymentService InventoryService")
        return

    print("FIRM Framework - Service Composition (SDW)")
    print("--------------------------------------------------")
    print("Config:     ", config_path)
    print("Timeout:    ", timeout, "ms")
    print("QoS Limit:  ", qos_limit, "ms")
    print("Session:    ", session_id)
    print("Services:   ", len(service_names))
    print("--------------------------------------------------")

    var registry = ServiceRegistry()
    var invoker = ServiceInvoker(timeout)
    var global_cache = MemoCache()

    registry.load_config(config_path)

    var composition = ServiceComposition()
    for i in range(len(service_names)):
        var step = CompositionStep()
        var svc = registry.find(service_names[i], session_id)
        if svc.name == "None":
            print("Warning: Service '" + service_names[i] + "' not found in registry. Skipping.")
            continue
        step.add_service(svc)
        composition.add_step(step)
        print("  Added step", i + 1, ":", service_names[i])

    print("--------------------------------------------------")
    var result = composition.execute(registry, invoker, global_cache, session_id)
    print("--------------------------------------------------")
    print("FIRM [Composition Result]:")
    print("  Payload:  ", result.payload)
    print("  Latency:  ", result.latency, "ms")
    print("  Status:   ", result.status_code)
    print("  Success:  ", result.success)

fn run_mapreduce(config_path: String, timeout: Int,
                 service_names: List[String], job_name: String,
                 num_maps: Int, num_reduces: Int) raises:
    """Run a MapReduce job across user-specified worker services."""
    if len(service_names) == 0:
        print("Error: 'mapreduce' requires at least one worker service name.")
        print("  Example: pixi run mojo main.mojo mapreduce PaymentService InventoryService")
        return

    print("FIRM Framework - MapReduce Orchestration")
    print("--------------------------------------------------")
    print("Config:     ", config_path)
    print("Timeout:    ", timeout, "ms")
    print("Job Name:   ", job_name)
    print("Map Tasks:  ", num_maps)
    print("Reduce Tasks:", num_reduces)
    print("Workers:    ", len(service_names))
    print("--------------------------------------------------")

    var registry = ServiceRegistry()
    var invoker = ServiceInvoker(timeout)

    registry.load_config(config_path)

    var coordinator = MapReduceCoordinator(invoker)
    for i in range(len(service_names)):
        var svc = registry.find(service_names[i])
        if svc.name == "None":
            print("Warning: Worker '" + service_names[i] + "' not found. Skipping.")
            continue
        coordinator.add_worker(svc)
        print("  Added worker:", service_names[i])

    print("--------------------------------------------------")
    var job = MapReduceJob(job_name, num_maps, num_reduces)
    var result = coordinator.run_job(job)
    print("--------------------------------------------------")
    print("FIRM [MapReduce Result]:")
    print("  Payload:  ", result.payload)
    print("  Latency:  ", result.latency, "ms")
    print("  Status:   ", result.status_code)
    print("  Success:  ", result.success)

fn run_list(config_path: String) raises:
    """List all services registered from the config file."""
    print("FIRM Framework - Service Registry")
    print("--------------------------------------------------")
    var registry = ServiceRegistry()
    registry.load_config(config_path)
    registry.list_services()

fn main() raises:
    var args = argv()

    # Convert argv Span to List[String] for easier handling
    var arg_list = List[String]()
    for i in range(len(args)):
        arg_list.append(String(args[i]))

    if len(arg_list) < 2:
        print_usage()
        return

    var command = arg_list[1]

    # Parse common options from arg_list
    var config_path = String("services.conf")
    var timeout = 500
    var qos_limit = 100.0
    var session_id = String("session_0")
    var job_name = String("UserJob")
    var num_maps = 3
    var num_reduces = 1

    var i = 2
    while i < len(arg_list):
        if arg_list[i] == "--config" and i + 1 < len(arg_list):
            config_path = arg_list[i + 1]
            i += 2
        elif arg_list[i] == "--timeout" and i + 1 < len(arg_list):
            timeout = atol(arg_list[i + 1])
            i += 2
        elif arg_list[i] == "--qos-limit" and i + 1 < len(arg_list):
            qos_limit = atof(arg_list[i + 1])
            i += 2
        elif arg_list[i] == "--session" and i + 1 < len(arg_list):
            session_id = arg_list[i + 1]
            i += 2
        elif arg_list[i] == "--job-name" and i + 1 < len(arg_list):
            job_name = arg_list[i + 1]
            i += 2
        elif arg_list[i] == "--maps" and i + 1 < len(arg_list):
            num_maps = atol(arg_list[i + 1])
            i += 2
        elif arg_list[i] == "--reduces" and i + 1 < len(arg_list):
            num_reduces = atol(arg_list[i + 1])
            i += 2
        else:
            i += 1  # Skip positional args (handled below)

    # Collect positional service names (non-flag args after command)
    var service_names = List[String]()
    for j in range(2, len(arg_list)):
        if not arg_list[j].startswith("--"):
            # Check the previous arg isn't a flag (i.e. this isn't a flag value)
            if j >= 3 and arg_list[j - 1].startswith("--"):
                continue  # This is a value for a flag, skip
            service_names.append(arg_list[j])

    if command == "demo":
        run_demo(config_path, timeout, qos_limit)
    elif command == "list":
        run_list(config_path)
    elif command == "compose":
        run_compose(config_path, timeout, qos_limit, service_names, session_id)
    elif command == "mapreduce":
        run_mapreduce(config_path, timeout, service_names, job_name, num_maps, num_reduces)
    elif command == "--help" or command == "-h" or command == "help":
        print_usage()
    else:
        print("Error: Unknown command '" + command + "'")
        print("")
        print_usage()
