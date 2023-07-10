# Old Powershell code!
# Use with care.

function cursor-goto-fine ([int] $x_coordinate, [int] $y_coordinate){
    [Console]::SetCursorPosition($x_coordinate, $y_coordinate);
}

#########################
# COLOUR ESCAPE CODES AND FUNCTIONS
#########################################################
$esc = "$([char]27)"
$reset = "$esc[0m"

# returns formatted char or string
# $x = return-rgb($y)($red)($green)($blue)
function return-rgb ([string] $output_line, [int] $red, [int] $green, [int] $blue) {
    $esc = "$([char]27)"
    $r = $red.tostring()
    $g = $green.tostring()
    $b = $blue.tostring()
    $color = "$esc[48;2;" + $r + ";" + $g + ";" + $b + "m"
    $output = $color + $output_line + $reset
    return $output
}
function write-rgb ([string] $output_line, [int] $red, [int] $green, [int] $blue) {
    $output = return-rgb($output_line)($red)($green)($blue)
    [console]::Write($output)
}
#########################################################

# default values.
[long] $tx_size_limit_default = 2000  # size limit per sendmany transaction
$fee_rate = 100                       # sat per byte tx fee
$satspercoin = 100000000              # satoshis per coin
$comment_tx = ""

###############################

#main script $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#

cursor-goto-fine(0)(0)

[console]::Write("Welcome to the Powershell SendMany command generator script`n")
write-rgb("Created by KohGT in 2021`n`n")(176)(82)(121)
$filepath = Read-Host("Type in the file name of the text file (excluding .txt):`n")
$currentpath = $PSScriptRoot
$fullfilepath = $currentpath + "\" + $filepath + ".txt"
[console]::Write("`nLooking for address list in $fullfilepath`n")

try { $file_data = Get-Content $fullfilepath } 
catch [System.IO.IOException] {"No such text file."}

# sample namecoin JSON command
# sendmany "" "{\"NEWSAGENTTWs3jEiaEWPomXYVxkVe57Zgv\":0.00001000,\"N8in88z1G5s5s2QLcDxELDmauAH4m6WokU\":0.00001000}"

$array_length = $file_data.Length
[console]::Write("Array length/Addresses: $array_length`n`n")

# may change, arbitrary constant
$tx_size_limit_input = Read-Host("Enter tx size limit (default $tx_size_limit_default) [Enter to Skip]`n")
if ([string]::IsNullOrWhiteSpace($tx_size_limit_input)){
    [long] $tx_size_limit = $tx_size_limit_default
    [console]::Write("`nNo input detected, setting tx size limit to default $tx_size_limit_default.`n")
} else {
    [long] $tx_size_limit = $tx_size_limit_input
    [console]::Write("`nSetting tx size limit to $tx_size_limit_input`n")
}

$total_commands = [math]::Floor($array_length / $tx_size_limit) + 1

if ($array_length -gt $tx_size_limit) {
    write-rgb("There are more than $tx_size_limit addresses. $total_commands command outputs expected.`n`n")(100)(100)(0)
}


# default transaction amount in satoshis
$default_amt = 546
$amount_send_int = $default_amt

# minimum amount constant
$dust_limit = 546

$amount_send = Read-Host("Satoshis per address (default $default_amt):`n")
if ([string]::IsNullOrWhiteSpace($amount_send)){
    [long] $amount_send_int = $default_amt
    [console]::Write("`nNo input registered, default amount selected.`n")
} else {
    [long] $amount_send_int = $amount_send
    [console]::Write("`nSetting amount to $amount_send satoshis per address.`n")
}


$fee_input = Read-Host("`nEnter fee in sat/byte (default $fee_rate) [Enter to Skip]`n`n")

if ([string]::IsNullOrWhiteSpace($fee_input)){
    [long] $fee = $fee_rate
} else {
    [long] $fee = $fee_input
}


