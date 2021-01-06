---
layout: post
title: Ledger Accounting
date: 2021-01-06 22:35:00
comment_id: 123
categories: [Accounting]
tags: [Ledger]
---

Recently I'd like to find if there is any tools that I can account my expense and revenue in local. Then I found this tool -> [Ledger](https://www.ledger-cli.org/)

Ledger is powerful and have been created almost 20 years ago. It's open sourced and can be used in command line easily. I thought it should be a good start for my pc accounting ~

## What it will look like

Ledger can generate detail account report via a simply command line:

```s
ledger -f YourLedgerFile.ledger register
```

A typical transaction will look like this:

```dat
2021/01/06 Shopping
    Expenses:Food:Groceries                 $42.00
    Assets:Checking                        
```

A simple report will look like this:

```s
ledger -f ledger.dat bal
             $-42.00  Assets:Checking
              $42.00  Expenses:Food:Groceries
--------------------
                   0
```

## How to use it

There are 5 high level account types:

- Expenses: where money goes,
- Assets: where money sits,
- Income: where money comes from,
- Liabilities: money you owe,
- Equity: the real value of your property.

We can also define sub-account based on the requirement, ex: Expense:Food

### Frequent Command

```s
#  Include the config file.
include meta.txt

# Strict 
# in the ledger.dat file's beginning, addd
account Assets:Checking
alias Checking=Assets:Checking
commodity CNY
# run command by
$ ledger -f ledger.dat balance checking --strict

# check balance not contains assets or liabilities, use to check credit card
$ ledger -f ledger.dat balance ^assets or ^liabilities

# check liabilities details
$ ledger -f ledger.dat -s '-date' reg liabilities

# check period expense
$ ledger -f ledger.dat -b '-date' -d '-date' bal '^Expense:Food'

# Budget
~ Monthly
    Expenses:Food       $300.00
    Assets:Checking

$ ledger -f ledger.dat --budget balance food

# Limit report date
# use -b -e
$ ledger -f ledger.dat -b 2019-09-01 -e 2019-09-31 --budget balance food
# use -p
$ ledger -f ledger.dat register groceries -p "this month"
$ ledger -f ledger.dat register groceries -p "Jan 2021"

# Unit price
2021/01/06 * Farmer Market
    Expenses:Food       10 apples @ $0.30
    Assets:Checking

# Show monthly expenses & average since Jan 2021
$ led -M -n -A --limit "date>=[2021/01/06]" reg ^Expenses

# Show monthly expenses since Jan 2021 & average monthly expense since the dawn of time
$ led -M -n -A --display "date>=[2021/01/06]" reg ^Expenses

# Show monthly expenses for Jan 2021 & average monthly expenses since Mar 2021
$ led -M -n -A --limit "date>=[2021/03/06]" --display "date>=[2021/01/06]" reg ^Expenses

# currency history file
P 2004/06/21 02:18:01 FEQTX $22.49
P 2004/06/21 02:18:01 BORL $6.20
P 2004/06/21 02:18:02 AAPL $32.91
P 2004/06/21 02:18:02 AU $400.00

# specify price to import in terms of market value
$ ledger --price-db prices.db -V balance brokerage
```

#### Reference

- <https://www.ledger-cli.org/>
