""" Metacontroller hook: creates a number of pods depending on the time. """

import json
from http.server import BaseHTTPRequestHandler, HTTPServer

# from pprint import pprint


class Controller(BaseHTTPRequestHandler):
    """webhook"""

    def sync(self, parent, children, controller):
        """returns desired state: set of pods, increasing each time the hook
        is called."""

        who = parent.get("spec", {}).get("who", "World")
        pod_count = parent.get("spec", {}).get("count", 1)
        greeting = "Hello" if who == "defn" else "Hi"
        parent_id = controller["metadata"]["uid"]
        parent_name = parent["metadata"]["name"]

        desired_pods = []
        for pod_index in range(pod_count):
            new_pod = {
                "apiVersion": "v1",
                "kind": "Pod",
                "metadata": {"name": f"{parent_name}-{parent_id}-{pod_index}"},
                "spec": {
                    "restartPolicy": "OnFailure",
                    "containers": [
                        {
                            "name": "hello",
                            "image": "busybox",
                            "command": [
                                "sh",
                                "-c",
                                f"echo {greeting}, {who}!; exec sleep 30",
                            ],
                        }
                    ],
                },
            }
            desired_pods.append(new_pod)

        desired_status = {
            "pods": len(children["Pod.v1"])
        }

        return {"status": desired_status, "children": desired_pods}

    def do_POST(self):
        """Serve the sync() function as a JSON webhook."""
        content_length = int(self.headers.get("content-length"))
        observed = json.loads(self.rfile.read(content_length))
        desired = self.sync(
            observed["parent"], observed["children"], observed["controller"]
        )

        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(desired).encode())


HTTPServer(("", 80), Controller).serve_forever()
