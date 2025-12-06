# Kimi API HURL file
# Preset variable defined below (can be overridden by CLI args or env vars)
# Usage: hurl kimi_api.hurl (uses preset)
#        hurl --variable api_key=new_key kimi_api.hurl (overrides preset)
#        KIMI_API_KEY=new_key hurl kimi_api.hurl (env var override)

# POST https://api.kimi.com/coding/v1/messages
# x-api-key: sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
# # anthropic-version: 2023-06-01
# content-type: application/json

# {
#   "model": "kimi-for-coding",
#   "max_tokens": 1024,
#   "messages": [
#     {
#       "role": "user",
#       "content": "Hello! How are you today?"
#     }
#   ]
# }


#! Anthropic API example 
# POST https://api.kimi.com/coding/v1/messages
# x-api-key: sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
# anthropic-version: 2023-06-01
# content-type: application/json

# {
#   "model": "kimi-for-coding",
#   "max_tokens": 1024,
#   "messages": [
#     { "role": "user", "content": "Write a message request example for Anthropic's Claude API." }
#   ]
# }

#! get models example
# GET https://api.kimi.com/coding/v1/models
# Authorization: Bearer sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
# Content-Type: application/json
# X-title: Kilo Code

#! OpenAI Chat API example
POST https://api.kimi.com/coding/v1/chat/completions
Authorization: Bearer sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
Content-Type: application/json
User-agent: Kilo-Code/4.119.2 # User-agent is needed

{
  "model": "kimi-for-coding",
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

