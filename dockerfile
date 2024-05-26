# Use a specific tag for the base image to ensure consistency
FROM tomcat:latest

# Set the working directory to the Tomcat webapps directory
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file into the Tomcat webapps directory
COPY vprofile-v2.war .

# Create a new user for running Tomcat (optional but recommended for security)
RUN groupadd -r tomcat && useradd -r -g tomcat -d /usr/local/tomcat -s /sbin/nologin tomcat

# Change ownership of the Tomcat directory to the new user
RUN chown -R tomcat:tomcat /usr/local/tomcat

# Expose the default Tomcat port
EXPOSE 8080

# Run Tomcat server
USER tomcat
CMD ["catalina.sh", "run"]
