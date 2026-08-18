FROM python:3.10

WORKDIR /app

COPY . .

RUN pip install flask pytest

EXPOSE 80

CMD ["python", "app.py"]