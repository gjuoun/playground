

#! get models example
GET https://api.z.ai/api/paas/v4/models
Authorization: Bearer cdd234508ec74ab7aeaeef2f0af8dc19.1FkRn6EOoddvHqQF
Content-Type: application/json

HTTP 200

#! Anthropic API example 
POST https://api.z.ai/api/anthropic/v1/messages
authorization: Bearer cdd234508ec74ab7aeaeef2f0af8dc19.1FkRn6EOoddvHqQF
anthropic-version: 2023-06-01
content-type: application/json

{
  "model": "glm-4.5-air",
  "max_tokens": 1024,
  "messages": [
    { "role": "user", "content": "Write a message request example for Anthropic's Claude API." }
  ]
}
HTTP 200

# #! OpenAI Chat API example
POST https://api.z.ai/api/paas/v4/chat/completions
Authorization: Bearer cdd234508ec74ab7aeaeef2f0af8dc19.1FkRn6EOoddvHqQF
Content-Type: application/json
User-agent: Kilo-Code/4.119.2 # User-agent is needed
X-title: Kilo Code

{
  "model": "glm-4.5-air",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "Hello! How are you today?"
    }
  ],
  "max_tokens": 150,
  "temperature": 0.7
}

HTTP 200