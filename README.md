Disaster Relief Tracker Smart Contract

A transparent blockchain-based platform for managing and tracking disaster relief efforts.

## 🎯 Features

- 📊 Transparent donation tracking
- 🆔 Recipient verification system
- ✅ Volunteer-based verification
- 💸 Secure fund disbursement
- 📈 Real-time statistics
- 👥 Volunteer assignment system
- 🔍 Decentralized recipient verification by assigned volunteers

## 🚀 Contract Functions

### Administrative Functions
- `register-disaster`: Create new disaster relief campaigns
- `register-recipient`: Add verified aid recipients
- `register-volunteer`: Register trusted volunteers
- `assign-volunteer-to-disaster`: Assign volunteers to specific disasters
- `unassign-volunteer-from-disaster`: Remove volunteer assignments

### Verification Functions
- `verify-recipient`: Allow assigned volunteers to verify recipients for their disaster

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
- `is-volunteer-assigned`: Check volunteer assignment status

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
Revolutionize disaster response coordination with our cutting-edge volunteer assignment system! 🌟 This innovative feature empowers administrators to seamlessly link dedicated volunteers with specific disaster campaigns, creating a more structured and accountable relief ecosystem.

Dive deep into the mechanics: our system introduces a robust mapping mechanism that tracks volunteer-disaster relationships with precision. By enabling owner-controlled assignments and unassignments, we ensure only authorized personnel can manage these critical connections. The read-only query function provides instant visibility into assignment status, supporting real-time decision-making.

Key enhancements include:
- 🔗 Direct volunteer-to-disaster linkages
- 🛡️ Owner-gated assignment controls
- 📊 Transparent assignment tracking
- ⚡ Efficient query capabilities

#DisasterRelief #BlockchainInnovation #VolunteerCoordination #SmartContracts

Ready for review and testing.

