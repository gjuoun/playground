# Dockerfile
FROM oven/bun:1 
RUN bun install -g @anthropic-ai/claude-code
WORKDIR /workspace
CMD ["bash"]