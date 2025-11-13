POST https://api.kimi.com/coding/v1/chat/completions
Authorization: Bearer sk-kimi-2CZBLdpbBg3d7MJBeecNptq1lyO5OXLiaqxULqka8dP84LgYIexBcgBZaEnr5MW8
Content-Type: application/json

{
  "model": "kimi-for-coding",
  "messages": [
    { "role": "system", "content": "You are a helpful assistant." },
    { "role": "user", "content": "Write a message request example for OpenAI." }
  ],
  "temperature": 0.7
}
