# Stage 1: Build environment
# Use rocker/r-apt:bionic as the base image (sourced from: https://stackoverflow.com/questions/51500385/how-to-speed-up-r-packages-installation-in-docker)
FROM rocker/r-apt:bionic AS builder

# Install necessary build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	curl \
	libssl-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	wget \
	llvm \
	libgdbm-dev \
	liblzma-dev \
	python3 \
	python3-pip \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python 2.7
RUN curl -O https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
	tar -xzf Python-2.7.18.tgz && \
	cd Python-2.7.18 && \
	./configure --enable-optimizations --without-tests && \
	make && \
	make install && \
	cd .. && \
	rm -rf Python-2.7.18 Python-2.7.18.tgz

# Install pip for Python 2
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
	python2.7 get-pip.py && \
	rm get-pip.py

# Set up a working directory
WORKDIR /app

# Copy requirements file first (to take advantage of caching)
COPY requirements.txt requirements.txt

# Install Python 3 dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the infinite_loop.py script into the image
COPY infinite_loop.py .

# Stage 2: Runtime environment
FROM ubuntu:22.04

# Install only the necessary runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	python3 \
	python2.7 \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up a working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/bin/python2.7 /usr/local/bin/
COPY --from=builder /usr/local/bin/pip2 /usr/local/bin/
COPY --from=builder /usr/bin/python3 /usr/bin/
COPY --from=builder /app/requirements.txt /app/
COPY --from=builder /app/infinite_loop.py /app/

# Command to run the infinite_loop.py script using Python 3
CMD ["python3", "infinite_loop.py"]
