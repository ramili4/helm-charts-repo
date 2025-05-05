FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода
COPY dns_exporter.py .

# Создание директории для файла с доменами
RUN mkdir -p /etc/dns_exporter

# Порт для Prometheus
EXPOSE 9369

# Запуск экспортера
CMD ["python", "dns_exporter.py"]
