# Covalent API PowerShell Module

**Created By**: Maxim Tkachenko
<br>
**Email**: itsys4@gmail.com

### Purpose:
Contains functions implementing calls to Covalent API endpoints

### Official Covalent API docs
https://www.covalenthq.com/docs/api/

### Installation and Useful Notes
1. Create a Covalent API token: https://www.covalenthq.com/platform/#/auth/register (skip this step if you have a token already)
2. Download `covalent-api-ps-module.psm1` file
3. Run the command to import the module: `Import-Module "<path to the folder where the file was saved>\covalent-api-ps-module.psm1" -Force`
4. Set `$env:COVALENT_API_TOKEN` environment variable: `$env:COVALENT_API_TOKEN = "<your token>"`
5. Default quote currency is USD. To change that, either set `$env:QUOTE_CURRENCY` variable or use `-QuoteCurrency` parameter available in many functions
6. Default output format is JSON. To change that, either set `$env:OUTPUT_FORMAT` variable or use `-Format` parameter available in many functions
7. Default Covalent API url is `https://api.covalenthq.com/v1`, but it can be changed via `-APIUrl` parameter of each function if needed
8. Many functions have the pagination parameters `-PageNumber` and `-PageSize` which can be used to limit output
9. Many functions have `ChainId` parameter. A list of supported blockchain networks can be found [here](https://www.covalenthq.com/docs/api/#overview--supported-networks)
10. Covalent offers the query language [Primer](https://www.covalenthq.com/docs/learn/tutorials/query-with-primer-beg) which makes it easy for users to further process and transform the records in the Covalent API responses for their custom use-cases. All class A functions have the Primer parameters: `Primer`, `Match`, `Group`, `Sort`, `Skip`, `Limit`. It is better to use single quotes when working with the Primer queries to avoid escaping double quotes. Examples: `-Match '{"gas_spent": {"$lt": 200000} }'`

### Functions and Respective API Endpoint ([doc](https://www.covalenthq.com/docs/api/))
**Class A**
- Get-TokenBalancesForAddress - "Get token balances for address"
- Get-HistoricalPortfolioValueOverTime - "Get historical portfolio value over time"
- Get-Transactions - "Get transactions"
- Get-ERC20TokenTransfers - "Get ERC20 token transfers"
- Get-Block - "Get a block"
- Get-BlockHeights - "Get block heights"
- Get-LogEventsByContractAddress - "Get Log events by contract address"
- Get-LogEventsByTopicHashes - "Get Log events by topic hash(es)"
- Get-ExternalNFTMetadata - "Get external NFT metadata"
- Get-NFTTokenIDs - "Get NFT Token IDs"
- Get-NFTTransactions - "Get NFT Transactions"
- Get-ChangesInTokenHoldersBetweenTwoBlockHeights - "Get changes in token holders between two block heights"
- Get-TokenHoldersAsOfBlockHeight - "Get token holders as of a block height"
- Get-ContractMetadata - "Get all contract metadata"
- Get-TransactionByTxHash - "Get a transaction"

**Class B**
- Get-SushiswapAddressExchangeLiquidityTransactions - "Get Sushiswap address exchange liquidity transactions"
- Get-SushiswapAddressExchangeBalances - "Get Sushiswap address exchange balances"
- Get-SushiswapNetworkAssets - "Get Sushiswap network assets"
- Get-AaveV2AddressBalances - "Get Aave v2 address balances"
- Get-AaveAddressBalances - "Get Aave address balances"
- Get-BalancerExchangeAddressBalances - "Get Balancer exchange address balances"
- Get-CompoundAddressActivity - "Get Compound address activity"
- Get-CompoundAddressBalances - "Get Compound address balances"
- Get-CurveAddressBalances - "Get Curve address balances"
- Get-FarmingStats - "Get farming stats"
- Get-UniswapV1AddressExchangeBalances - "Get Uniswap v1 address exchange balances"
- Get-UniswapV2AddressExchangeBalances - "Get Uniswap v2 address exchange balances"
- Get-UniswapV2AddressExchangeLiquidityTransactions - "Get Uniswap v2 address exchange liquidity transactions"
- Get-AaveV2NetworkAssets - "Get Aave v2 network assets"
- Get-AaveNetworkAssets - "Get Aave network assets"
- Get-AugurMarketAffiliateFeeDivisors - "Get Augur market affiliate fee divisors"
- Get-CompoundNetworkAssets - "Get Compound network assets"
- Get-UniswapV2NetworkAssets - "Get Uniswap v2 network assets"
- Get-PancakeswapV2AddressExchangeBalances - "Get Pancakeswap V2 address exchange balances"
- Get-PancakeswapAddressExchangeBalances - "Get Pancakeswap address exchange balances"
- Get-PancakeswapAddressExchangeLiquidityTransactions - "Get Pancakeswap address exchange liquidity transactions"
- Get-PancakeswapV2NetworkAssets - "Get Pancakeswap V2 network assets"
- Get-PancakeswapNetworkAssets - "Get Pancakeswap network assets"
- Get-PancakeswapV2NetworkAssetByAddress - "Get Pancakeswap V2 network asset by address"

**Pricing Endpoints**
- Get-HistoricalPricesByAddress - "Get historical prices by address"
- Get-HistoricalPricesByAddresses - "Get historical prices by addresses"
- Get-HistoricalPricesByAddressesV2 - "Get historical prices by addresses v2"
- Get-HistoricalPricesByTicker - "Get historical prices by ticker symbol"
- Get-SpotPrices - "Get spot prices"
- Get-PriceVolatility - "Get price volatility"
