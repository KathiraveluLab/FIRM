from .common import Service, QoSMetadata
from utils.vector import DynamicVector

struct ServiceRegistry:
    var services: DynamicVector[Service]

    fn __init__(inout self):
        self.services = DynamicVector[Service]()

    fn register(inout self, service: Service):
        self.services.push_back(service)

    fn find(self, name: String) -> Service:
        # Simple linear search for research parity
        for i in range(len(self.services)):
            if self.services[i].name == name:
                return self.services[i]
        
        # Return a null-like placeholder if not found
        return Service("None", "None", QoSMetadata(0.0, 0.0, 0.0))

    fn list_services(self):
        print("Registered Services:")
        for i in range(len(self.services)):
            print("- ", self.services[i].name, " @ ", self.services[i].endpoint)
