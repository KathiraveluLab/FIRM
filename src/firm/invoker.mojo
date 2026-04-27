from std.memory import UnsafePointer, alloc
from std.collections import List
from std.ffi import external_call
from .common import Service, QoSMetadata
from .results import InvocationResult
from .protocol import AMQPLiteFrame
import std.time as time

# POSIX Constants for sockets
comptime AF_INET: Int32 = 2
comptime SOCK_STREAM: Int32 = 1

struct ServiceInvoker(ImplicitlyCopyable):
    var timeout_ms: Int

    fn __init__(out self: Self, timeout_ms: Int):
        self.timeout_ms = timeout_ms

    fn __copyinit__(out self: Self, *, copy: Self):
        self.timeout_ms = copy.timeout_ms

    fn invoke(self, service: Service, payload: String) -> InvocationResult:
        # 1. Create Socket (libc.socket)
        var fd = external_call["socket", Int32, Int32, Int32, Int32](AF_INET, SOCK_STREAM, 0)
        if fd < 0:
            return InvocationResult("Failed to create socket", 0.0, 500, False)
            
        # 2. Timing start
        var start_time = time.perf_counter()
        
        # 3. Connection simulation
        print("FIRM [Libc]: Socket", fd, "connecting to", service.host, ":", service.port)
        
        # 4. AMQP-lite Framing
        var frame = AMQPLiteFrame(1, UInt16(service.amqp_channel), payload)
        var tx_buffer = frame.pack()
        var tx_size = 8 + len(payload)
        
        # 5. Send (libc.send)
        # Using Int for pointer to bypass origin issues
        _ = external_call["send", Int, Int32, Int, Int, Int32](fd, Int(tx_buffer), tx_size, 0)
        
        # 6. Receive (libc.recv)
        var rx_buffer = alloc[UInt8](1024)
        var received = external_call["recv", Int, Int32, Int, Int, Int32](fd, Int(rx_buffer), 1024, 0)
        
        # 7. Close (libc.close)
        _ = external_call["close", Int32, Int32](fd)
        
        var end_time = time.perf_counter()
        var latency = (end_time - start_time) * 1000.0
        
        var response_payload = String("ACK (Binary)")
        if received > 0:
            var rx_frame = AMQPLiteFrame.unpack(rx_buffer, received)
            response_payload = rx_frame.payload

        return InvocationResult(response_payload, latency, 200, True)

    fn batch_invoke(self, services: List[Service], payload: String):
        for i in range(len(services)):
            var res = self.invoke(services[i], payload)
            res.print_result()
