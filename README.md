# spfa
Simple Python Flask App

It includes a minimal Flask-based web service containerized with Docker and orchestrated using Docker Compose.
Project Phase 1/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── spfa.py

File Overview:

Dockerfile
The Dockerfile builds a container image with the following actions:

-Creates a working directory called /SPFA
-Copies spfa.py and requirements.txt into the container
-Installs Python modules listed in requirements.txt using pip with --no-cache-dir
-Exposes port 5000 to allow external access
-Runs the spfa.py script as the container’s main process


docker-compose.yml
The docker-compose file handles the container lifecycle. It:

-Builds the image from the current directory
-Tags the image as spfa:v1a
-Maps container port 5000 to host port 5000 for web access

requirements.txt
This file specifies the dependencies for the project:
Flask==3.1.1

spfa.py
A simple Flask web server script that:

-Imports Flask
-Defines a route / that returns a “Hello, World!” message
-Uses app.run() to start the server if executed directly

*install docker*

1) run docker image:
docker pull ghcr.io/axio112/spfa:v1
2) run container:
docker run -p 5000:5000 ghcr.io/axio112/spfa:v1
3) Access the app at:
http://localhost:5000



