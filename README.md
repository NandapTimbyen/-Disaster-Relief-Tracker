# 🌍 Disaster Relief Tracker Smart Contract

A transparent blockchain-based platform for managing and tracking disaster relief efforts.

## 🎯 Features

- 📊 Transparent donation tracking
- 🆔 Recipient verification system
- ✅ Volunteer-based verification
- 💸 Secure fund disbursement
- 📈 Real-time statistics

## 🚀 Contract Functions

### Administrative Functions
- `register-disaster`: Create new disaster relief campaigns
- `register-recipient`: Add verified aid recipients
- `register-volunteer`: Register trusted volunteers

### Donation Functions
- `donate`: Make donations to specific disaster relief efforts
- `create-disbursement`: Initialize aid disbursement
- `verify-disbursement`: Verify aid delivery

### Read-Only Functions
- `get-disaster-info`: View disaster campaign details
- `get-recipient-info`: Check recipient information
- `get-donation-info`: Track specific donations
- `get-total-donations`: View total donations received
- `get-total-disbursements`: Check total aid disbursed

## 💻 Usage

1. Deploy the contract using Clarinet
2. Register disasters through contract owner
3. Add recipients and volunteers
4. Accept donations and manage disbursements
5. Track all transactions on-chain

## 🔐 Security

- Owner-only administrative functions
- Verification requirements for disbursements
- Duplicate aid prevention
```

Git commit message:
```
feat: Implement Disaster Relief Tracker MVP with donation and verification system
```

PR Title:
```
✨ Add Disaster Relief Tracker Smart Contract MVP
```

PR Description:
```
This PR introduces the Disaster Relief Tracker smart contract MVP with the following features:

- Transparent donation management system
- Recipient registration and verification
- Volunteer-based disbursement verification
- Real-time tracking of donations and disbursements
- Administrative controls for disaster campaign management

The implementation includes:
- Core smart contract with essential functions
- Documentation with usage instructions
- Clean and minimal codebase focused on core functionality

Ready for review and testing.

