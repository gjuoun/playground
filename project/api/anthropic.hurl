POST https://api.kimi.com/coding/v1/messages
x-api-key: sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
# authorization: sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
anthropic-version: 2023-06-01
content-type: application/json

{
  "model": "kimi-for-coding",
  "max_tokens": 1024,
  "messages": [
    { "role": "user", "content": "Write a message request example for Anthropic's Claude API." }
  ]
}