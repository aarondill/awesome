local function format_message(seconds, poststr)
  if not seconds or seconds <= 0 then return poststr or "" end
  local hours = math.floor(seconds / 3600)
  seconds = seconds - (3600 * hours)
  local minutes = math.floor(seconds / 60)
  seconds = seconds - (60 * minutes)
  return string.format("%02.0f:%02.0f:%02.0f %s", hours, minutes, seconds, poststr or "")
end
---Calculate the time remaining until full/dead battery
---@param info battery_info
---@source ACPIclient source code
---@return string
local function calculate_time_remaining(info)
  local MIN_PRESENT_RATE = 0.01 -- Less than this is considered zero
  local status = string.lower(info.status)
  local power_now = info.current_now or info.power_now
  local present_rate = power_now and tonumber(power_now) / 1000
  local voltage = info.voltage_now and tonumber(info.voltage_now) / 1000
  local last_capacity = info.charge_full and tonumber(info.charge_full) / 1000
  local last_capacity_unit = info.energy_full and tonumber(info.energy_full) / 1000
  local remaining_energy = info.energy_now and tonumber(info.energy_now) / 1000
  local remaining_capacity = info.charge_now and tonumber(info.charge_now) / 1000

  if not present_rate then return format_message(nil, "rate information unavailable") end

  if remaining_energy and not remaining_capacity then
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

  if present_rate <= MIN_PRESENT_RATE then present_rate = 0 end
  local seconds = nil -- The seconds left until full/zero

  if status == "charging" then
    if present_rate == 0 then return format_message(nil, "charging at zero rate - will never fully charge.") end
    seconds = (3600 * (last_capacity - remaining_capacity)) / present_rate
    return format_message(seconds, "until charged")
  end

  if status == "discharging" then
    if present_rate == 0 then return format_message(nil, "discharging at zero rate - will never fully discharge.") end
    seconds = (3600 * remaining_capacity) / present_rate
    return format_message(seconds, "remaining")
  end

  return format_message(nil, nil)
end
return calculate_time_remaining
