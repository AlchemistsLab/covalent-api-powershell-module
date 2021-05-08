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

Export-ModuleMember -Function Get-HistoricalPricesByAddress, Get-HistoricalPricesByAddresses, Get-HistoricalPricesByAddressesV2, Get-HistoricalPricesByTicker, Get-SpotPrices, Get-PriceVolatility