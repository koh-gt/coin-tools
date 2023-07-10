$b58chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
$b58base = $b58chars.Length

function sha256hash([byte[]] $x){
    $sha256 = New-Object System.Security.Cryptography.SHA256CryptoServiceProvider
    $sha256.ComputeHash($sha256.ComputeHash($x), 0, $sha256.HashSize / 8)
}

function b58encode([byte[]] $v){
    $long_value = [bigint]::Zero
    for ($i = 0; $i -lt $v.Length; $i++){
        $long_value += [bigint]::Pow(256, $i) * $v[$v.Length - $i - 1]
    }

    $result = ''
    while ($long_value -ge $b58base){
        $div = [bigint]::Divide($long_value, $b58base)
        $mod = [bigint]::Remainder($long_value, $b58base)
        $result = $b58chars[$mod] + $result
        $long_value = $div
    }
    $result = $b58chars[$long_value] + $result

    $nPad = 0
    foreach ($c in $v) {
        if ($c -eq 0) {
            $nPad++
        } else {
            break
        }
    }

    return ($b58chars[0].ToString() * $nPad) + $result
}

function hash_160_to_address([byte[]]$h160, [int]$addrtype){

    if ($h160 -eq $null -or $h160.Length -ne 20){
        return $null
    }

    $vh160 = [byte[]]($addrtype) + $h160
    $h = sha256hash $vh160
    $addr = $vh160 + $h[0..3]
    return (b58encode $addr)
}

function b58decode($v, $length) {
    $longValue = 0L
    for ($i = 0; $i -lt $v.Length; $i++) {
        $c = $v[$v.Length - $i - 1]
        $longValue += $b58chars.IndexOf($c) * [System.Numerics.BigInteger]::Pow($b58base, $i)
    }

    $result = ''
    while ($longValue -ge 256) {
        $div = $longValue / 256
        $mod = $longValue % 256
        $result = [char][int]$mod + $result
        $longValue = $div
    }
    $result = [char][int]$longValue + $result

    return $result
}

function get-leading-ones-from-addr($addr){
    $leadingOnes = ""
    if ($addr -match '^1+') {
        $leadingOnes = $Matches[0]
        return $leadingOnes.length
    } else {
        return 0
    }
}

function bc_address_to_hash_160($addr) {
    
    if ($addr -eq $null -or $addr.Length -eq 0) {
        return $null
    }
    $bytes = b58decode $addr 25

    $leading1 = get-leading-ones-from-addr($addr)

    $START_BYTE = 1
    $END_BYTE = 20
    if ($leading1 -gt 0){
        if ($leading1 -eq 1){
            $START_BYTE = 0
            $END_BYTE = 19
        } else {
            $START_BYTE = 0
            $END_BYTE = 20 - $leading1
            [int] $zerobytes = $leading1 - 1
            $zero_bytearray = New-Object System.Byte[] $zerobytes
            return $zero_bytearray + $bytes[$START_BYTE..$END_BYTE]
        }
    }
    
    if ($bytes -ne $null) {
        return $bytes[$START_BYTE..$END_BYTE]
    }
    return $null
}


# $hexstring = "1ad3b0b711f211655a01142fbb8fecabe8e30b93"

function get-address-from-hash160($hexstr, $ADDRESS_VERSION){
    
    $byteArray = [byte[]]($hexstr -split '(?<=\G..)(?=.)' | ForEach-Object { [byte]::Parse($_, 'HexNumber') })
    $address = hash_160_to_address ($byteArray)($ADDRESS_VERSION)
    return $address
}

function get-hexstring($address){
    $bytes = bc_address_to_hash_160 $address
    if ($bytes -ne $null) {
        $b = [BitConverter]::ToString($bytes) -replace '-'
        return $b
    }
}

# $address = 'LMfoRhZDaAFxDFRCEK7Uu7mYRpLg3BuCoQ'
[string] $address = Read-Host "Input Legacy (P2PKH) public address"
$hexstr = get-hexstring $address
#$hexstr = "00000000b862012514e48faa6a93d29e4f2eb44b"
[console]::WriteLine("`nhash160: $hexstr`n")

# produces addresses that share the same privkey, not necessarily the same Wallet Import Format (WIF)
$currencyArray = @(
    @(0, "Bitcoin (BTC)"),         # privkey WIF 128
    @(30, "Dogecoin (DOGE)"),      # privkey WIF 158
    @(36, "Ferrite (FEC)"),        # privkey WIF 163
    @(48, "Litecoin (LTC)"),       # privkey WIF 176
    @(52, "Namecoin (NMC)")       # privkey WIF 180

    # @(143, "test")
    # @(144, "test")
    # @(255, "test")
)

[int] $PADVERSPACES = 7
[int] $PADNAMESPACES = 20
[int] $PADADDRSPACES = 36

if ($hexstr -ne $null){

    [console]::WriteLine("Version" + " | " + "Name".PadLeft($PADNAMESPACES) + " | " + "Address".PadLeft($PADADDRSPACES))

    foreach ($coin in $currencyArray){
        $version, $name = $coin
        $padver = ([string] $version).PadLeft($PADVERSPACES)
        $padname = $name.PadLeft($PADNAMESPACES)
        $addr = get-address-from-hash160 $hexstr $version
        $padaddr = ([string] $addr).PadLeft($PADADDRSPACES)
        [console]::WriteLine("$padver | $padname | $padaddr")
    }

} else {

    [console]::WriteLine("Invalid address/error")

}

start-sleep 60
