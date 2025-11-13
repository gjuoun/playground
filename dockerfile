# Use official Node.js image
FROM node:24-slim

# Install system dependencies as root
USER root
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Create non-root developer user
RUN groupadd -r developer --gid=1001 && \
    useradd -r -g developer --uid=1001 --home-dir /home/developer --shell /bin/bash --create-home developer

# Create and set ownership of workspace
RUN mkdir -p /workspace && chown -R developer:developer /workspace
WORKDIR /workspace

# Switch to non-root user for npm configuration and installation
USER developer

# Configure npm to use user-specific directories
RUN mkdir -p /home/developer/.npm-global && \
    npm config set prefix '/home/developer/.npm-global'

# Add npm global bin to PATH
ENV PATH="/home/developer/.npm-global/bin:$PATH"

# Now install claude-code globally
RUN npm install -g @anthropic-ai/claude-code

# Switch back to root for final setup
USER root
COPY --chown=developer:developer . /workspace/

# Switch to non-root for running
USER developer
CMD ["claude", "--dangerously-skip-permissions"]
