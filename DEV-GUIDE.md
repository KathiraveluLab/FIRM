# FIRM Development Guide

Welcome to the FIRM project development guide.

## Architecture Overview

FIRM is built primarily using **Mojo** to achieve bare-metal performance for service composition, dicycle execution, and built-in MapReduce orchestration. This departs from the original JVM/Hadoop-based architecture to provide maximum execution speed and concurrency.

### Python Interoperability (SDN Bridge)

While the core execution engine is fully Mojo-native, you will notice a Python file in the source tree: `src/firm/sdn_bridge.py`.

#### Why Python?
The Mojo language ecosystem is still maturing and currently lacks built-in, production-ready HTTP and JSON parsing libraries necessary for communicating with SDN controllers (like RYU) via their REST APIs.

To solve this, we leverage **Mojo's seamless Python interoperability**. The `sdn_bridge.py` script uses Python's `requests` and `json` libraries to perform the REST API calls.

#### How it works
In the Mojo codebase (e.g., `src/firm/manage.mojo`), the Python module is imported directly into the Mojo runtime:

```mojo
self.sdn = Python.import_module("sdn_bridge").SDNBridge()
```

When a service violates its QoS threshold, the Mojo `QoSManager` calls the Python bridge, which in turn sends a FlowMod request to the SDN controller.

### Best Practices
- **Mojo First**: Write all core logic, orchestration, and computational components in Mojo.
- **Python as a Bridge**: Only use Python for external API calls, libraries, or tools that do not yet exist in the Mojo standard library. Keep the Python footprints small and isolated (like the `sdn_bridge.py`).
