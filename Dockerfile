FROM golang:1.24-alpine

ARG UID=1000
ARG GID=1000

# Create a non-root user with the specified UID and GID
RUN addgroup -g ${GID} appgroup && adduser -u ${UID} -G appgroup -D appuser

WORKDIR /app

# Install anchor-go (as root, then change ownership if needed)
RUN go install github.com/gagliardetto/anchor-go@latest

# Add anchor-go to PATH
ENV PATH="/go/bin:${PATH}"

# Change ownership of the /app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Copy only the necessary JSON files
COPY *.json ./

# Command to be run by docker-compose
CMD ["/bin/sh", "-c", "for file in *.json; do anchor-go --idl "$file" --output "$(basename "$file" .json)"; done"]
