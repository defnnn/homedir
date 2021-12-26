ARG IMAGE

FROM $IMAGE

RUN echo "nodejs 16.13.1" >> .tool-versions
RUN bin/env.sh asdf plugin-add nodejs
RUN bin/env.sh asdf install nodejs
