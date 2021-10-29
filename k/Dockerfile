FROM k3d-hub.defn.ooo:5000/defn/home:home

COPY .index /tmp/.index

RUN mkdir -p .password-store
RUN sudo chown app:app .password-store
RUN chmod 700 .password-store
