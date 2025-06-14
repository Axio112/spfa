FROM python:3.11-alpine

WORKDIR /SPFA

COPY spfa.py .
COPY requirements.txt .

RUN pip3 install --upgrade pip && pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python3", "spfa.py"]
