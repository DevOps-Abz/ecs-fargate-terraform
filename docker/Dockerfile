# Use the official python image as a base
FROM --platform=linux/amd64 python:3.9-slim

# Set the working directory
WORKDIR /program

# Copy contents of the current directory to /app in the container
COPY program.py .

# Command to run the application
CMD ["python", "program.py"]