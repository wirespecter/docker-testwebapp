FROM golang:1.15.1 AS builder

# ----------- Environment variables -----------------
ENV applicationName="serverTest"
ENV workingDir=/home/nexus/go/src/testwebapp/
# ----------- Environment variables -----------------


# set a directory for the app
WORKDIR $workingDir

# copy all the files to the container
COPY . .

# build the Go app
RUN go build -o $applicationName .





# alpine-based images have fewer vulnerabilities than full-blown system OS images
FROM alpine:3.12.0

# ----------- Environment variables -----------------
ENV restrictedUsername="golang"
ENV applicationName="serverTest"
ENV workingDir=/home/nexus/go/src/testwebapp/
# ----------- Environment variables -----------------


# Install dependencies required to run our application
RUN apk add --no-cache libc6-compat

# create a less-privileged user
RUN adduser --disabled-password --gecos "" --home "/home/$restrictedUsername/" --uid "12345" "$restrictedUsername"

# change working directory to that user's home folder
WORKDIR /home/$restrictedUsername/

# copy the binary file from previous stage
COPY --from=builder $workingDir/$applicationName .
# copy all subdirectories that hold resources ("html, css, javascript, etc.")
COPY --from=builder $workingDir/static/ ./static/

# restrict user's directory a bit
RUN chown root:root /home/$restrictedUsername/
# change ownership to our new user (apply only to directories where app needs to write data like file uploads)
# RUN chown -R $restrictedUsername:$restrictedUsername /home/$restrictedUsername/

# expose the port
EXPOSE 3000

# switch to that user
USER $restrictedUsername

# run the application
CMD ["sh", "-c", "./$applicationName"]