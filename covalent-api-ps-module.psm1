#############################################################################################
# Covalent API PowerShell Module
#
# Created By: Maxim Tkachenko
# Email: itsys4@gmail.com
#
# Purpose:
# Contains functions implementing calls to Covalent API endpoints
#
# Official Covalent API docs: https://www.covalenthq.com/docs/api/
#############################################################################################

$script:COVALENT_API_URL = "https://api.covalenthq.com/v1"

<#
.SYNOPSIS
Function validates if the API token is found or not.

.DESCRIPTION
Function validates if the API token is found and returns an error if not.

.EXAMPLE
Confirm-APIToken -APIToken "<token>"
#>
function Confirm-APIToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [String]$APIToken
    )
    BEGIN {
    }
    PROCESS {
        if (-not $APIToken) {
            throw "API token is not found. Please provide it in -APIToken parameter or by setting `$env:COVALENT_API_TOKEN environment variable."
        }
        else {
            Write-Verbose "API token is found."
        }
    }
    END {
    }
}

<#
.SYNOPSIS
Function returns historical prices for a contract_address in a particular chain and quote_currency.

.DESCRIPTION
Function returns historical prices for a contract_address in a particular chain and quote_currency. Can pass to and from to define a range, by default if they are omitted, it returns today's price.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER QuoteCurrency
The requested fiat currency. Default is USD.

.PARAMETER ContractAddress
Smart contract address.

.PARAMETER StartDay
The start day of the historical price range.

.PARAMETER EndDay
The end day of the historical price range.

.PARAMETER SortOrder
Sort the prices in chronological order. By default, it's set to descending order. Possible values: Asc, Desc.

