{-# LANGUAGE TemplateHaskell #-}

-- | More complex types from the paper.

module RSCoin.Core.Types
       ( PeriodId
       , Mintette (..)
       , Mintettes
       , MintetteId
       , LogChainHead
       , LogChainHeads
       , CheckConfirmation (..)
       , CheckConfirmations
       , ActionLogEntry (..)
       , ActionLog
       , LBlock (..)
       , Dpk
       , HBlock (..)
       ) where

import qualified Data.Map               as M
import           Data.SafeCopy          (base, deriveSafeCopy)

import           RSCoin.Core.Crypto     (Hash, PublicKey, Signature)
import           RSCoin.Core.Primitives (AddrId, Transaction)

-- | Periods are indexed by sequence of numbers starting from 0.
type PeriodId = Int

-- | All the information about a particular mintette.
data Mintette = Mintette
    { mintetteHost :: !String
    , mintettePort :: !Int
    , mintetteKey  :: !PublicKey
    }

$(deriveSafeCopy 0 'base ''Mintette)

-- | Mintettes list is stored by Bank and doesn't change over period.
type Mintettes = [Mintette]

-- | Mintette is identified by it's index in mintettes list stored by Bank.
-- This id doesn't change over period, but may change between periods.
type MintetteId = Int

-- | Each mintette has a log of actions along with hash which is chained.
-- Head of this chain is represented by pair of hash and sequence number.
type LogChainHead = (Hash, Int)

-- | ChainHeads is a map containing head for each mintette with whom
-- the particular mintette has indirectly interacted.
type LogChainHeads = M.Map MintetteId LogChainHead

-- | CheckConfirmation is a confirmation received by user from mintette as
-- a result of CheckNotDoubleSpent action.
data CheckConfirmation = CheckConfirmation
    { ccMintetteKey       :: !PublicKey     -- ^ key of corresponding mintette
    , ccMintetteSignature :: !Signature     -- ^ signature for (tx, addrid, head)
    , ccHead              :: !LogChainHead  -- ^ head of log
    } deriving (Show)

-- | CheckConfirmations is a bundle of evidence collected by user and
-- sent to mintette as payload for Commit action.
type CheckConfirmations = M.Map (MintetteId, AddrId) CheckConfirmation

-- | Each mintette mantains a high-integrity action log, consisting of entries.
data ActionLogEntry
    = QueryEntry !Transaction
    | CommitEntry !Transaction
                  !CheckConfirmations
    | CloseEpochEntry !LogChainHeads
    deriving (Show)

-- | Action log is a list of entries.
type ActionLog = [ActionLogEntry]

-- | Lower-level block generated by mintette in the end of an epoch.
-- To form a lower-level block a mintette uses the transaction set it
-- formed throughout the epoch and the hashes it has received from other
-- mintettes.
data LBlock = LBlock
    { lbHash         :: !Hash          -- ^ hash of
                                       -- (h^(i-1)_bank, h^m_(j-1), hashes, transactions)
    , lbTransactions :: [Transaction]  -- ^ txset
    , lbSignature    :: !Signature     -- ^ signature given by mintette for hash
    , lbHeads        :: LogChainHeads  -- ^ heads received from other mintettes
    } deriving (Show)

-- | DPK is a list of signatures which authorizies mintettes for one period
type Dpk = [(PublicKey, Signature)]

-- | Higher-level block generated by bank in the end of a period.
-- To form a higher-level block bank uses lower-level blocks received
-- from mintettes and simply merges them after checking validity.
data HBlock = HBlock
    { hbHash         :: !Hash
    , hbTransactions :: [Transaction]
    , hbSignature    :: !Signature
    , hbDpk          :: Dpk
    } deriving (Show)
