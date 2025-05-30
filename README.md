# G-Naira (gNGN) Token

A blockchain-based solution for the Nigerian financial system, implementing a regulated digital currency on the Base network. With a Multi-Sign(an approver) feature taking away total control away from the "GOVERNOR".

## Overview and Important Notice

G-Naira (gNGN) is a regulated digital currency built on the **Base network**, designed to enhance transparency and accountability in Nigeria's financial sector. The project implements a **multi-signature** system for minting and burning tokens, with role-based access control and compliance features. Like other StableCoins, such as Tether USDt(USDT), **gNGN does not have a fixed maximum supply**, the Central Bank can issue (mint) new gNGN based on market demands and reserves, and the supply can flucuate. **As of May 26, 2025, the current circulating supply of gNGN is approximately 10,000,000,000 gNGN.** The Central Bank reserves the right to **PAUSE** transactions on gNGN, as a pause feature was also integrated into the contract.

## Contract Information

### Base Sepolia Contract
- **Contract Address**: `0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378`
- **View Contract**: [Basescan Contract](https://sepolia.basescan.org/address/0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378)
- **View Contract Code**: [Verified Contract](https://sepolia.basescan.org/address/0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378#code)
- **View Events**: [Contract Events](https://sepolia.basescan.org/address/0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378#events)
- **View Test Transactions**: [Contract Transactions](https://sepolia.basescan.org/address/0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378#txs)

## Requirements

- Node.js (v14 or higher)
- npm or yarn
- MetaMask wallet
- Base Sepolia testnet ETH

## Project Structure

```
gngn-token/
├── contracts/
│   └── GNaira.sol
├── scripts/
│   └── deploy.js
├── .gitignore
├── README.md
├── hardhat.config.js
└── package.json
```

## Features

### Core Functionalities

1. **ERC20 Compliance**
   - Standard token implementation
   - Transfer and approval mechanisms
   - Balance tracking

2. **Multi-signature Minting**
   - Request-approve-execute flow
   - Time-based expiration (24h for approval, 48h for execution)
   - Role-based access control

3. **Multi-signature Burning**
   - Request-approve-execute flow
   - Balance verification
   - Time-based expiration

4. **Blacklist System**
   - Address-specific restrictions
   - Governor-controlled blacklisting
   - Transfer prevention for blacklisted addresses

5. **Pause Mechanism**
   - Emergency stop functionality
   - System-wide transaction prevention
   - Governor-controlled pause/unpause

### Role-Based Access Control

| Role | Description | Key Permissions | Changeable |
|------|-------------|----------------|------------|
| GOVERNOR_ROLE | Primary operational role | • Request mint/burn operations<br>• Execute approved operations<br>• Manage blacklist<br>• Control pause mechanism | Yes (by Admin) |
| Approver | Independent approval role | • Approve mint requests<br>• Approve burn requests | Yes (by Admin) |
| DEFAULT_ADMIN_ROLE | Administrative role | • Grant/revoke GOVERNOR_ROLE<br>• Change approver address<br>• Initial contract setup | No |

### Multi-Signature Features

#### Minting Process
| Step | Role | Action | Time Limit | Description |
|------|------|--------|------------|-------------|
| 1 | GOVERNOR_ROLE | Request Mint | N/A | Initiates mint request with target address and amount |
| 2 | Approver | Approve Mint | 24 hours | Approves the mint request |
| 3 | GOVERNOR_ROLE | Execute Mint | 48 hours | Executes the approved mint operation |

#### Burning Process
| Step | Role | Action | Time Limit | Description |
|------|------|--------|------------|-------------|
| 1 | GOVERNOR_ROLE | Request Burn | N/A | Initiates burn request with source address and amount |
| 2 | Approver | Approve Burn | 24 hours | Approves the burn request |
| 3 | GOVERNOR_ROLE | Execute Burn | 48 hours | Executes the approved burn operation |

#### Security Features
| Feature | Description | Control |
|---------|-------------|---------|
| Time-based Expiration | Requests expire if not approved within 24 hours or executed within 48 hours | Automatic |
| Role Separation | Governor cannot approve their own requests | Enforced by contract |
| Balance Verification | Burn requests verify sufficient balance before execution | Automatic |
| Blacklist Integration | All operations check against blacklist status | Automatic |

## Testing on Base Sepolia

### Prerequisites

1. **Setup Wallets**
   - Governor wallet
   - Approver wallet
   - Test user wallet
   - All wallets need Base Sepolia ETH

2. **Contract Address**
   - Deployed contract: `0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378`
   - View on [Basescan](https://sepolia.basescan.org/address/0x0aF4e2C83B26A42e8a9348Cb9681BCFFa767f378)

### Test Flow

1. **Minting Flow**
   ```
   a. Request Mint (Governor)
   - Connect Governor wallet
   - Call requestMint(to, amount) // (eg. 1000000000000000000, will mint 1 gNGN token with 18 decimals)
   - Note requestId from event

   b. Approve Mint (Approver)
   - Connect Approver wallet
   - Call approveMint(requestId)
   - Must be within 24 hours

   c. Execute Mint (Governor)
   - Connect Governor wallet
   - Call executeMint(requestId)
   - Must be within 48 hours
   ```

2. **Burning Flow**
   ```
   a. Request Burn (Governor)
   - Connect Governor wallet
   - Call requestBurn(from, amount)
   - Note requestId from event

   b. Approve Burn (Approver)
   - Connect Approver wallet
   - Call approveBurn(requestId)
   - Must be within 24 hours

   c. Execute Burn (Governor)
   - Connect Governor wallet
   - Call executeBurn(requestId)
   - Must be within 48 hours
   ```

3. **Blacklist Testing**
   ```
   a. Blacklist Address (Governor)
   - Connect Governor wallet
   - Call blacklist(address)
   - Verify transfers fail

   b. Remove from Blacklist (Governor)
   - Connect Governor wallet
   - Call removeFromBlacklist(address)
   - Verify transfers succeed
   ```

4. **Pause Testing**
   ```
   a. Pause Contract (Governor)
   - Connect Governor wallet
   - Call pause()
   - Verify all transfers fail

   b. Unpause Contract (Governor)
   - Connect Governor wallet
   - Call unpause()
   - Verify transfers succeed
   ```

## Development

### Installation

```bash
# Clone the repository
git clone https://github.com/kingsleycj/gngn-token.git

# Install dependencies
npm install

# Create .env file
cp .env.example .env
```

### Environment Variables

```env
PRIVATE_KEY=your_deployer_private_key
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
ETHERSCAN_API_KEY=your_basescan_api_key
```

### Deployment

```bash
# Compile contracts
npx hardhat compile

# Deploy to Base Sepolia
npx hardhat run scripts/deploy.js --network base_sepolia
```

### Deployment Preparation

Before deploying the contract, ensure you have the following wallets set up:

1. **Governor Wallet**
   - This wallet will have GOVERNOR_ROLE
   - Will be able to:
     - Request mint/burn operations
     - Execute approved operations
     - Manage blacklist
     - Control pause mechanism
   - Must have Base Sepolia ETH for gas fees

2. **Approver Wallet**
   - This wallet will be the approver address
   - Will be able to:
     - Approve mint requests
     - Approve burn requests
   - Must have Base Sepolia ETH for gas fees

3. **Deployer Wallet**
   - This wallet will have DEFAULT_ADMIN_ROLE
   - Will be able to:
     - Grant/revoke GOVERNOR_ROLE
     - Change approver address
   - Must have Base Sepolia ETH for deployment and gas fees

**Important**: The governor and approver addresses are set in the constructor and cannot be changed after deployment (except for the approver which can be changed by the admin). Make sure to use the correct addresses during deployment.

## Security Considerations

1. **Multi-signature Protection**
   - Two-step approval process
   - Time-based expiration
   - Role separation

2. **Access Control**
   - Role-based permissions
   - Admin controls
   - Blacklist system

3. **Emergency Controls**
   - Pause mechanism
   - Blacklist functionality
   - Time-based request expiration

## License

This project is licensed under the MIT License

## Contact

For any questions or concerns, please open an issue in the repository.

## Acknowledgments

- OpenZeppelin Contracts
- Base Network
- Hardhat

## Creator

[Kingsley Nweke](https://github.com/kingsleycj)