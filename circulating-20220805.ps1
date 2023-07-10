# Old Powershell code!
# Use with care.
# Last updated Aug 2022

function cursor-goto-fine ([int] $x_coordinate, [int] $y_coordinate){
    [Console]::SetCursorPosition($x_coordinate, $y_coordinate);
}
$esc = "$([char]27)"
$reset = "$esc[0m"
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
#########################################################\



###############################

#main script $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#

cursor-goto-fine(0)(0)

[console]::Write("Welcome to the Powershell CoinSupply command generator script`n")
write-rgb("Created by KohGT in 2022`n`n")(176)(82)(121)
[console]::Write(" BTC NMC BCH BSV - 1`n LTC - 2`nDOGE - 3`nFEC - `n`n")
$type = Read-Host("`nEnter PoW coin type:  ")
$height = Read-Host("`nEnter Block Height:  ")

# WIP - use switch
if ($type -eq 1){
    $initial_block_size = 50
    $halve = 1
    $halvingblocks = 210000
}
if ($type -eq 2){
    $initial_block_size = 50
    $halve = 1
    $halvingblocks = 840000
}
if ($type -eq 3){
    $initial_block_size = 10000
    $halve = 0
    $halvingblocks = 1 # none
}
if ($type -eq 4){
    $initial_block_size = 100
    $halve = 1
    $halvingblocks = 301107 # none
}

[long] $total = 0
if ($halve -eq 1){
    $halvings = [math]::Floor($height/$halvingblocks)
    $remainder = $height % $halvingblocks
    for ($i = 0; $i -lt ($halvings + 1); $i++){
        if ($i -ne $halvings){
            $total = $total + $halvingblocks*$initial_block_size/([math]::Pow(2,$i))
        } else {
            $total = $total + $remainder*$initial_block_size/([math]::Pow(2,$i))
        }
    }
} else {
    $halvings = 0
    $total = $total*$height
}


[console]::Write("`n$total coins minted`n")
$aa = Read-Host("`nPress Enter to continue...  ")
