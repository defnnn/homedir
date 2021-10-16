""" Metacontroller hook: creates a number of pods depending on the time. """

from http.server import BaseHTTPRequestHandler, HTTPServer
from pprint import pprint
import json


class Controller(BaseHTTPRequestHandler):
    """webhook"""

    POD_COUNT = 0

    def sync(self, parent, children, controller):
        """returns desired state: set of pods, increasing each time the hook
        is called."""

        who = parent.get("spec", {}).get("who", "World")
        greeting = "Hello" if who == "defn" else "Hi"
        parent_id = controller["metadata"]["uid"]
        Controller.POD_COUNT += 1
        parent_name = parent["metadata"]["name"]

        desired_pods = []
        pprint(Controller.POD_COUNT)
        for _ in range(Controller.POD_COUNT):
            new_pod = {
                "apiVersion": "v1",
                "kind": "Pod",
                "metadata": {"name": f"{parent_name}-{parent_id}"},
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

        return {"status": Controller.POD_COUNT, "children": desired_pods}

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