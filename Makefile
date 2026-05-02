.PHONY: help build run test clean install docker-build docker-run docker-clean stop

help:
	@echo "Available commands:"
	@echo "  make install       - Install Python dependencies"
	@echo "  make run           - Run the Flask application locally"
	@echo "  make test          - Test the Flask application"
	@echo "  make build         - Build the project (install dependencies)"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-run    - Run Docker container"
	@echo "  make docker-clean  - Remove Docker image"
	@echo "  make stop          - Stop running containers"
	@echo "  make clean         - Clean up build artifacts"

install:
	pip install -r requirements.txt

build: install
	@echo "Build complete!"

run:
	python app.py

test:
	@echo "Running tests..."
	@echo "Starting Flask application in background..."
	@python app.py > /dev/null 2>&1 &
	@sleep 2
	@if curl -s http://localhost:5000/ > /dev/null 2>&1; then \
		echo "✓ Application is running successfully!"; \
		curl -s http://localhost:5000/; \
		make stop > /dev/null 2>&1; \
	else \
		echo "✗ Failed to connect to application on port 5000"; \
		make stop > /dev/null 2>&1; \
		exit 1; \
	fi

docker-build:
	docker build -t myapp .
	@echo "Docker image built successfully!"

docker-run:
	docker run -d -p 5000:5000 --name myapp-container myapp
	@echo "Docker container is running on port 5000"

docker-stop:
	docker stop myapp-container || true
	docker rm myapp-container || true
	@echo "Docker container stopped and removed"

stop:
	@pkill -f "python app.py" || echo "No running Flask processes found"

docker-clean: docker-stop
	docker rmi myapp || true
	@echo "Docker image removed!"

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "Cleaned up build artifacts"
