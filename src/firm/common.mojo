from python import Python

struct QoSMetadata:
    var latency: Float64
    var throughput: Float64
    var reliability: Float64

    fn __init__(inout self, latency: Float64, throughput: Float64, reliability: Float64):
        self.latency = latency
        self.throughput = throughput
        self.reliability = reliability

struct Service:
    var name: String
    var endpoint: String
    var qos: QoSMetadata

    fn __init__(inout self, name: String, endpoint: String, qos: QoSMetadata):
        self.name = name
        self.endpoint = endpoint
        self.qos = qos

struct Node:
    var node_id: Int
    var capacity: Int
    var current_load: Int
    var is_active: Bool

    fn __init__(inout self, node_id: Int, capacity: Int):
        self.node_id = node_id
        self.capacity = capacity
        self.current_load = 0
        self.is_active = True

    fn get_load_factor(self) -> Float64:
        return Float64(self.current_load) / Float64(self.capacity)
