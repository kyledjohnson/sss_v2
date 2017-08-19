// Copyright (c) 2016 The SeventeenSeventySix developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "wallet/wallet.h"
#include "seventeenseventysix/JoinSplit.hpp"
#include "seventeenseventysix/Note.hpp"
#include "seventeenseventysix/NoteEncryption.hpp"

CWalletTx GetValidReceive(ZCJoinSplit& params,
                          const libseventeenseventysix::SpendingKey& sk, CAmount value,
                          bool randomInputs);
libseventeenseventysix::Note GetNote(ZCJoinSplit& params,
                       const libseventeenseventysix::SpendingKey& sk,
                       const CTransaction& tx, size_t js, size_t n);
CWalletTx GetValidSpend(ZCJoinSplit& params,
                        const libseventeenseventysix::SpendingKey& sk,
                        const libseventeenseventysix::Note& note, CAmount value);
