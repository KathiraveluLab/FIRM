from ffi import external_call

fn main():
    # socket(AF_INET, SOCK_STREAM, 0)
    # AF_INET = 2, SOCK_STREAM = 1
    let fd = external_call["socket", Int32, Int32, Int32, Int32](2, 1, 0)
    if fd < 0:
        print("Failed to create socket")
    else:
        print("Socket created with fd:", fd)
        # close(fd)
        _ = external_call["close", Int32, Int32](fd)
