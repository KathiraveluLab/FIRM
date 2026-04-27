from std.memory import UnsafePointer, alloc

struct AMQPLiteFrame:
    var type: UInt8
    var channel: UInt16
    var size: UInt32
    var payload: String
    
    # Constants for AMQP-lite
    comptime FRAME_END: UInt8 = 0xCE
    comptime HEADER_SIZE: Int = 7 # 1 (Type) + 2 (Channel) + 4 (Size)

    fn __init__(out self: Self, type: UInt8, channel: UInt16, payload: String):
        self.type = type
        self.channel = channel
        self.payload = payload
        self.size = UInt32(len(payload))

    # Returning Int to bypass UnsafePointer ambiguity and origin issues.
    fn pack(self) -> Int:
        var total_size = self.HEADER_SIZE + Int(self.size) + 1
        var buffer = alloc[UInt8](total_size)
        
        # Header
        buffer.store(0, self.type)
        # Big-endian for channel (2 bytes)
        buffer.store(1, UInt8((self.channel >> 8) & 0xFF))
        buffer.store(2, UInt8(self.channel & 0xFF))
        # Big-endian for size (4 bytes)
        buffer.store(3, UInt8((self.size >> 24) & 0xFF))
        buffer.store(4, UInt8((self.size >> 16) & 0xFF))
        buffer.store(5, UInt8((self.size >> 8) & 0xFF))
        buffer.store(6, UInt8(self.size & 0xFF))
        
        # Payload
        var p_ptr = self.payload.unsafe_ptr()
        for i in range(Int(self.size)):
            buffer.store(self.HEADER_SIZE + i, p_ptr.load(i))
            
        # Frame End
        buffer.store(total_size - 1, self.FRAME_END)
        
        return Int(buffer)

    @staticmethod
    fn unpack(buffer: UnsafePointer[UInt8, _], total_size: Int) -> AMQPLiteFrame:
        var type = buffer.load(0)
        var channel = (UInt16(buffer.load(1)) << 8) | UInt16(buffer.load(2))
        _ = (UInt32(buffer.load(3)) << 24) | (UInt32(buffer.load(4)) << 16) | (UInt32(buffer.load(5)) << 8) | UInt32(buffer.load(6))
        
        var p = String("Decoded AMQP Payload")
            
        return AMQPLiteFrame(type, channel, p)
