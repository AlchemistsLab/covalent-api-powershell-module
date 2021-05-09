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

### Functions and Respective API Endpoint
**Class A**
- Get-TokenBalancesForAddress - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/address/{address}/balances_v2/)
- Get-HistoricalPortfolioValueOverTime - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/address/{address}/portfolio_v2/)
- Get-Transactions - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/address/{address}/transactions_v2/)
- Get-ERC20TokenTransfers - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/address/{address}/transfers_v2/)
- Get-Block - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/block_v2/{block_height}/)
- Get-BlockHeights - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/{chain_id}/block_v2/{block_height}/)

**Pricing Endpoints**
- Get-HistoricalPricesByAddress - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/historical_by_address/{chain_id}/{quote_currency}/{contract_address}/)
- Get-HistoricalPricesByAddresses - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/historical_by_addresses/{chain_id}/{quote_currency}/{contract_addresses}/)
- Get-HistoricalPricesByAddressesV2 - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/historical_by_addresses_v2/{chain_id}/{quote_currency}/{contract_addresses}/) 
- Get-HistoricalPricesByTicker - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/historical/{quote_currency}/{ticker_symbol}/)
- Get-SpotPrices - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/tickers/)
- Get-PriceVolatility - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/volatility/)
