from memory import Pointer
from utils.vector import DynamicVector

struct AMQPLiteFrame:
    var type: UInt8
    var channel: UInt16
    var size: UInt32
    var payload: String
    
    # Constants for AMQP-lite
    alias FRAME_END: UInt8 = 0xCE
    alias HEADER_SIZE: Int = 7 # 1 (Type) + 2 (Channel) + 4 (Size)

    fn __init__(inout self, type: UInt8, channel: UInt16, payload: String):
        self.type = type
        self.channel = channel
        self.payload = payload
        self.size = len(payload)

    fn pack(self) -> Pointer[UInt8]:
        let total_size = self.HEADER_SIZE + Int(self.size) + 1
        let buffer = Pointer[UInt8].alloc(total_size)
        
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
        let p_ptr = self.payload._as_ptr()
        for i in range(Int(self.size)):
            buffer.store(self.HEADER_SIZE + i, p_ptr.load(i))
            
        # Frame End
        buffer.store(total_size - 1, self.FRAME_END)
        
        return buffer

    @staticmethod
    fn unpack(buffer: Pointer[UInt8], total_size: Int) -> AMQPLiteFrame:
        let type = buffer.load(0)
        let channel = (UInt16(buffer.load(1)) << 8) | UInt16(buffer.load(2))
        let size = (UInt32(buffer.load(3)) << 24) | (UInt32(buffer.load(4)) << 16) | (UInt32(buffer.load(5)) << 8) | UInt32(buffer.load(6))
        
        # Extract payload string simulation (in real Mojo we'd have a helper for this)
        var p = String("Decoded AMQP Payload")
            
        return AMQPLiteFrame(type, channel, p)
