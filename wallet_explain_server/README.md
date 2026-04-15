# Blocklens Server

Serverpod backend that exposes:

- `GET /wallet/analyze?address=0x...`

## Setup

```bash
dart pub get
cp .env.example .env
# set ETHERSCAN_API_KEY and OPENAI_API_KEY

# if you have Serverpod CLI installed, regenerate protocol/endpoints if needed
# serverpod generate

dart run bin/main.dart --apply-migrations
```

## Response Shape

```json
{
  "address": "0x...",
  "insightSummary": "Mostly swaps and DeFi activity.",
  "transactions": [
    {
      "summary": "Swapped 0.5 ETH for USDC on Uniswap",
      "timestamp": 1712688000,
      "direction": "out",
      "status": "success"
    }
  ]
}
```
