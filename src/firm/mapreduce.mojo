from std.collections import List
from .common import Service
from .invoker import ServiceInvoker
from .results import InvocationResult

struct MapReduceJob(ImplicitlyCopyable):
    var name: String
    var num_maps: Int
    var num_reduces: Int

    fn __init__(out self: Self, name: String, maps: Int, reduces: Int):
        self.name = name
        self.num_maps = maps
        self.num_reduces = reduces

    fn __copyinit__(out self: Self, *, copy: Self):
        self.name = copy.name
        self.num_maps = copy.num_maps
        self.num_reduces = copy.num_reduces

struct MapReduceCoordinator:
    var invoker: ServiceInvoker
    var workers: List[Service]

    fn __init__(out self: Self, invoker: ServiceInvoker):
        self.invoker = invoker
        self.workers = List[Service]()

    fn add_worker(mut self, worker: Service):
        self.workers.append(worker)

    fn run_job(self, job: MapReduceJob) raises -> InvocationResult:
        print("FIRM [MapReduce]: Initializing Job -", job.name)
        print("FIRM [MapReduce]: Total Tasks:", job.num_maps + job.num_reduces)
        
        if len(self.workers) == 0:
            return InvocationResult("FAILED: No Workers", 0.0, 500, False)

        # 1. Map Phase
        print("FIRM [MapReduce]: Starting MAP phase...")
        for i in range(job.num_maps):
            var worker = self.workers[i % len(self.workers)]
            _ = self.invoker.invoke(worker, "MAP_TASK_" + String(i))
        
        print("FIRM [MapReduce]: Map phase complete.")

        # 2. Shuffle & Reduce Phase
        print("FIRM [MapReduce]: Starting REDUCE phase...")
        for i in range(job.num_reduces):
            var worker = self.workers[i % len(self.workers)]
            _ = self.invoker.invoke(worker, "REDUCE_TASK_" + String(i))

        print("FIRM [MapReduce]: Job", job.name, "COMPLETED.")
        return InvocationResult("MapReduce Success for " + job.name, 120.5, 200, True)
