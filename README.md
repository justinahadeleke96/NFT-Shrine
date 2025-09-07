📄 README for NFT Shrine Contract

Overview

The NFT Shrine Contract is a Clarity smart contract that allows users to create, manage, and enhance digital shrines by sacrificing STX tokens. Each shrine is unique, with customizable metadata and power levels that grow as tokens are offered. The system tracks ownership, shrine details, and total contributions, enabling a gamified and collectible experience around shrine creation and token sacrifices.

✨ Features

Shrine Creation

Users can create shrines with a name and description by paying a creation fee.

Each shrine is assigned a unique ID.

Token Sacrifice

Owners can sacrifice STX tokens to their shrine.

Sacrifices increase the shrine’s power level proportionally to the amount offered.

The shrine records total tokens sacrificed and the last sacrifice block height.

Ownership Management

Shrines are owned by principals.

Owners can transfer shrines to new owners.

Ownership records are maintained per user.

Administrative Control

The contract owner can update the shrine creation fee.

Data Queries

Fetch shrine details by ID.

Get all shrine IDs owned by a user.

Retrieve shrine power level or total tokens sacrificed.

Get the next shrine ID available for creation.

⚙️ Key Functions

create-shrine (name description) → Creates a new shrine after transferring the creation fee.

sacrifice-tokens (shrine-id amount) → Sacrifices STX to increase shrine power.

transfer-shrine (shrine-id new-owner) → Transfers shrine ownership.

get-shrine (shrine-id) → Reads shrine details.

get-user-shrines (user) → Lists shrines owned by a principal.

get-shrine-power (shrine-id) → Returns a shrine’s current power level.

get-total-sacrificed (shrine-id) → Returns total tokens sacrificed to a shrine.

set-creation-fee (new-fee) → Admin-only function to update shrine creation fee.

🛑 Error Codes

u100 → Not the owner of the shrine.

u101 → Shrine not found.

u102 → Insufficient tokens.

u103 → Invalid amount (must be greater than 0).

u999 → List overflow when appending shrine IDs.

🚀 Example Flow

A user calls create-shrine "Sun Shrine" "A shrine devoted to the eternal sun".

The contract deducts the shrine creation fee and stores the shrine.

The user later calls sacrifice-tokens shrine-id u5000000 to empower the shrine.

The shrine’s power-level increases, and total tokens sacrificed is updated.

The user may transfer the shrine to another principal if desired.

🔑 Administrative Note

The contract owner (deployer) controls the shrine creation fee and receives all STX paid for shrine creation and sacrifices.