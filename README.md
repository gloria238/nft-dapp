# SimpleNFT DApp

A full-stack NFT minting platform built with **Next.js 14**, **Wagmi v2**, and **Viem**. Users can connect their wallet, mint ERC-721 NFTs with custom metadata, and browse all minted tokens in a live gallery — all with clean, maintainable Web3 UX.

🔗 **Live Demo**: _https://nft-dapp.vercel.app_   
📦 **Smart Contracts**: Solidity 0.8.20 (Hardhat), located in `/contract`

---

## 🚀 Features

- ✅ **Wallet Connection** – MetaMask, Rabby, or any injected provider via Wagmi's `injected()` connector.
- ✅ **ERC-721 Minting** – Payable `mint()` with real-time transaction state tracking (`idle → pending → confirming → success/error`).
- ✅ **Automatic Refund** – Contract returns any excess ETH above `mintPrice` back to the sender on-chain.
- ✅ **Live NFT Gallery** – Reads `nextTokenId` from the contract and renders all tokens with owner address and metadata image.
- ✅ **Multi-format tokenURI Parsing** – Handles base64-encoded JSON, plain JSON, and direct image URL fallback.
- ✅ **Network Guard** – Blocks all contract interaction if the wallet is on the wrong chain. No silent failures.
- ✅ **Derived Toast State** – Error and success notifications derived directly from hook state — zero `useEffect` syncing, zero stale-state bugs.
- ✅ **Fully Typed** – TypeScript strict mode with generic `useContractRead<T>` hook and function overloads for per-function arg type safety.

---

## 🖼️ Screenshots

> _Add screenshots here_

---

## 🛠 Tech Stack

| Layer               | Technology                                       |
| :------------------ | :----------------------------------------------- |
| **Frontend**        | Next.js 14 (App Router)                          |
| **Language**        | TypeScript (strict mode)                         |
| **Web3 SDK**        | Wagmi v2 + Viem                                  |
| **Async State**     | TanStack Query (via Wagmi)                       |
| **Smart Contracts** | Solidity 0.8.20 · OpenZeppelin ERC721URIStorage  |
| **Dev Network**     | Hardhat (local) · Sepolia (testnet)              |
| **Deployment**      | Vercel (frontend) · Hardhat Ignition (contracts) |

---

## 📁 Project Structure

```
simple-nft/
├── contract/                    # Hardhat project
│   ├── contracts/
│   │   └── SimpleNFT.sol        # ERC721URIStorage + Ownable
│   ├── ignition/modules/
│   │   └── SimpleNFT.ts         # Ignition deployment module
│   └── hardhat.config.ts
│
└── frontend/                    # Next.js application
    └── src/
        ├── app/                 # App Router pages & layout
        │   ├── layout.tsx       # Global nav + Providers wrapper
        │   ├── page.tsx         # Home (entry point)
        │   ├── mint/
        │   │   └── page.tsx     # Mint page (wallet-gated)
        │   └── gallery/
        │       └── page.tsx     # NFT gallery with sort toggle
        ├── components/
        │   ├── mint/
        │   │   └── MintForm.tsx       # Core mint UI
        │   ├── nft/
        │   │   └── NFTCard.tsx        # Token display card
        │   ├── ui/
        │   │   ├── Button.tsx
        │   │   ├── Toast.tsx
        │   │   └── Skeleton.tsx
        │   └── web3/
        │       ├── WalletButton.tsx   # Connect / disconnect
        │       ├── NetworkGuard.tsx   # Chain ID enforcement
        │       └── TxStatus.tsx       # Transaction status display
        ├── hooks/
        │   ├── useContractRead.ts     # Generic typed contract reads
        │   └── useMint.ts             # Write + lifecycle state machine
        └── config/
            ├── contracts.ts           # CONTRACT_ADDRESS + ABI
            └── wagmi.ts               # Wagmi createConfig
```

---

## 🧩 Key Engineering Highlights

### 1. Generic Typed Contract Read Hook

All contract reads go through a single `useContractRead<T>` hook with TypeScript function overloads. Each function name is mapped to its exact argument signature at compile time — passing `ownerOf` without a `[bigint]` arg is a type error, not a runtime failure.

```typescript
// Correct — no args needed
useContractRead<bigint>({ functionName: "mintPrice" });

// Correct — tokenId required
useContractRead<string>({ functionName: "tokenURI", args: [BigInt(id)] });

// ❌ Type error at compile time — missing args
useContractRead<string>({ functionName: "tokenURI" });
```

### 2. Derived State — Zero useEffect for Toast

Instead of syncing `isSuccess` or `error` into a separate state via `useEffect` (which risks stale state and double-firing in React Strict Mode), `MintForm` computes the toast value directly during render:

