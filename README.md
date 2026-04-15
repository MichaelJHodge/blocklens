# Blocklens

Production-lean MVP that converts recent Ethereum wallet activity into plain-English summaries.

## Monorepo Structure

- `wallet_explain_flutter/` Flutter mobile frontend (Riverpod, dark UI)
- `wallet_explain_server/` Serverpod backend (`GET /wallet/analyze?address=0x...`)

## Architecture

- Flutter sends wallet address to backend via REST.
- Serverpod route validates address, fetches raw transactions from Etherscan, normalizes data, and calls OpenAI for concise summaries.
- Backend returns user-friendly transaction summaries with timestamp, direction, and status.
- In-memory cache avoids repeated API + LLM calls for 5 minutes per wallet.

## API Keys Needed

- `ETHERSCAN_API_KEY`
- `OPENAI_API_KEY`

See `wallet_explain_server/.env.example`.

## Quick Start

### 1) Backend

```bash
cd wallet_explain_server
dart pub get
cp .env.example .env
# fill in real keys

dart run bin/main.dart --apply-migrations
```

Server route:

- `GET http://localhost:8082/wallet/analyze?address=0x...`

### 2) Flutter App

```bash
cd wallet_explain_flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8082
```

## Behavior and Edge Cases

- Invalid address: backend returns `400` + frontend form validation.
- No transactions: frontend shows `No recent transactions found`.
- API failure: retry dialog shown from loading screen.
- LLM failure: backend falls back to deterministic text summaries.

## Notes

- This MVP is read-only (no wallet connection, no key handling).
- For production hardening, add persistent cache (Redis/DB), observability, and stricter blockchain decoding for token transfers/swaps.
