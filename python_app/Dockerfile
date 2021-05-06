FROM python:3.10-rc-alpine
WORKDIR /app
COPY app /app
RUN pip install -r requirements.txt

CMD ["python3", "app.py"]
