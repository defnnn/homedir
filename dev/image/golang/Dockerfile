ARG IMAGE

FROM $IMAGE

RUN echo "golang 1.17.5" >> .tool-versions
RUN bin/env.sh asdf plugin-add golang
RUN bin/env.sh asdf install golang

RUN make latest
