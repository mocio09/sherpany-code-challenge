FROM python:3.11-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache libffi openssl
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Create a non-root user and switch to it
RUN adduser -D bot
USER bot

# Copy application code
COPY main.py .

EXPOSE 8080

CMD ["python", "main.py"]