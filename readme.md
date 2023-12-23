# README for Baby Creed (BCR) Token Contract

## Overview
The Baby Creed (BCR) Token is an ERC20 token with a total supply of 1.5 trillion tokens. This contract includes unique tax features that apply to transactions, part of which contributes to the project's sustainability and liquidity.

- **Website:** [https://creed-one.com/baby-creed](https://creed-one.com/baby-creed)
- **Whitepaper:** [https://bit.ly/BabyCreedPaper](https://bit.ly/BabyCreedPaper)
- **Telegram:** [https://t.me/BabyCreedToken](https://t.me/BabyCreedToken)
- **Twitter X:** [https://twitter.com/creedfinance1](https://twitter.com/creedfinance1)
- **Github Contracts:** [https://github.com/ArielRin/BCR-Baby-Creed](https://github.com/ArielRin/BCR-Baby-Creed)
- **Test Contract:** [https://testnet.bscscan.com/token/0xfcc19802278A60217Cc671599Ca601222B4b9230#code](https://testnet.bscscan.com/token/0xfcc19802278A60217Cc671599Ca601222B4b9230#code)

![The Defiant Little Assassin](https://raw.githubusercontent.com/ArielRin/BCR-Baby-Creed/master/bcrcoinswallassassin.jpg)

## Tax Features
### Distribution of Taxes
- **3% Treasury Fee:** Each transaction contributes 3% to the Treasury. These funds are earmarked for the project's long-term development and sustainability.
- **2% Auto Liquidity Pool (LP) Fee:** An additional 2% fee is added to the liquidity pool automatically. This strengthens the token's liquidity, ensuring stability and reducing price volatility.

### Reflections
- The contract also includes a mechanism for reflections, designed for future use cases. This feature allows for redistribution of tokens among holders, encouraging long-term holding and investment.

## Future Use Cases for Reflections
Reflections are a powerful feature that can be utilized in various ways, such as:
- **Rewarding Long-Term Holders:** Distributing tokens among holders, rewarding those who hold their tokens over time.
- **Stabilizing Token Price:** By redistributing tokens, it can help in stabilizing the price during volatile market conditions.

## Technical Details
- **Contract Name:** BabyCreed
- **Inheritance:** Inherits from ERC20 and Ownable, indicating a standard ERC20 token with ownership privileges.
- **Taxation Logic:** The contract implements a taxation system on transactions, where a portion of each transaction is split between the Treasury and the Auto LP.
- **Swap and Liquify:** The contract includes functions to swap tokens for Ethereum (ETH) and add to the liquidity pool, supporting the price stability of the token.

## Additional Features
- **Investment and Mutual Funds Addresses:** The contract contains mechanisms to support investment strategies through addresses dedicated to stocks and mutual funds.
- **Buyback and Burn:** The contract supports a buyback mechanism, where tokens can be bought back from the market and sent to a burn address, effectively reducing the total supply and potentially increasing the token value.

# Contract Features for Enhanced Launch Protection

#### 1. Transaction Limits with Owner Exemption

- Implementation Details: The contract now enforces a cap on the number of tokens that can be transferred in a single transaction (`_maxTxAmount`).
- Strategic Purpose: This is designed to prevent significant price impacts caused by large single transactions and aims to reduce the influence of large holders on the token's market behavior.
- Owner Exemption Rationale: The exemption for the contract owner is crucial for initial liquidity setup and other key administrative operations, ensuring smooth launch and ongoing management.

#### 2. Snipe Block Protection - In-depth

- How It Works: For a predefined number of blocks after the launch (`snipeBlockAmount`), the contract restricts all transactions except those made by the owner.
- Technical Mechanics: This is achieved by checking the current block number against the launch time (`launchTime`) and the specified snipeBlockAmount. If the current block is within this range, only the owner can execute transactions.
- Key Benefits: This feature is crucial in preventing automated bots and snipers from disrupting the initial trading phase. By doing so, it creates a fairer start for all participants and avoids the typical pitfalls of token launches where bots can dominate and manipulate the market.

#### 3. Cooldown Timer for Transactions - Detailed Explanation

- Mechanism: After executing a transaction, an address must wait for a specified cooldown period (`txCooldown`) before it can initiate another transaction.
- Technical Details: Upon each transaction by an address, the contract records the timestamp. Any subsequent transaction attempts before the cooldown period elapses are blocked.
- Purpose and Impact: This cooldown period is a strategic measure to prevent rapid, automated transactions, which are often used in manipulative trading strategies. It ensures a more equitable and stable trading environment by allowing time for market absorption of each transaction.

The integration of these features provides a fair, secure, and successful launch.


## Conclusion
The Baby Creed Token aims to create a sustainable ecosystem with its unique tax structure, supporting both the project's growth and rewarding its community. The reflections feature, while not currently active, holds potential for future applications to incentivize holding and stabilize the token's market.

---

Note: This README is a simplified description of the BCR token contract. For full details, users should refer to the actual contract code.