.EXAMPLE
Get-HistoricalPricesByAddress -ChainId 1 -QuoteCurrency "USD" -ContractAddress "0xc7283b66eb1eb5fb86327f08e1b5816b0720212b" -StartDay "2021-04-01" -EndDay "2021-05-01" -SortOrder "Asc"
#>
function Get-HistoricalPricesByAddress {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $(if ($env:QUOTE_CURRENCY) {$env:QUOTE_CURRENCY} else {"USD"}),

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        [Parameter(Mandatory = $false)]
        [datetime]$StartDay,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDay,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Asc","Desc")]
        [String]$SortOrder = "Desc",

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/pricing/historical_by_address/$ChainId/$($QuoteCurrency.ToLower())/$($ContractAddress.Trim())/?&key=$APIToken"

        if ($StartDay) {
            $uri += "&from=$($StartDay.ToString('yyyy-MM-dd'))"
        }

        if ($EndDay) {
            $uri += "&to=$($EndDay.ToString('yyyy-MM-dd'))"
        }

        if ($SortOrder -ieq "Asc") {
            $uri += "&prices-at-asc=true"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns historical prices for a contract_address, or a comma-separated group of contract_addresses in a particular chain_id and quote_currency.

.DESCRIPTION
Function returns historical prices for a contract_address, or a comma-separated group of contract_addresses in a particular chain_id and quote_currency. Can pass to and from to define a range, by default if they are omitted, it returns today's price.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER QuoteCurrency
The requested fiat currency. Default is USD.

.PARAMETER ContractAddresses
Smart contract address(es).

.PARAMETER StartDay
The start day of the historical price range.

.PARAMETER EndDay
The end day of the historical price range.

.PARAMETER SortOrder
Sort the prices in chronological order. By default, it's set to descending order. Possible values: Asc, Desc.

.EXAMPLE
Get-HistoricalPricesByAddresses -ChainId 1 -QuoteCurrency "USD" -ContractAddress "0xdac17f958d2ee523a2206206994597c13d831ec7,0xc7283b66eb1eb5fb86327f08e1b5816b0720212b" -StartDay "2021-04-01" -EndDay "2021-05-01" -SortOrder "Asc"
#>
function Get-HistoricalPricesByAddresses {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $(if ($env:QUOTE_CURRENCY) {$env:QUOTE_CURRENCY} else {"USD"}),

        [Parameter(Mandatory = $true)]
        [String]$ContractAddresses,

        [Parameter(Mandatory = $false)]
        [datetime]$StartDay,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDay,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Asc","Desc")]
        [String]$SortOrder = "Desc",

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        # converting a comma-separated list into url compatible
        $contractList = $ContractAddresses.Split(",").Trim() -join "%2C"

        $uri = "$APIUrl/pricing/historical_by_addresses/$ChainId/$($QuoteCurrency.ToLower())/$contractList/?&key=$APIToken"

        if ($StartDay) {
            $uri += "&from=$($StartDay.ToString('yyyy-MM-dd'))"
        }

        if ($EndDay) {
            $uri += "&to=$($EndDay.ToString('yyyy-MM-dd'))"
        }

        if ($SortOrder -ieq "Asc") {
            $uri += "&prices-at-asc=true"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns historical prices for a contract_address, or a comma-separated group of contract_addresses in a particular chain_id and quote_currency.

.DESCRIPTION
Function returns historical prices for a contract_address, or a comma-separated group of contract_addresses in a particular chain_id and quote_currency. Can pass to and from to define a range, by default if they are omitted, it returns today's price.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER QuoteCurrency
The requested fiat currency. Default is USD.

.PARAMETER ContractAddresses
Smart contract address(es).

.PARAMETER StartDay
The start day of the historical price range.

.PARAMETER EndDay
The end day of the historical price range.

.PARAMETER SortOrder
Sort the prices in chronological order. By default, it's set to descending order. Possible values: Asc, Desc.

.EXAMPLE
Get-HistoricalPricesByAddressesV2 -ChainId 1 -QuoteCurrency "USD" -ContractAddress "0xdac17f958d2ee523a2206206994597c13d831ec7,0xc7283b66eb1eb5fb86327f08e1b5816b0720212b" -StartDay "2021-04-01" -EndDay "2021-05-01" -SortOrder "Asc"
#>
function Get-HistoricalPricesByAddressesV2 {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $(if ($env:QUOTE_CURRENCY) {$env:QUOTE_CURRENCY} else {"USD"}),

        [Parameter(Mandatory = $true)]
        [String]$ContractAddresses,

        [Parameter(Mandatory = $false)]
        [datetime]$StartDay,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDay,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Asc","Desc")]
        [String]$SortOrder = "Desc",

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        # converting a comma-separated list into url compatible
        $contractList = $ContractAddresses.Split(",").Trim() -join "%2C"

        $uri = "$APIUrl/pricing/historical_by_addresses_v2/$ChainId/$($QuoteCurrency.ToLower())/$contractList/?&key=$APIToken"

        if ($StartDay) {
            $uri += "&from=$($StartDay.ToString('yyyy-MM-dd'))"
        }

        if ($EndDay) {
            $uri += "&to=$($EndDay.ToString('yyyy-MM-dd'))"
        }

        if ($SortOrder -ieq "Asc") {
            $uri += "&prices-at-asc=true"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns historical prices for a ticker_symbol in a particular quote_currency.

.DESCRIPTION
Function returns historical prices for a ticker_symbol in a particular quote_currency. Can pass to and from to define a range, by default if they are omitted, it returns today's price.

.PARAMETER QuoteCurrency
The requested fiat currency. Default is USD.

.PARAMETER Ticker
Ticker symbol.

.PARAMETER StartDay
The start day of the historical price range.

.PARAMETER EndDay
The end day of the historical price range.

.PARAMETER SortOrder
Sort the prices in chronological order. By default, it's set to descending order. Possible values: Asc, Desc.

.EXAMPLE
Get-HistoricalPricesByTicker -QuoteCurrency "USD" -Ticker "TRIBE" -StartDay "2021-04-01" -EndDay "2021-05-01" -SortOrder "Asc"
#>
function Get-HistoricalPricesByTicker {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $(if ($env:QUOTE_CURRENCY) {$env:QUOTE_CURRENCY} else {"USD"}),

        [Parameter(Mandatory = $true)]
        [String]$Ticker,

        [Parameter(Mandatory = $false)]
        [datetime]$StartDay,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDay,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Asc","Desc")]
        [String]$SortOrder = "Desc",

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/pricing/historical/$($QuoteCurrency.ToLower())/$($Ticker.Trim().ToLower())/?&key=$APIToken"

        if ($StartDay) {
            $uri += "&from=$($StartDay.ToString('yyyy-MM-dd'))"
        }

        if ($EndDay) {
            $uri += "&to=$($EndDay.ToString('yyyy-MM-dd'))"
        }

        if ($SortOrder -ieq "Asc") {
            $uri += "&prices-at-asc=true"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns spot prices and metadata for all tickers or a select group of tickers.

.DESCRIPTION
Function returns spot prices and metadata for all tickers or a select group of tickers. Without tickers query param, it returns a paginated list of all tickers sorted by market cap.

.PARAMETER Tickers
Comma-separated list of tickers. If empty, all available tickers are returned.

.EXAMPLE
Get-SpotPrices -Tickers ""
Get-SpotPrices -Tickers "TRIBE,MATIC,1INCH"
#>
function Get-SpotPrices {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [String]$Tickers,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/pricing/tickers/?&key=$APIToken"

        # converting a comma-separated list into url compatible
        if ($Tickers) {
            $tickerList = $Tickers.Split(",").Trim() -join "%2C"

            if ($tickerList.Replace("%2C","")) {
                $uri += "&tickers=$tickerList"
            }
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns price volatility and metadata for a select group of tickers.

.DESCRIPTION
Function returns price volatility and metadata for a select group of tickers. Without the tickers query param, it defaults to ETH volatility.

.PARAMETER Tickers
Comma-separated list of tickers. If empty, all available tickers are returned.

.EXAMPLE
Get-PriceVolatility -Tickers ""
Get-PriceVolatility -Tickers "TRIBE,MATIC,1INCH"
#>
function Get-PriceVolatility {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [String]$Tickers,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/pricing/volatility/?&key=$APIToken"

        # converting a comma-separated list into url compatible
        if ($Tickers) {
            $tickerList = $Tickers.Split(",").Trim() -join "%2C"

            if ($tickerList.Replace("%2C","")) {
                $uri += "&tickers=$tickerList"
            }
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns a list of all ERC20 and NFT token balances for address along with their current spot prices. 

.DESCRIPTION
Function returns a list of all ERC20 and NFT token balances for address along with their current spot prices.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.PARAMETER IncludeNft
Set to true to return ERC721 and ERC1155 assets. Defaults to false.

.PARAMETER NoNftFetch
Set to true to skip fetching NFT metadata, which can result in faster responses. Defaults to false and only applies when IncludeNft is true.

.EXAMPLE
Get-TokenBalancesForAddress -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
Get-TokenBalancesForAddress -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae" -IncludeNft $true -NoNftFetch $false
#>
function Get-TokenBalancesForAddress {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeNft = $false,

        [Parameter(Mandatory = $false)]
        [bool]$NoNftFetch = $false,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/balances_v2/?&key=$APIToken"

        if ($IncludeNft) {
            $uri += "&nft=true"

            if ($NoNftFetch) {
                $uri += "&no-nft-fetch=true"
            }
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns wallet value for the last 30 days at 24 hour timestamps. 

.DESCRIPTION
Function returns wallet value for the last 30 days at 24 hour timestamps.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-HistoricalPortfolioValueOverTime -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-HistoricalPortfolioValueOverTime {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$Address,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/portfolio_v2/?&key=$APIToken"

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns all transactions for address including their decoded log events. 

.DESCRIPTION
Function returns all transactions for address including their decoded log events. This endpoint does a deep-crawl of the blockchain to retrieve all kinds of transactions that references the address.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.PARAMETER SortOrder
Sort the transactions in chronological order. By default, it's set to Desc and returns transactions in chronological descending order.

.PARAMETER NoLogs
Setting this to $true will omit decoded event logs, resulting in lighter and faster responses. By default it's set to $false.

.EXAMPLE
Get-Transactions -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae" -SortOrder Asc -NoLogs $true
#>
function Get-Transactions {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Asc","Desc")]
        [String]$SortOrder = "Desc",

        [Parameter(Mandatory = $false)]
        [bool]$NoLogs = $false,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/transactions_v2/?&key=$APIToken"

        if ($SortOrder -ieq "Asc") {
            $uri += "&block-signed-at-asc=true"
        }

        if ($NoLogs) {
            $uri += "&no-logs=true"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns ERC20 token transfers for wallet address and contract address.

.DESCRIPTION
Function returns ERC20 token transfers for wallet address and contract address.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.PARAMETER ContractAddress
Smart contract address.

.EXAMPLE
Get-ERC20TokenTransfers -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae" -ContractAddress "0xc7283b66eb1eb5fb86327f08e1b5816b0720212b"
#>
function Get-ERC20TokenTransfers {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/transfers_v2/?&key=$APIToken"

        if ($ContractAddress) {
            $uri += "&contract-address=$($ContractAddress.Trim().ToLower())"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($QuoteCurrency) {
            $uri += "&quote-currency=$($QuoteCurrency.ToLower())"
        }

        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns a single block at BlockHeight.

.DESCRIPTION
Function returns a single block at BlockHeight. If BlockHeight is not set, returns the latest block available.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER BlockHeight
Block height. By default "latest".

.EXAMPLE
Get-Block -ChainId 1
Get-Block -ChainId 1 -BlockHeight 12402190
#>
function Get-Block {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $false)]
        [int]$BlockHeight,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        if ($BlockHeight) {
            $blockHeightString = $BlockHeight.ToString()
        }
        else {
            $blockHeightString = "latest"
        }

        $uri = "$APIUrl/$ChainId/block_v2/$blockHeightString/?&key=$APIToken"

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns all the block height(s) of a particular chain within a date range.

.DESCRIPTION
Function returns all the block height(s) of a particular chain within a date range. If the EndDate is not set, returns every block height from the StartDate to now.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER StartDate
The start day of the date range.

.PARAMETER EndDate
The end day of the date range. If not set, it means "latest" by default.

.EXAMPLE
Get-BlockHeights -ChainId 1 -StartDate "2021-04-01" -EndDate "2021-04-02"
Get-BlockHeights -ChainId 1 -StartDate (Get-Date).AddDays(-1)
#>
function Get-BlockHeights {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,

        [Parameter(Mandatory = $false)]
        [datetime]$EndDate,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $startDateString = $StartDate.ToString('yyyy-MM-ddTHH:mm:ssZ').Replace(":","%3A")

        if ($EndDate) {
            $endDateString = $EndDate.ToString('yyyy-MM-ddTHH:mm:ssZ').Replace(":","%3A")
        }
        else {
            $endDateString = "latest"
        }

        $uri = "$APIUrl/$ChainId/block_v2/$startDateString/$endDateString/?&key=$APIToken"

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns a paginated list of decoded log events emiited by a particular smart contract.

.DESCRIPTION
Function returns a paginated list of decoded log events emiited by a particular smart contract.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
Smart contract address.

.PARAMETER StartingBlock
Starting block to define a block range.

.PARAMETER EndingBlock
Ending block to define a block range. By default "latest".

.EXAMPLE
Get-LogEventsByContractAddress -ChainId 1 -ContractAddress "0xc7283b66eb1eb5fb86327f08e1b5816b0720212b" -StartingBlock 12302518 -EndingBlock 12402520
#>
function Get-LogEventsByContractAddress {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        [Parameter(Mandatory = $true)]
        [int]$StartingBlock,

        [Parameter(Mandatory = $false)]
        [int]$EndingBlock,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/events/address/$($ContractAddress.Trim().ToLower())/?&key=$APIToken"

        $uri += "&starting-block=$StartingBlock"

        if ($EndingBlock) {
            $endingBlockString = $EndingBlock.ToString()
        }
        else {
            $endingBlockString = "latest"
        }

        $uri += "&ending-block=$endingBlockString"

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

<#
.SYNOPSIS
Function returns a paginated list of decoded log events with one or more topic hashes separated by a comma.

.DESCRIPTION
Function returns a paginated list of decoded log events with one or more topic hashes separated by a comma.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER TopicHashes
A comma separated list of topic hashes. Topic hash calculator: https://www.covalenthq.com/docs/tools/topic-calculator

.PARAMETER StartingBlock
Starting block to define a block range.

.PARAMETER EndingBlock
Ending block to define a block range. By default "latest".

.PARAMETER SenderAddress
The address of the sender.

.EXAMPLE
Get-LogEventsByTopicHashes -ChainId 1 -TopicHashes "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925" -StartingBlock 12402600 -EndingBlock 12402603 -PageSize 10
#>
function Get-LogEventsByTopicHashes {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$TopicHashes,

        [Parameter(Mandatory = $true)]
        [int]$StartingBlock,

        [Parameter(Mandatory = $false)]
        [int]$EndingBlock,

        [Parameter(Mandatory = $false)]
        [String]$SenderAddress,

        ####### API token #######
        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN,

        ####### pagination parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -ge 0})]
        [int]$PageNumber,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript({$_ -gt 0})]
        [int]$PageSize,

        ####### common parameters #######
        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        # converting a comma-separated list into url compatible
        $topicList = $TopicHashes.Split(",").Trim() -join "%2C"

        $uri = "$APIUrl/$ChainId/events/topics/$topicList/?&key=$APIToken"

        $uri += "&starting-block=$StartingBlock"

        if ($EndingBlock) {
            $endingBlockString = $EndingBlock.ToString()
        }
        else {
            $endingBlockString = "latest"
        }

        $uri += "&ending-block=$endingBlockString"

        if ($SenderAddress) {
            $uri += "&sender-address=$($SenderAddress.Trim().ToLower())"
        }

        ####### validating API token #######
        Confirm-APIToken -APIToken $APIToken

        ####### processing of the pagination parameters #######
        if ($PageNumber) {
            $uri += "&page-number=$PageNumber"
        }

        if ($PageSize) {
            $uri += "&page-size=$PageSize"
        }

        ####### processing of the common parameters #######
        if ($Format) {
            $uri += "&format=$($Format.ToLower())"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}

Export-ModuleMember -Function Get-HistoricalPricesByAddress, Get-HistoricalPricesByAddresses, Get-HistoricalPricesByAddressesV2, Get-HistoricalPricesByTicker, Get-SpotPrices, Get-PriceVolatility, Get-TokenBalancesForAddress, Get-HistoricalPortfolioValueOverTime, Get-Transactions, Get-ERC20TokenTransfers, Get-Block, Get-BlockHeights, Get-LogEventsByContractAddress, Get-LogEventsByTopicHashes