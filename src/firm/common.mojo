from std.python import Python

struct QoSMetadata(ImplicitlyCopyable):
    var latency: Float64
    var throughput: Float64
    var reliability: Float64

    fn __init__(out self: Self, latency: Float64, throughput: Float64, reliability: Float64):
        self.latency = latency
        self.throughput = throughput
        self.reliability = reliability

    fn __copyinit__(out self: Self, *, copy: Self):
        self.latency = copy.latency
        self.throughput = copy.throughput
        self.reliability = copy.reliability

struct Service(ImplicitlyCopyable):
    var name: String
    var host: String
    var port: Int
    var amqp_channel: Int
    var qos: QoSMetadata

    fn __init__(out self: Self, name: String, host: String, port: Int, amqp_channel: Int, qos: QoSMetadata):
        self.name = name
        self.host = host
        self.port = port
        self.amqp_channel = amqp_channel
        self.qos = qos

    fn __copyinit__(out self: Self, *, copy: Self):
        self.name = copy.name
        self.host = copy.host
        self.port = copy.port
        self.amqp_channel = copy.amqp_channel
        self.qos = copy.qos

struct Node(ImplicitlyCopyable):
    var node_id: Int
    var capacity: Int
    var current_load: Int
    var is_active: Bool

    fn __init__(out self: Self, node_id: Int, capacity: Int):
        self.node_id = node_id
        self.capacity = capacity
        self.current_load = 0
        self.is_active = True

    fn __copyinit__(out self: Self, *, copy: Self):
        self.node_id = copy.node_id
        self.capacity = copy.capacity
        self.current_load = copy.current_load
        self.is_active = copy.is_active

    fn get_load_factor(self) -> Float64:
        return Float64(self.current_load) / Float64(self.capacity)
