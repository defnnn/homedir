from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime
from pprint import pprint
import json

class Controller(BaseHTTPRequestHandler):
  def sync(self, parent, children, controller):
    # Compute status based on observed state.
    desired_status = {
      "pods": len(children["Pod.v1"])
    }

    # Generate the desired child object(s).
    who = parent.get("spec", {}).get("who", "World")
    greeting = "Hello" if who == "defn" else "Hi"
    parentId = controller["metadata"]["uid"]
    desired_pods = [
      {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
          "name": "%s-%s" % (parent["metadata"]["name"], parentId)
        },
        "spec": {
          "restartPolicy": "OnFailure",
          "containers": [
            {
              "name": "hello",
              "image": "busybox",
              "command": ["sh", "-c", "echo %s, %s!; exec sleep 30" % (greeting, who)]
            }
          ]
        }
      }
    ]

    return {"status": desired_status, "children": desired_pods}

  def do_POST(self):
    # Serve the sync() function as a JSON webhook.
    observed = json.loads(self.rfile.read(int(self.headers.get("content-length"))))
    desired = self.sync(observed["parent"], observed["children"], observed["controller"])

    self.send_response(200)
    self.send_header("Content-type", "application/json")
    self.end_headers()
    self.wfile.write(json.dumps(desired).encode())

HTTPServer(("", 80), Controller).serve_forever()

