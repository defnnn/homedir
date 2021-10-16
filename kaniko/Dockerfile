FROM k3d-hub.defn.ooo:5000/kaniko-project/executor:v1.6.0-debug

RUN ["/busybox/mkdir", "-p", "/bin"]
RUN ["/busybox/ln", "-s", "/busybox/sh", "/bin/sh"]

RUN mkdir -p /app
COPY . /app
