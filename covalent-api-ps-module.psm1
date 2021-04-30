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

Export-ModuleMember -Function Get-SpotPrices, Get-PriceVolatility