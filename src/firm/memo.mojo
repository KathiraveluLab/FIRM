from std.collections import Dict

struct MemoCache:
    var cache: Dict[String, String]

    fn __init__(out self: Self):
        self.cache = Dict[String, String]()

    fn get(self, service_name: String, payload: String) -> String:
        var key = service_name + "_" + payload
        if key in self.cache:
            try:
                return self.cache[key]
            except:
                return ""
        return ""

    fn set(mut self, service_name: String, payload: String, value: String):
        var key = service_name + "_" + payload
        self.cache[key] = value
