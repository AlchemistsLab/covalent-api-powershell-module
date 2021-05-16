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
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

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
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

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
Function, given a NFT contract address and a token ID, fetchs and returns the external metadata.

.DESCRIPTION
Function, given a NFT contract address and a token ID, fetchs and returns the external metadata. Both ERC751 as well as ERC1155 are supported.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
NFT contract address.

.PARAMETER TokenId
The ID to the token.

.EXAMPLE
Get-ExternalNFTMetadata -ChainId 1 -ContractAddress "0xe4605d46fd0b3f8329d936a8b258d69276cba264" -TokenId "123"
#>
function Get-ExternalNFTMetadata {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        [Parameter(Mandatory = $true)]
        [String]$TokenId,

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
        $uri = "$APIUrl/$ChainId/tokens/$($ContractAddress.Trim().ToLower())/nft_metadata/$($TokenId.Trim().ToLower())/?&key=$APIToken"

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
Function returns a list of all token IDs for a NFT contract on a blockchain network.

.DESCRIPTION
Function returns a list of all token IDs for a NFT contract on a blockchain network.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
NFT contract address.

.EXAMPLE
Get-NFTTokenIDs -ChainId 1 -ContractAddress "0xe4605d46fd0b3f8329d936a8b258d69276cba264"
#>
function Get-NFTTokenIDs {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

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
        $uri = "$APIUrl/$ChainId/tokens/$($ContractAddress.Trim().ToLower())/nft_token_ids/?&key=$APIToken"

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
Function returns a list of transactions given a NFT contract and a token ID on a blockchain network.

.DESCRIPTION
Function returns a list of transactions given a NFT contract and a token ID on a blockchain network.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
NFT contract address.

.PARAMETER TokenId
The ID to the token.

.EXAMPLE
Get-NFTTransactions -ChainId 1 -ContractAddress "0xe4605d46fd0b3f8329d936a8b258d69276cba264" -TokenId "123"
#>
function Get-NFTTransactions {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        [Parameter(Mandatory = $true)]
        [String]$TokenId,

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
        $uri = "$APIUrl/$ChainId/tokens/$($ContractAddress.Trim().ToLower())/nft_transactions/$($TokenId.Trim().ToLower())/?&key=$APIToken"

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
Function returns token balance changes for token holders between StartingBlock and EndingBlock.

.DESCRIPTION
Function returns token balance changes for token holders between StartingBlock and EndingBlock. Return a paginated list of token holders and their current/historical balances. If EndingBlock is omitted, the latest block is used.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
Smart contract address.

.PARAMETER StartingBlock
Starting block to define a block range.

.PARAMETER EndingBlock
Ending block to define a block range. By default "latest".

.EXAMPLE
Get-ChangesInTokenHoldersBetweenTwoBlockHeights -ChainId 1 -ContractAddress "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984" -StartingBlock 11000000 -EndingBlock 11383362 -PageSize 10
#>
function Get-ChangesInTokenHoldersBetweenTwoBlockHeights {
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
        [ValidateSet("USD","CAD","EUR","SGD","INR","JPY","VND","CNY","KRW","RUB","TRY","ETH")]
        [String]$QuoteCurrency = $env:QUOTE_CURRENCY,

        [Parameter(Mandatory = $false)]
        [ValidateSet("JSON", "CSV")]
        [String]$Format = $env:OUTPUT_FORMAT,

        [Parameter(Mandatory = $false)]
        [String]$APIUrl = $script:COVALENT_API_URL
    )
    BEGIN {
        $uri = "$APIUrl/$ChainId/tokens/$($ContractAddress.Trim().ToLower())/token_holders_changes/?&key=$APIToken"

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
Function returns a paginated list of token holders.

.DESCRIPTION
Function returns a paginated list of token holders. If block-height is omitted, the latest block is used.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
Smart contract address.

.PARAMETER BlockHeight
Block height. By default "latest".

.EXAMPLE
Get-TokenHoldersAsOfBlockHeight -ChainId 1 -ContractAddress "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984" -BlockHeight 11383235 -PageSize 10
#>
function Get-TokenHoldersAsOfBlockHeight {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$ContractAddress,

        [Parameter(Mandatory = $false)]
        [int]$BlockHeight,

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
        $uri = "$APIUrl/$ChainId/tokens/$($ContractAddress.Trim().ToLower())/token_holders/?&key=$APIToken"

        if ($BlockHeight) {
            $blockString = $BlockHeight.ToString()
        }
        else {
            $blockString = "latest"
        }

        $uri += "&block-height=$blockString"

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
Function returns a list of all contracts on a blockchain along with their metadata.

.DESCRIPTION
Function returns a list of all contracts on a blockchain along with their metadata.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER ContractAddress
Smart contract address. Only 'all' supported right now.

.EXAMPLE
Get-ContractMetadata -ChainId 56 -ContractAddress "all"
#>
function Get-ContractMetadata {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $false)]
        [String]$ContractAddress = "all",

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
        $uri = "$APIUrl/$ChainId/tokens/tokenlists/$($ContractAddress.Trim().ToLower())/?&key=$APIToken"

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
Function returns a single transaction for TxHash including their decoded log events.

.DESCRIPTION
Function returns a single transaction for TxHash including their decoded log events.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER TxHash
Transaction hash.

.PARAMETER NoLogs
Setting this to $true will omit decoded event logs, resulting in lighter and faster responses. By default it's set to $false.

.EXAMPLE
Get-TransactionByTxHash -ChainId 1 -TxHash "0xbda92389200cadac424d64202caeab70cd5e93756fe34c08578adeb310bba254" -NoLogs $true
#>
function Get-TransactionByTxHash {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$TxHash,

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
        $uri = "$APIUrl/$ChainId/transaction_v2/$($TxHash.Trim().ToLower())/?&key=$APIToken"

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
Function returns Sushiswap address exchange liquidity transactions.

.DESCRIPTION
Function returns Sushiswap address exchange liquidity transactions.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.PARAMETER Swaps
Get additional insight on swap event data related to this address, default: $false

.EXAMPLE
Get-SushiswapAddressExchangeLiquidityTransactions -ChainId 137 -Address "0x4121dD930B15742b6d2e89B41284A79320bb8503" -Swaps $true
#>
function Get-SushiswapAddressExchangeLiquidityTransactions {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $false)]
        [bool]$Swaps = $false,

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
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/stacks/sushiswap/acts/?&key=$APIToken"

        if ($Swaps) {
            $uri += "&swaps=true"
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
Function returns Sushiswap address exchange balances.

.DESCRIPTION
Function returns Sushiswap address exchange balances.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-SushiswapAddressExchangeBalances -ChainId 1 -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-SushiswapAddressExchangeBalances {
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
        $uri = "$APIUrl/$ChainId/address/$($Address.Trim().ToLower())/stacks/sushiswap/balances/?&key=$APIToken"

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
Function returns a paginated list of Sushiswap pools sorted by exchange volume.

.DESCRIPTION
Function returns a paginated list of Sushiswap pools sorted by exchange volume. If $Tickers (a comma separated list) is present, only return the pools that contain these tickers.

.PARAMETER ChainId
Chain ID of the Blockchain being queried. https://www.covalenthq.com/docs/api/#overview--supported-networks

.PARAMETER Tickers
If tickers (a comma separated list) is present, only return the pools that contain these tickers.

.EXAMPLE
Get-SushiswapNetworkAssets -ChainId 1 -Tickers "1INCH,ANKR"
Get-SushiswapNetworkAssets -ChainId 250
#>
function Get-SushiswapNetworkAssets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [int]$ChainId,

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
        $uri = "$APIUrl/$ChainId/networks/sushiswap/assets/?&key=$APIToken"

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
Function returns Aave v2 address balances, supply and borrow positions.

.DESCRIPTION
Function returns Aave v2 address balances, supply and borrow positions.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-AaveV2AddressBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-AaveV2AddressBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/aave_v2/balances/?&key=$APIToken"

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
Function returns Aave address balances.

.DESCRIPTION
Function returns Aave address balances.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-AaveAddressBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-AaveAddressBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/aave/balances/?&key=$APIToken"

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
Function returns Balancer exchange address balances.

.DESCRIPTION
Function returns Balancer exchange address balances.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-BalancerExchangeAddressBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-BalancerExchangeAddressBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/balancer/balances/?&key=$APIToken"

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
Function returns Compound address activity.

.DESCRIPTION
Function returns Compound address activity.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-CompoundAddressActivity -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-CompoundAddressActivity {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/compound/acts/?&key=$APIToken"

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
Function returns Compound address balances.

.DESCRIPTION
Function returns Compound address balances.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-CompoundAddressBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-CompoundAddressBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/compound/balances/?&key=$APIToken"

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
Function returns Curve address balances.

.DESCRIPTION
Function returns Curve address balances.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-CurveAddressBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-CurveAddressBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/curve/balances/?&key=$APIToken"

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
Function returns farming positions on Uniswap, Sushiswap, and Harvest.

.DESCRIPTION
Function returns farming positions on Uniswap, Sushiswap, and Harvest.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-FarmingStats -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-FarmingStats {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/farming/positions/?&key=$APIToken"

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
Function returns Uniswap v1 address exchange balances. 

.DESCRIPTION
Function returns Uniswap v1 address exchange balances. 

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-UniswapV1AddressExchangeBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-UniswapV1AddressExchangeBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/uniswap_v1/balances/?&key=$APIToken"

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
Function returns Uniswap v2 address exchange balances. 

.DESCRIPTION
Function returns Uniswap v2 address exchange balances. 

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-UniswapV2AddressExchangeBalances -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae"
#>
function Get-UniswapV2AddressExchangeBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/uniswap_v2/balances/?&key=$APIToken"

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
Function returns Uniswap v2 address exchange liquidity transactions.

.DESCRIPTION
Function returns Uniswap v2 address exchange liquidity transactions.

.PARAMETER Address
Wallet address.

.PARAMETER Swaps
Get additional insight on swap event data related to this address, default: $false

.EXAMPLE
Get-UniswapV2AddressExchangeLiquidityTransactions -Address "0x5a6d3b6bf795a3160dc7c139dee9f60ce0f00cae" -Swaps $true
#>
function Get-UniswapV2AddressExchangeLiquidityTransactions {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $false)]
        [bool]$Swaps = $false,

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
        $uri = "$APIUrl/1/address/$($Address.Trim().ToLower())/stacks/uniswap_v2/acts/?&key=$APIToken"

        if ($Swaps) {
            $uri += "&swaps=true"
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
Function returns Aave v2 network assets.

.DESCRIPTION
Function returns Aave v2 network assets.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-AaveV2NetworkAssets
#>
function Get-AaveV2NetworkAssets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/networks/aave_v2/assets/?&key=$APIToken"

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
Function returns Aave network assets.

.DESCRIPTION
Function returns Aave network assets.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-AaveNetworkAssets
#>
function Get-AaveNetworkAssets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/networks/aave/assets/?&key=$APIToken"

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
Function returns Augur market affiliate fee divisors

.DESCRIPTION
Function returns Augur market affiliate fee divisors

.EXAMPLE
Get-AugurMarketAffiliateFeeDivisors
#>
function Get-AugurMarketAffiliateFeeDivisors {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/networks/augur/affiliate_fee/?&key=$APIToken"

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
Function returns Compound network assets.

.DESCRIPTION
Function returns Compound network assets.

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-CompoundNetworkAssets
#>
function Get-CompoundNetworkAssets {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/1/networks/compound/assets/?&key=$APIToken"

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
Function returns a paginated list of Uniswap pools sorted by exchange volume.

.DESCRIPTION
Function returns a paginated list of Uniswap pools sorted by exchange volume. If $Tickers (a comma separated list) is present, only return the pools that contain these tickers.

.PARAMETER Tickers
If tickers (a comma separated list) is present, only return the pools that contain these tickers.

.EXAMPLE
Get-UniswapV2NetworkAssets -Tickers "1INCH,ANKR"
#>
function Get-UniswapV2NetworkAssets {
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
        $uri = "$APIUrl/1/networks/uniswap_v2/assets/?&key=$APIToken"

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
Function returns Pancakeswap V2 address exchange balances. 

.DESCRIPTION
Function returns Pancakeswap V2 address exchange balances. 

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-PancakeswapV2AddressExchangeBalances -Address "0x085bc434707cf6ae616948ffeee200ccdff15c1a"
#>
function Get-PancakeswapV2AddressExchangeBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/56/address/$($Address.Trim().ToLower())/stacks/pancakeswap_v2/balances/?&key=$APIToken"

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
Function returns Pancakeswap address exchange balances. 

.DESCRIPTION
Function returns Pancakeswap address exchange balances. 

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-PancakeswapAddressExchangeBalances -Address "0x085bc434707cf6ae616948ffeee200ccdff15c1a"
#>
function Get-PancakeswapAddressExchangeBalances {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
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
        $uri = "$APIUrl/56/address/$($Address.Trim().ToLower())/stacks/pancakeswap/balances/?&key=$APIToken"

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
Function returns Pancakeswap address exchange liquidity transactions.

.DESCRIPTION
Function returns Pancakeswap address exchange liquidity transactions.

.PARAMETER Address
Wallet address.

.PARAMETER Swaps
Get additional insight on swap event data related to this address, default: $false

.EXAMPLE
Get-PancakeswapAddressExchangeLiquidityTransactions -Address "0x085bc434707cf6ae616948ffeee200ccdff15c1a" -Swaps $true
#>
function Get-PancakeswapAddressExchangeLiquidityTransactions {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Address,

        [Parameter(Mandatory = $false)]
        [bool]$Swaps = $false,

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
        $uri = "$APIUrl/56/address/$($Address.Trim().ToLower())/stacks/pancakeswap/acts/?&key=$APIToken"

        if ($Swaps) {
            $uri += "&swaps=true"
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
Function returns a paginated list of Pancake V2 pools sorted by exchange volume. Only pools with swaps in the last 24 hours are included. 

.DESCRIPTION
Function returns a paginated list of Pancake V2 pools sorted by exchange volume. Only pools with swaps in the last 24 hours are included. 

.PARAMETER Tickers
If tickers (a comma separated list) is present, only return the pools that contain these tickers.

.EXAMPLE
Get-PancakeswapV2NetworkAssets -Tickers "1INCH,ANKR"
#>
function Get-PancakeswapV2NetworkAssets {
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
        $uri = "$APIUrl/56/networks/pancakeswap_v2/assets/?&key=$APIToken"

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
Function returns a paginated list of Pancake pools sorted by exchange volume. Only pools with swaps in the last 24 hours are included. 

.DESCRIPTION
Function returns a paginated list of Pancake pools sorted by exchange volume. Only pools with swaps in the last 24 hours are included. 

.PARAMETER Tickers
If tickers (a comma separated list) is present, only return the pools that contain these tickers.

.EXAMPLE
Get-PancakeswapNetworkAssets -Tickers "1INCH,ANKR"
#>
function Get-PancakeswapNetworkAssets {
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
        $uri = "$APIUrl/56/networks/pancakeswap/assets/?&key=$APIToken"

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
Function returns Pancakeswap V2 network asset by address

.DESCRIPTION
Function returns Pancakeswap V2 network asset by address

.PARAMETER Address
Wallet address.

.EXAMPLE
Get-PancakeswapV2NetworkAssetByAddress -Address "0x16b9a82891338f9ba80e2d6970fdda79d1eb0dae"
#>
function Get-PancakeswapV2NetworkAssetByAddress {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Address,

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
        $uri = "$APIUrl/56/networks/pancakeswap_v2/assets/$($Address.Trim().ToLower())/?&key=$APIToken"

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

# export functions
$functionList = @()
$functionList += @("Get-TokenBalancesForAddress", "Get-HistoricalPortfolioValueOverTime", "Get-Transactions", "Get-ERC20TokenTransfers")
$functionList += @("Get-Block", "Get-BlockHeights", "Get-LogEventsByContractAddress", "Get-LogEventsByTopicHashes", "Get-ExternalNFTMetadata")
$functionList += @("Get-NFTTokenIDs", "Get-NFTTransactions", "Get-ChangesInTokenHoldersBetweenTwoBlockHeights", "Get-TokenHoldersAsOfBlockHeight")
$functionList += @("Get-ContractMetadata", "Get-TransactionByTxHash", "Get-SushiswapAddressExchangeLiquidityTransactions", "Get-SushiswapAddressExchangeBalances")
$functionList += @("Get-SushiswapNetworkAssets", "Get-AaveV2AddressBalances", "Get-AaveAddressBalances", "Get-BalancerExchangeAddressBalances")
$functionList += @("Get-CompoundAddressActivity", "Get-CompoundAddressBalances", "Get-CurveAddressBalances", "Get-FarmingStats")
$functionList += @("Get-UniswapV1AddressExchangeBalances", "Get-UniswapV2AddressExchangeBalances", "Get-UniswapV2AddressExchangeLiquidityTransactions")
$functionList += @("Get-AaveV2NetworkAssets", "Get-AaveNetworkAssets", "Get-AugurMarketAffiliateFeeDivisors", "Get-CompoundNetworkAssets", "Get-UniswapV2NetworkAssets")
$functionList += @("Get-PancakeswapV2AddressExchangeBalances", "Get-PancakeswapAddressExchangeBalances", "Get-PancakeswapAddressExchangeLiquidityTransactions")
$functionList += @("Get-PancakeswapV2NetworkAssets", "Get-PancakeswapNetworkAssets", "Get-PancakeswapV2NetworkAssetByAddress")
$functionList += @("Get-HistoricalPricesByAddress", "Get-HistoricalPricesByAddresses", "Get-HistoricalPricesByAddressesV2")
$functionList += @("Get-HistoricalPricesByTicker", "Get-SpotPrices", "Get-PriceVolatility")
Export-ModuleMember -Function $functionList