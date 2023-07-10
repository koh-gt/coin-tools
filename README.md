# coin-tools
A collection of cryptocurrency coin tools

## addrconv
A Powershell script enerates addresses that share the same private key across all added altcoins.

## sendmany
`Old script - Imported from koh-gt/sendmany-gen`<br>
A Powershell Script that reads addresses from text and converts into a sendmany console command.

Text file(s) will be generated.
Default minimum send is 0.00000546 (546 satoshi) per address because of dust limit.
You can opt to send fewer, but the command may not work.

Default transaction size is 2,000 addresses (~68000 Bytes) because of 100kB transaction limit.
You can opt to set to send to more addresses per transaction, but transaction may be too large.

Default fee is 100 sat/vB because most bitcoin forks have a minimum relay transaction fee of 100 sat/vB.
You should set it lower if you are transferring an expensive coin, such as Bitcoin.
There is a list of recommended lowest transaction fees for each coin.
Setting too low a fee may cause transaction to be stuck in mempool, or take a long time to confirm.

Recommended lowest transaction sizes in sat/vB
Name    | Symbol | Fee (sat/vB) | Amount |
--------|--------|--------------|--------|
Bitcoin     |  BTC  |    1 | 0.00000546  |
Litcoin     |  LTC  |   10 | 0.00005460  |
Namecoin    |  NMC  |  100 | 0.00054600  |
Ferritecoin |  FEC  | 1000 | 0.00010000  |

## circulating
`Old script - Imported from koh-gt/coin-supply`<br>
A Powershell script that calculates the total coin supply in circulation given the blockchain height.
