# SA_General_Questions_Assessment

1. Create an image with python2, python3, R, install a set of requirements and upload it to
   docker hub.

2. For the previously created image
   a. Share build times
   docker build -t dmesa2/sa_assessment:latest .
   Building 23.9s (22/22) FINISHED

   b. How would you improve build times?
   The installation of r-base was the primary bottleneck affecting build times. Initially, I started with a standard Ubuntu image and attempted to install the necessary packages. However, after nearly an hour of building, I recognized the need for a different approach. Through research on Stack Overflow, I discovered an existing Docker image with R pre-installed, which significantly accelerated the process. I then added Python 2 and 3 and implemented a multi-stage build strategy to ensure that the final Docker image is lean, containing only the essential binaries.

3. Scan the recently created container and evaluate the CVEs that it might contain.
   a. Create a report of your findings and follow best practices to remediate the CVE
   b. What would you do to avoid deploying malicious packages?

4. Use the created image to create a kubernetes deployment with a command that will
   keep the pod running

5. Expose the deployed resource

6. Every step mentioned above have to be in a code repository with automated CI/CD

7. How would you monitor the above deployment? Explain or implement the tools that you
   would use
