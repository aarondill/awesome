---@param seconds number?
---@param poststr string?
---@return string?
local function format_message(seconds, poststr)
  if not seconds or seconds <= 0 then return poststr end
  local hours = math.floor(seconds / 3600)
  seconds = seconds - (3600 * hours)
  local minutes = math.floor(seconds / 60)
  seconds = seconds - (60 * minutes)
  return string.format("%02.0f:%02.0f:%02.0f %s", hours, minutes, seconds, poststr or "")
end
---Calculate the time remaining until full/dead battery
---@param info battery_info
---@source ACPIclient source code
---@return string?
local function calculate_time_remaining(info)
  local MIN_PRESENT_RATE = 0.01 -- Less than this is considered zero
  local status = info.status and string.lower(info.status)
  local power_now = info.current_now or info.power_now
  local present_rate = power_now and (tonumber(power_now) / 1000) or nil
  local voltage = info.voltage_now and (tonumber(info.voltage_now) / 1000) or nil
  local last_capacity = info.charge_full and (tonumber(info.charge_full) / 1000) or nil
  local last_capacity_unit = info.energy_full and (tonumber(info.energy_full) / 1000) or nil
  local remaining_energy = info.energy_now and (tonumber(info.energy_now) / 1000) or nil
  local remaining_capacity = info.charge_now and (tonumber(info.charge_now) / 1000) or nil

  if not present_rate or not remaining_energy then return format_message(nil, "rate information unavailable") end

  if not remaining_capacity then
    if voltage then
      remaining_capacity = (remaining_energy * 1000) / voltage
      present_rate = (present_rate * 1000) / voltage
    else
      remaining_capacity = remaining_energy
    end
  end

  -- convert energy values (in mWh) to charge values (in mAh) if needed and possible
  if last_capacity_unit and not last_capacity then
    last_capacity = voltage and (last_capacity_unit * 1000 / voltage) or last_capacity_unit
  end
  if not last_capacity then return format_message(nil, "battery capacity unavailable") end

  if present_rate <= MIN_PRESENT_RATE then present_rate = 0 end

  if status == "full" then return format_message(nil, nil) end

  if status == "charging" then
    if present_rate == 0 then return format_message(nil, "charging at zero rate - will never fully charge.") end
    -- The seconds left until full
    local seconds = (3600 * (last_capacity - remaining_capacity)) / present_rate
    return format_message(seconds, "until charged")
  end

  if status == "discharging" then
    if present_rate == 0 then return format_message(nil, "discharging at zero rate - will never fully discharge.") end
    local seconds = (3600 * remaining_capacity) / present_rate
    return format_message(seconds, "remaining")
  end

  return format_message(nil, "could not calculate battery time remaining")
end
return calculate_time_remaining