$coins_sent = [math]::Floor($amount_send_int / $satspercoin)
$sats_sent = $amount_send_int % $satspercoin
$padded_satoshi_amt = "{0:d8}" -f $sats_sent

[console]::Write("`nGenerating command to send $coins_sent.$padded_satoshi_amt coins to each wallet.`n")
[console]::Write("Amount per wallet: " + "$coins_sent." + "$padded_satoshi_amt" + "`n")
[console]::Write("Total commands: $total_commands`n")

#convert existing array to formatted
for ($i = 0; $i -lt $array_length; $i++){
        $file_data[$i] = "\`"" + $file_data[$i] + "\`"" + ":$coins_sent." + $padded_satoshi_amt
    }
#split above array 

if ($total_commands -gt 1){
    $file_data_part = (1..$tx_size_limit)
    for ($j = 0; $j -lt $total_commands - 1; $j++){
        for ($i = 0; $i -lt $tx_size_limit; $i++){
            $file_data_part[$i] = $file_data[$tx_size_limit * $j + $i] 
        }
        $string_output_part = "sendmany `"`" `"{" + [string]::Join(",", $file_data_part) + "}`"" + " 6 `"$comment_tx`" null false null `"unset`" $fee"

        $indexname_j = $j + 1
        $string_output_part | Out-file -FilePath "$currentpath\$filepath`_output_part_$indexname_j.txt"
    }
    

    $remainder_addresses = $array_length % $tx_size_limit
    $file_data_final = (1..$remainder_addresses)
    #reset partial array
    for ($i = 0; $i -lt $remainder_addresses; $i++){
        $file_data_final[$i] = $file_data[$tx_size_limit * ($total_commands - 1) + $i]
    }
    $string_output_final = "sendmany `"`" `"{" + [string]::Join(",", $file_data_final) + "}`"" + " 6 `"`" null false null `"unset`" $fee"

    $string_output_final | Out-file -FilePath "$currentpath\$filepath`_output_part_$total_commands.txt"


} else {

    $string_output = "sendmany `"`" `"{" + [string]::Join(",", $file_data) + "}`""  + " 6 `"`" null false null `"unset`" $fee"

    $string_output | Out-file -FilePath "$currentpath\$filepath`_output_only.txt"
}




$inputs = 1
# arbitrary offset
$offset = 225


$outputs = $array_length
[long] $total_amount_sats = $amount_send_int * $outputs
$total_amount_coins = [math]::Floor($total_amount_sats / $satspercoin)
[int] $total_amount_sats_remainder = $total_amount_sats % $satspercoin
$total_amount_sats_pad = "{0:d8}" -f $total_amount_sats_remainder


[console]::Write("Total wallets: $outputs`n")
[console]::Write("Total sent: $total_amount_coins.$total_amount_sats_pad`n")
[console]::Write("`nFile written to $currentpath\$filepath`_output.txt `n")
$a = Read-Host("Press Enter to continue for fee estimate...")


# fee calculation

[long] $bytes = 225 + ($inputs - 1) * 147 + ($outputs - 1) * 34
[long] $fee_pay = $bytes * $fee
$fee_coins = [math]::Floor($fee_pay/$satspercoin)
$fee_sats = $fee_pay % $satspercoin
$fee_sats_padded = "{0:d8}" -f $fee_sats
[console]::Write("`n         Fees:  $fee_coins.$fee_sats_padded        Bytes: $bytes`n")
[console]::Write("   Coins Sent:  $total_amount_coins.$total_amount_sats_pad`n")

#grand total
$all_sats = $total_amount_sats + $fee_pay
$all_coins = [math]::Floor($all_sats/$satspercoin)
$all_sats_rem = $all_sats % $satspercoin
$all_sats_padded = "{0:d8}" -f $all_sats_rem
[console]::Write("--- Total ---:  $all_coins.$all_sats_padded`n`n")

start-sleep 3
$a = Read-Host("Press Enter to exit...")