```typescript
const autoToast = error
  ? { message: error, type: "error" }
  : isSuccess
  ? { message: "Mint success!", type: "success" }
  : null;

// Manual toast (e.g. "enter a URI") takes priority
const toast = manualToast ?? autoToast;
```

This follows the React single-source-of-truth principle and eliminates an entire category of state synchronization bugs.

### 3. Multi-Format tokenURI Parser

NFT metadata can live in multiple formats. `NFTCard` handles all of them with a graceful fallback chain:

```
data:application/json;base64,…  →  atob() + JSON.parse()  →  extract image + name
plain JSON string                →  JSON.parse() directly  →  extract image + name
anything else                    →  treat URI as direct image URL (fallback)
```

### 4. Network Guard at the Provider Level

`NetworkGuard` wraps the entire child tree inside `Providers`. The moment a user switches to the wrong chain, the whole UI unmounts and a switch-network prompt renders — no component-level chain checks needed, no silent wrong-network contract calls.

### 5. Transaction Lifecycle State Machine

`useMint` exposes a precise state machine rather than a single `loading` boolean:

```
idle → isPending (wallet prompt) → isConfirming (block wait) → isSuccess / error
```

Button copy, disabled state, and Toast content all derive from this machine — the UI always reflects exactly where in the transaction lifecycle the user is.

---

## 🔧 Local Development

### Prerequisites

- Node.js 18+
- MetaMask or Rabby wallet
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/simple-nft.git
cd simple-nft
```

### 2. Start Local Blockchain

```bash
cd contract
npm install
npx hardhat node
```

Keep this terminal running — it starts a local Ethereum node on `http://127.0.0.1:8545` and prints 20 funded test accounts.

### 3. Deploy Contracts

Open a new terminal:

```bash
cd contract
npx hardhat ignition deploy ./ignition/modules/SimpleNFT.ts --network localhost
```

Copy the printed contract address and paste it into `frontend/src/config/contracts.ts`:

```typescript
export const CONTRACT_ADDRESS = "0x<your-deployed-address>";
```

### 4. Run the Frontend

```bash
cd ../frontend
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### 5. Connect Wallet

Add the Hardhat local network to MetaMask:

| Field           | Value                   |
| :-------------- | :---------------------- |
| Network Name    | Hardhat Local           |
| RPC URL         | `http://127.0.0.1:8545` |
| Chain ID        | `31337`                 |
| Currency Symbol | ETH                     |

Import a test account using one of the private keys printed in the Hardhat terminal.

---

## 🚢 Deployment

### Frontend (Vercel)

```bash
cd frontend
npx vercel --prod
```

### Contracts (Sepolia Testnet)

1. Add your RPC URL and deployer private key to `hardhat.config.ts`.

2. Deploy:

```bash
npx hardhat ignition deploy ./ignition/modules/SimpleNFT.ts --network sepolia
```

3. Update `CONTRACT_ADDRESS` in `frontend/src/config/contracts.ts` with the new address.

4. In `frontend/src/config/wagmi.ts`, switch the chain from `localhost` to `sepolia`:

```typescript
import { sepolia } from "wagmi/chains";

export const config = createConfig({
  chains: [sepolia],
  transports: { [sepolia.id]: http() },
});
```

5. In `frontend/src/components/web3/NetworkGuard.tsx`, update `TARGET_CHAIN`:

```typescript
const TARGET_CHAIN = 11155111; // Sepolia
```

---

## 📄 Smart Contract

`SimpleNFT.sol` inherits from OpenZeppelin's `ERC721URIStorage` and `Ownable`.

| Function                | Access     | Description                                                  |
| :---------------------- | :--------- | :----------------------------------------------------------- |
| `mint(string tokenURI)` | Public     | Mints one NFT. Requires `msg.value >= mintPrice`. Refunds excess ETH. |
| `setMintPrice(uint256)` | Owner only | Updates the mint price.                                      |
| `withdraw()`            | Owner only | Transfers contract balance to owner.                         |
| `mintPrice()`           | View       | Returns current mint price in wei.                           |
| `nextTokenId()`         | View       | Returns total number of tokens minted.                       |
| `tokenURI(uint256)`     | View       | Returns metadata URI for a given token.                      |
| `ownerOf(uint256)`      | View       | Returns current owner address of a token.                    |

---

## 📝 License

MIT

---

## 👤 Author

**Danni Han (Gloria)**  
Web3 Frontend Developer  
📧 gloria_2384619@proton.me  
💬 Discord: gloria01744  
🔗 GitHub: [github.com/gloria238](https://github.com/gloria238)
