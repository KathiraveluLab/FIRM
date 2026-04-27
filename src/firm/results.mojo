struct InvocationResult(ImplicitlyCopyable):
    var payload: String
    var latency: Float64
    var status_code: Int
    var success: Bool

    fn __init__(out self: Self, payload: String, latency: Float64, status_code: Int, success: Bool):
        self.payload = payload
        self.latency = latency
        self.status_code = status_code
        self.success = success

    fn __copyinit__(out self: Self, *, copy: Self):
        self.payload = copy.payload
        self.latency = copy.latency
        self.status_code = copy.status_code
        self.success = copy.success

    fn print_result(self):
        var status = "SUCCESS" if self.success else "FAILED"
        print("Result: ", status, " (", self.status_code, ") Latency: ", self.latency, "ms")
