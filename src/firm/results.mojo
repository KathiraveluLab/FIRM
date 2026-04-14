struct InvocationResult:
    var payload: String
    var latency: Float64
    var status_code: Int
    var success: Bool

    fn __init__(inout self, payload: String, latency: Float64, status_code: Int, success: Bool):
        self.payload = payload
        self.latency = latency
        self.status_code = status_code
        self.success = success

    fn print_result(self):
        var status = "SUCCESS" if self.success else "FAILED"
        print("Result: ", status, " (", self.status_code, ") Latency: ", self.latency, "ms")
