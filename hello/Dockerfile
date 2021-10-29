FROM python:3.9.7

RUN mkdir -p /app

WORKDIR /app

RUN python -m venv /app/venv

COPY requirements.txt requirements.txt

RUN . venv/bin/activate && pip install -r requirements.txt

COPY main.py main.py

CMD [ "venv/bin/python", "main.py"]
