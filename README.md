# Covalent API PowerShell Module

**Created By**: Maxim Tkachenko
<br>
**Email**: itsys4@gmail.com

### Purpose:
Contains functions implementing calls to Covalent API endpoints

### Official Covalent API docs
https://www.covalenthq.com/docs/api/

### Installation
1. Create a Covalent API token: https://www.covalenthq.com/platform/#/auth/register
2. Download `covalent-api-ps-module.psm1` file
3. Run the command to import the module: `Import-Module "<path to the folder where the file was saved>\covalent-api-ps-module.psm1" -Force`
4. Set `$env:COVALENT_API_TOKEN` environment variable: `$env:COVALENT_API_TOKEN = "<your token>"`
5. Default quote currency is USD. To change that, either set `$env:QUOTE_CURRENCY` variable or use `-QuoteCurrency` parameter available in many functions

### Functions and respective API endpoint
- Get-SpotPrices - [endpoint](https://www.covalenthq.com/docs/api/#get-/v1/pricing/tickers/)
