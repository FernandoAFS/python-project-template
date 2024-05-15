ARG PYTHON_VERSION=3.11


# COMPILER
FROM python:${PYTHON_VERSION} AS builder_base
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}

# THIS WORKS FOR NOW... MAYBE MOVE TO PIPX IN THE MID TERM.
RUN pip install -U pip setuptools wheel
RUN pip install pdm

COPY pyproject.toml pdm.lock README.md 
COPY src/ /project/src

# install dependencies and project into the local packages directory
WORKDIR /project


FROM builder_base AS builder
RUN mkdir __pypackages__ && pdm sync --no-editable


FROM builder_base AS lab_builder
RUN mkdir __pypackages__ && pdm sync -G lab --no-editable


# run stage
FROM python:${PYTHON_VERSION} as runner-base
ARG APP_VERSION
ARG UID=999
ARG GID=999
ENV UID=${UID}
ENV GID=${GID}

RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu tini; \
	rm -rf /var/lib/apt/lists/*; \
    groupadd --gid ${UID} app; \
    useradd --uid ${UID}  -g app -b /project -M -s /bin/sh app;

WORKDIR /project
# retrieve packages from build stage

COPY py/dist/docker/docker-entrypoint.sh /project/entrypoint.sh

ENV OFFERS_VERSION=${APP_VERSION}
ENV OFFERS_REVISION=${APP_REVISION}

ENV PYTHONPATH=/project/pkgs
ENV USER="999:999"
ENV EEMS_VERSION=${EEMS_VERSION}
ENV PATH="/opt/venv/bin:$PATH"

ENTRYPOINT ["./entrypoint.sh"]


# ==========
# LAB RUNNER
# ==========

FROM runner-base as lab
ARG PYTHON_VERSION=3.11

VOLUME [ "/data", "/notebooks" ]
ENV LAB_DATA="/data"
ENV LAB_NOTEBOOKS="/notebooks"
ENV JUPYTER_CONFIG_DIR="/jupyter-config"
EXPOSE 8888

COPY /py/dist/docker/jupyter_lab_config.py /jupyter-config/jupyter_lab_config.py
COPY --from=lab-builder /project/__pypackages__/${PYTHON_VERSION}/lib /project/pkgs
COPY --from=lab-builder /project/__pypackages__/${PYTHON_VERSION}/bin/* /bin/

# ROOM FOR IMPROVEMENT HERE. TRY TO BUILD ELSEWHERE. NOT VERY BAD SINCE IT'S NOT MEAN FOR PRODUCTION
RUN mkdir -p /jupyter-config; \
	apt-get update; \
	apt-get install -y npm nodejs; \
	rm -rf /var/lib/apt/lists/*; \
    mkdir -p src; \
    jupyter lab build

CMD [ "lab" ]


# ==========
# BACKEND
# ==========

FROM runner-base as backend
ARG PYTHON_VERSION=3.11
ARG APP_PATH
ENV APP_PATH=${APP_PATH}

ARG UVICORN_HOST="0.0.0.0"
ARG UVICORN_PORT="8000"
ENV UVICORN_HOST=${UVICORN_HOST}
ENV UVICORN_PORT=${UVICORN_PORT}
EXPOSE 8000

# ADAPT TO YOUR PROJECT.
HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://127.0.0.1/ping || exit 1

COPY --from=builder /project/__pypackages__/${PYTHON_VERSION}/lib /project/pkgs
COPY --from=builder /project/__pypackages__/${PYTHON_VERSION}/bin/* /bin/

CMD [ "backend" ]
