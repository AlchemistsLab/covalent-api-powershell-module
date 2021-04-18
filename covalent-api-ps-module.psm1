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

$script:COVALENT_API = "https://api.covalenthq.com/v1"

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
Function returns a list spot prices for a ticket(s).

.DESCRIPTION
Function returns a list spot prices for a ticket(s).

.EXAMPLE
Get-SpotPrices -Tickers ""
#>
function Get-SpotPrices {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [String]$Tickers,

        # common parameters
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH"
        )]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [String]$APIToken = $env:COVALENT_API_TOKEN
    )
    BEGIN {
        Confirm-APIToken -APIToken $APIToken

        $uri = "$script:COVALENT_API/pricing/tickers/?&key=$APIToken"

        if ($Tickers) {
            $tickerList = ""
            foreach ($t in $Tickers.Split(",").Trim()) {
                if ($t) {
                    if ($tickerList) {
                        $tickerList += "%2C$t"
                    }
                    else {
                        $tickerList += "$t"
                    }
                }
            }

            $uri += "&tickers=$tickerList"
        }

        if ($QuoteCurrency) {
            $uri += "&quote-currency=$QuoteCurrency"
        }
    }
    PROCESS {
        $responseOutput = Invoke-RestMethod -Method GET -UseBasicParsing -Uri $uri -ContentType "application/json"
    }
    END {
        Write-Output $responseOutput
    }
}


Export-ModuleMember -Function Get-SpotPrices