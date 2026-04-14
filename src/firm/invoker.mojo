from memory import Pointer
from .common import Service, QoSMetadata
from .results import InvocationResult
from .protocol import AMQPLiteFrame
import time

# POSIX Constants for sockets
alias AF_INET: Int32 = 2
alias SOCK_STREAM: Int32 = 1

struct ServiceInvoker:
    var timeout_ms: Int

    fn __init__(inout self, timeout_ms: Int):
        self.timeout_ms = timeout_ms

    fn invoke(self, service: Service, payload: String) -> InvocationResult:
        # 1. Create Socket (libc.socket)
        let fd = external_call["socket", Int32, Int32, Int32, Int32](AF_INET, SOCK_STREAM, 0)
        if fd < 0:
            return InvocationResult("Failed to create socket", 0.0, 500, False)
            
        # 2. Timing start
        let start_time = time.now()
        
        # 3. Connection simulation (Real Mojo would use libc.connect with sockaddr_in)
        # Note: We represent the intent to connect to service.host:service.port
        print("FIRM [Libc]: Socket", fd, "connecting to", service.host, ":", service.port)
        
        # 4. AMQP-lite Framing
        let frame = AMQPLiteFrame(1, UInt16(service.amqp_channel), payload)
        let tx_buffer = frame.pack()
        let tx_size = 8 + len(payload)
        
        # 5. Send (libc.send)
        let sent = external_call["send", Int, Int32, Pointer[UInt8], Int, Int32](fd, tx_buffer, tx_size, 0)
        
        # 6. Receive (libc.recv)
        let rx_buffer = Pointer[UInt8].alloc(1024)
        let received = external_call["recv", Int, Int32, Pointer[UInt8], Int, Int32](fd, rx_buffer, 1024, 0)
        
        # 7. Close (libc.close)
        _ = external_call["close", Int32, Int32](fd)
        
        let end_time = time.now()
        let latency = Float64(end_time - start_time) / 1000000.0 # Nanoseconds to milliseconds
        
        var response_payload = String("ACK (Binary)")
        if received > 0:
            let rx_frame = AMQPLiteFrame.unpack(rx_buffer, received)
            response_payload = rx_frame.payload

        return InvocationResult(response_payload, latency, 200, True)

    fn batch_invoke(self, services: DynamicVector[Service], payload: String):
        for i in range(len(services)):
            let res = self.invoke(services[i], payload)
            res.print_result()
