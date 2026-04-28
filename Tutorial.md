# FIRM Framework Tutorial

This tutorial walks you through using the FIRM (Framework for Integrated Resource Management) command-line interface to compose services, run MapReduce jobs, and explore the framework's features.

## Prerequisites

Ensure you have completed the installation steps from the [README](README.md):

```bash
bash setup.sh
pixi shell
```

Verify the environment is working:

```bash
pixi run mojo main.mojo help
```

## 1. Listing Available Services

Before composing or dispatching jobs, inspect which services are available in your configuration:

```bash
pixi run mojo main.mojo list
```

**Expected output:**

```
FIRM Framework - Service Registry
--------------------------------------------------
FIRM [Registry]: Parsing Nginx-style config from services.conf
FIRM [Registry]: Successfully parsed config file.
Registered Services:
-  PaymentService  @  127.0.0.1 : 8081
-  InventoryService  @  127.0.0.1 : 8087
-  AnalysisService  @  127.0.0.1 : 8093
-  MathNode  @  127.0.0.1 : 8097
-  GraphNode  @  127.0.0.1 : 8100
```

You can point to a different config file using `--config`:

```bash
pixi run mojo main.mojo list --config my_services.conf
```

## 2. Service Composition (SDW Workflow)

The `compose` command lets you build a Software-Defined Workflow (SDW) by specifying which services to chain together. Each service you name becomes a step in the composition pipeline.

### Basic composition

Compose two services sequentially:

```bash
pixi run mojo main.mojo compose PaymentService InventoryService
```

**Expected output:**

```
FIRM Framework - Service Composition (SDW)
--------------------------------------------------
Config:      services.conf
Timeout:     500 ms
QoS Limit:   100.0 ms
Session:     session_0
Services:    2
--------------------------------------------------
FIRM [Registry]: Parsing Nginx-style config from services.conf
FIRM [Registry]: Successfully parsed config file.
  Added step 1 : PaymentService
  Added step 2 : InventoryService
--------------------------------------------------
FIRM [Composition]: Starting execution for session session_0
FIRM [SDW]: Performing cycle detection on workflow graph...
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8081
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8087
FIRM [Return]: Composition finished.
--------------------------------------------------
FIRM [Composition Result]:
  Payload:   Unified Result: ACK (Binary); ACK (Binary);
  Latency:   0.031 ms
  Status:    200
  Success:   True
```

### Composition with a named session

Session IDs enable the memoization cache. Re-running the same composition under the same session will reuse cached results:

```bash
pixi run mojo main.mojo compose PaymentService InventoryService --session order_session
```

### Composition with custom timeout

Increase the socket timeout for slow networks:

```bash
pixi run mojo main.mojo compose PaymentService --timeout 2000
```

### Multi-service workflow

Chain three or more services:

```bash
pixi run mojo main.mojo compose PaymentService InventoryService MathNode GraphNode
```

## 3. MapReduce Orchestration

The `mapreduce` command dispatches a Hadoop-style MapReduce job across the named worker services.

### Basic MapReduce

```bash
pixi run mojo main.mojo mapreduce PaymentService InventoryService
```

### Custom job configuration

Specify the number of map/reduce tasks and a job name:

```bash
pixi run mojo main.mojo mapreduce PaymentService InventoryService MathNode --maps 5 --reduces 2 --job-name AnalyticsJob
```

**Expected output:**

```
FIRM Framework - MapReduce Orchestration
--------------------------------------------------
Config:      services.conf
Timeout:     500 ms
Job Name:    AnalyticsJob
Map Tasks:   5
Reduce Tasks: 2
Workers:     3
--------------------------------------------------
FIRM [Registry]: Parsing Nginx-style config from services.conf
FIRM [Registry]: Successfully parsed config file.
  Added worker: PaymentService
  Added worker: InventoryService
  Added worker: MathNode
--------------------------------------------------
FIRM [MapReduce]: Initializing Job - AnalyticsJob
FIRM [MapReduce]: Total Tasks: 7
FIRM [MapReduce]: Starting MAP phase...
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8081
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8087
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8097
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8081
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8087
FIRM [MapReduce]: Map phase complete.
FIRM [MapReduce]: Starting REDUCE phase...
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8081
FIRM [Libc]: Socket 18 connecting to 127.0.0.1 : 8087
FIRM [MapReduce]: Job AnalyticsJob COMPLETED.
--------------------------------------------------
FIRM [MapReduce Result]:
  Payload:   MapReduce Success for AnalyticsJob
  Latency:   120.5 ms
  Status:    200
  Success:   True
```

Tasks are round-robin distributed across the workers you specify.

## 4. Running the Built-in Demo

The `demo` command runs the original hardcoded demonstration, exercising all framework features end-to-end (SDW with dicycle detection, MapReduce, and memoization verification):

```bash
pixi run mojo main.mojo demo
```

## 5. Running Benchmarks

The benchmark measures composition latency over 100 iterations and reports statistics aligned with Figure 6 of the FIRM paper:

```bash
pixi run mojo benchmark.mojo
```

**Expected output:**

```
--------------------------------------------------
FIRM BENCHMARK RESULTS (Figure 6 Parity)
Total Requests: 100
Average Completion Time (ms): 0.0004
Standard Deviation (ms): 0.0047
Status: VALID - Reproduces paper benchmark metrics.
--------------------------------------------------
```

## 6. Defining Custom Services

Services are defined in an Nginx-style configuration file (`services.conf` by default):

```nginx
services {
    service PaymentService {
        type simple;
        endpoint 127.0.0.1:8080;
        amqp_channel 1;
        latency_threshold 50.0;
    }
    service InventoryService {
        type simple;
        endpoint 127.0.0.1:8081;
        amqp_channel 2;
        latency_threshold 100.0;
    }
}
```

To add a new service, add a `service <Name> { ... }` block inside the `services` block. Then reference it by name in `compose` or `mapreduce` commands.

You can maintain multiple config files for different environments and switch between them:

```bash
pixi run mojo main.mojo compose MyServiceA MyServiceB --config production.conf
```

## CLI Reference

| Command | Description |
|---|---|
| `help` | Print usage information |
| `demo` | Run the built-in demonstration |
| `list` | List all registered services |
| `compose <svc> ...` | Compose and invoke named services (SDW) |
| `mapreduce <svc> ...` | Run a MapReduce job across named workers |

| Option | Description | Default |
|---|---|---|
| `--config <path>` | Path to services config file | `services.conf` |
| `--timeout <ms>` | Invoker timeout in milliseconds | `500` |
| `--qos-limit <ms>` | QoS latency limit in milliseconds | `100.0` |
| `--session <id>` | Session ID for memoization | `session_0` |
| `--maps <n>` | Number of map tasks (mapreduce) | `3` |
| `--reduces <n>` | Number of reduce tasks (mapreduce) | `1` |
| `--job-name <name>` | MapReduce job name | `UserJob` |

