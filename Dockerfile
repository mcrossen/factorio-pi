FROM --platform=$TARGETPLATFORM alekitto/qemu-user-static as arm
FROM --platform=linux/amd64 ubuntu:latest as x86

# Copy the x86 emulator for arm hosts into the image
COPY --from=arm --chown=root:root /usr/bin/qemu-x86_64-static /usr/bin/

# Install necessary dependencies
RUN apt update \
    && apt install wget xz-utils jq -y

# Create user to run server as
RUN adduser factorio
USER factorio
WORKDIR /home/factorio/

# Download and setup factorio server
RUN wget https://www.factorio.com/get-download/stable/headless/linux64 -O factorio-server.tar.xz \
    && tar -xJf factorio-server.tar.xz \
    && mv factorio/* ./ \
    && rm factorio-server.tar.xz \
    && rmdir factorio \
    && mkdir saves settings \
    && jq '.name="factorio-pi" | .description="factorio server on my raspberry pi" \
        | .require_user_verification=false | .visibility.public=false' \
        data/server-settings.example.json > settings/server-settings.json \
    && chown -R factorio:factorio /home/factorio/

# Run factorio server
ENTRYPOINT ["/usr/bin/qemu-x86_64-static", "bin/x64/factorio", "--start-server-load-latest", "saves/", "--server-settings", "settings/server-settings.json"]