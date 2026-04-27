import requests
import json

class SDNBridge:
    def __init__(self, controller_url="http://localhost:8080"):
        self.controller_url = controller_url

    def get_topology(self):
        """Fetches the current network topology from RYU."""
        try:
            # Example RYU REST API call for switches
            response = requests.get(f"{self.controller_url}/stats/switches")
            if response.status_code == 200:
                return response.json()
            return []
        except Exception as e:
            print(f"SDN Bridge Error: {e}")
            return []

    def update_flow_qos(self, service_id, priority):
        """Updates flow priority via the SDN controller."""
        print(f"SDN: Updating QoS for {service_id} to priority {priority}")
        # Logic to send FlowMod messages via RYU REST API
        return True

    def reconfigure_node(self, service_id, priority):
        """Alias for update_flow_qos to match FIRM manager nomenclature."""
        return self.update_flow_qos(service_id, priority)

def get_bridge(url):
    return SDNBridge(url)
