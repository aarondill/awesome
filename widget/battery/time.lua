local function num_dev_1000_or_neg_1(num)
  return num and tonumber(num) / 1000 or -1
end
---@param info battery_info
---@return string
local function calculate_time_remaining(info)
  local MIN_PRESENT_RATE = 0.01 -- Less than this is considered zero
  local status = string.lower(info.status)
  local present_rate = num_dev_1000_or_neg_1(info.current_now or info.power_now)
  local remaining_capacity = num_dev_1000_or_neg_1(info.charge_now)
  local last_capacity = num_dev_1000_or_neg_1(info.charge_full)
  local voltage = num_dev_1000_or_neg_1(info.voltage_now)
  local remaining_energy = num_dev_1000_or_neg_1(info.energy_now)
  local last_capacity_unit = num_dev_1000_or_neg_1(info.energy_full)

  if remaining_energy ~= -1 and remaining_capacity == -1 then
    if voltage ~= -1 then
      remaining_capacity = (remaining_energy * 1000) / voltage
      present_rate = (present_rate * 1000) / voltage
    else
      remaining_capacity = remaining_energy
    end
  end
  -- convert energy values (in mWh) to charge values (in mAh) if needed and possible
  if last_capacity_unit ~= -1 and last_capacity == -1 then
    if voltage ~= -1 then
      last_capacity = last_capacity_unit * 1000 / voltage
    else
      last_capacity = last_capacity_unit
    end
  end

  local poststr = nil -- The string to append
  local seconds = nil -- The seconds left until full/zero
  if present_rate == -1 then
    poststr = "rate information unavailable"
    seconds = -1
  elseif status == "charging" then
    if present_rate > MIN_PRESENT_RATE then
      seconds = (3600 * (last_capacity - remaining_capacity)) / present_rate
      poststr = " until charged"
    else
      poststr = "charging at zero rate - will never fully charge."
      seconds = -1
    end
  elseif status == "discharging" then
    if present_rate > MIN_PRESENT_RATE then
      seconds = (3600 * remaining_capacity) / present_rate
      poststr = " remaining"
    else
      poststr = "discharging at zero rate - will never fully discharge."
      seconds = -1
    end
  else
    poststr = nil
    seconds = -1
  end

  local remaining
  if seconds > 0 then
    local hours = math.floor(seconds / 3600)
    seconds = seconds - (3600 * hours)
    local minutes = math.floor(seconds / 60)
    seconds = seconds - (60 * minutes)
    remaining = string.format(", %02.0f:%02.0f:%02.0f%s", hours, minutes, seconds, poststr)
  elseif poststr then
    remaining = string.format(", %s", poststr)
  end
  return remaining
end
return calculate_time_remaining
