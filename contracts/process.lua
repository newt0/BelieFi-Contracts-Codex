-- BeliefFi DeFAI NFT – Atomic Assets AO Process (MVP)
-- Phase 01-01: Basic structure, state init, helpers
-- Notes: Public Mint system (no allow list) – limits and handlers implemented in later phases.

-- =========================
-- Imports (AO environment)
-- =========================
-- In AOS/AO, `json` is available. Keep require simple for portability.
local json_ok, json = pcall(require, "json")
if not json_ok then
  -- Minimal fallback to avoid runtime errors outside AO; encode/decode used sparingly here.
  json = {
    encode = function(tbl)
      local ok, res = pcall(function() return require("dkjson").encode(tbl) end)
      return ok and res or "{}"
    end,
    decode = function(str)
      local ok, res = pcall(function() return require("dkjson").decode(str) end)
      return ok and res or nil
    end,
  }
end

-- ao global is provided in AO runtime. Guard to avoid errors in local tooling.
_G.ao = _G.ao or {}

-- =========================
-- Constants & Specifications
-- =========================
local SPEC = {
  nft_name = "AO MAXI",
  strategy = "Maximize $AO",
  standard = "AtomicAssets",
  mint_price = { currency = "USDA", amount = 1 },
  supply_cap = 100,
  per_tx_limit = 1,
  public_mint = true,
}

-- =========================
-- Global Metadata Structures
-- =========================
NFT_METADATA = {
  name = SPEC.nft_name,
  standard = SPEC.standard,
  description = "BeliefFi DeFAI NFT – Public Mint MVP",
  attributes = {
    { trait_type = "Strategy", value = SPEC.strategy },
    { trait_type = "Mint Currency", value = SPEC.mint_price.currency },
    { trait_type = "Mint Price", value = tostring(SPEC.mint_price.amount) },
  },
}

-- =========================
-- State Initialization
-- =========================
-- MINT_STATE holds mutable counters and per-address ownership mapping.
MINT_STATE = MINT_STATE or {
  process = {
    version = "0.1.0-mvp",
    initialized_at = os.time(),
  },
  supply = {
    cap = SPEC.supply_cap,
    minted = 0,
  },
  pricing = {
    currency = SPEC.mint_price.currency,
    amount = SPEC.mint_price.amount,
  },
  policy = {
    public_mint = SPEC.public_mint,
    per_tx_limit = SPEC.per_tx_limit,
    per_address_limit = 1, -- enforced in later phases
  },
  holders = {}, -- map[address] = minted_count
}

-- =========================
-- Helper Utilities (pure)
-- =========================
local Utils = {}

function Utils.trim(s)
  if type(s) ~= "string" then return s end
  return s:match("^%s*(.-)%s*$")
end

function Utils.lower(s)
  if type(s) ~= "string" then return s end
  return string.lower(s)
end

function Utils.upper(s)
  if type(s) ~= "string" then return s end
  return string.upper(s)
end

function Utils.safe_tonumber(v)
  if type(v) == "number" then return v end
  if type(v) == "string" then
    local n = tonumber(v)
    return n
  end
  return nil
end

function Utils.is_positive_integer(v)
  local n = Utils.safe_tonumber(v)
  return n ~= nil and n > 0 and math.floor(n) == n
end

function Utils.table_size(t)
  if type(t) ~= "table" then return 0 end
  local c = 0
  for _ in pairs(t) do c = c + 1 end
  return c
end

function Utils.deepcopy(tbl)
  if type(tbl) ~= "table" then return tbl end
  local res = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      res[k] = Utils.deepcopy(v)
    else
      res[k] = v
    end
  end
  return res
end

function Utils.normalize_address(addr)
  return Utils.lower(Utils.trim(addr or ""))
end

function Utils.json_encode(value)
  local ok, out = pcall(json.encode, value)
  return ok and out or "{}"
end

function Utils.json_decode(str)
  if type(str) ~= "string" then return nil end
  local ok, out = pcall(json.decode, str)
  return ok and out or nil
end

-- =========================
-- Accessors (for handlers/tests)
-- =========================
function get_metadata()
  return Utils.deepcopy(NFT_METADATA)
end

function get_state()
  return Utils.deepcopy(MINT_STATE)
end

function reset_state()
  -- Resets dynamic parts while keeping constants from SPEC
  MINT_STATE.supply.minted = 0
  MINT_STATE.holders = {}
  MINT_STATE.process.initialized_at = os.time()
  return get_state()
end

-- =========================
-- Placeholders for future phases
-- =========================
-- Handlers and business logic will be implemented in subsequent prompts:
-- - Public mint flow, per-address limit, supply cap checks
-- - Payment processing (USDA), fund management
-- - Metadata finalization and Atomic Assets compliance
-- - Basic info/balance/metadata handlers
-- - Error handling and simple operational verification

-- Keep module-compatible return for local tooling; AO runtime ignores returns.
return {
  SPEC = SPEC,
  NFT_METADATA = NFT_METADATA,
  MINT_STATE = MINT_STATE,
  Utils = Utils,
  get_metadata = get_metadata,
  get_state = get_state,
  reset_state = reset_state,
}

