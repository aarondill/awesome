local exists = require("util.file.sync.exists")
local gstring = require("gears.string")
-- This test is inaccurate, but given separate / and /boot partitions and the
-- fact that only some architectures have ld-linux.so, I can't see anything
-- better. Make sure this test has a high number so that more accurate tests
-- can come first.
-- Unless volumes to checked are already mounted, they will be mounted using
-- GRUB's own filesystems through FUSE. Since these ATM doesn't support
-- symlinks we need to also check in /usr/lib* for distributions that
-- moved /lib* to /usr and only left symlinks behind.

---@class iolib
---@field lines fun(file: string, mode: readmode): (fun(): string, nil, nil, file*)
io.lines = io.lines -- fix the types

---@param file string path
---@return string?
local function get_name_from_release(file)
  for line in io.lines(file, "l") do
    local varname = "NAME=" -- This should end in '='!
    if gstring.startswith(line, varname) then
      local name = line
        :sub((varname):len() + 1) -- Remove NAME=
        :gsub("^[\"'](.*)['\"]$", "%1") -- Remove "quotes"
        :gsub("\\(.)", "%1") -- Unescape
      -- remove anything after the first space
      -- This isn't strictly necessary, but os-prober does it, and it makes it easier to detect names
      return (name:gsub("%s.*", ""))
    end
  end
end
local M = {}

-- Translated from os-prober
---@return string
function M.get_full_os_name()
  ---@alias DistroRet string|fun(file: string): string?
  ---@type {[1]:string, [2]:DistroRet}[]
  ---The left-hand side is the file to check for existing (or function to run)
  ---The right-hand side is the return value (or a function that will generate it)
  ---NOTE: This table of tables is required to keep the order. If a hash-table is used, the order is not guaranteed
  local tbl = {
    -- One of the /etc/os-release or /usr/os-release files will exist on nearly every system
    { "/etc/os-release", get_name_from_release },
    { "/usr/os-release", get_name_from_release },
    { "/etc/debian_version", "Debian" },
    -- RPM derived distributions may also have a redhat-release or
    -- mandrake-release, so check their file}s first.
    { "/etc/altlinux-release", "ALTLinux" },
    { "/etc/magic-release", "Magic" },
    { "/etc/blackPanther-release", "blackPanther" },
    { "/etc/ark-release", "Ark" },
    { "/etc/arch-release", "Arch" },
    { "/etc/asplinux-release", "ASPLinux" },
    { "/etc/lvr-release", "LvR" },
    { "/etc/caos-release", "cAos" },
    { "/etc/aurox-release", "Aurox" },
    { "/etc/engarde-release", "EnGarde" },
    { "/etc/vine-release", "Vine" },
    { "/etc/whitebox-release", "WhiteBox" },
    { "/etc/pld-release", "PLD" },
    { "/etc/startcom-release", "StartCom" },
    { "/etc/trustix-release", "Trustix" },
    { "/etc/openna-release", "OpenNA" },
    { "/etc/mageia-release", "Mageia" },
    { "/etc/conectiva-release", "Conectiva" },
    { "/etc/mandrake-release", "Mandrake" },
    { "/etc/fedora-release", "Fedora" },
    { "/etc/redhat-release", "RedHat" },
    { "/etc/SuSE-release", "SuSE" },
    { "/etc/gentoo-release", "Gentoo" },
    { "/etc/cobalt-release", "Cobalt" },
    { "/etc/yellowdog-release", "YellowDog" },
    { "/etc/turbolinux-release", "Turbolinux" },
    { "/etc/pardus-release", "Pardus" },
    { "/etc/kanotix-version", "Kanotix" },
    { "/etc/slackware-version", "Slackware" },
    { "/sbin/pkgtool", "Slackware" },
    { "/etc/frugalware-release", "Frugalware Linux" },
    { "/etc/kdemar-release", "K-DEMar" },
    { "/etc/lfs-release", "LFS" },
    { "/etc/meego-release", "MeeGo" },
    { "/etc/4MLinux-version", "4MLinux" },
    { "/etc/devuan_version", "Devuan" },
    { "/etc/exherbo-release", "Exherbo" },
  }
  for _, t in ipairs(tbl) do
    local file, ret = t[1], t[2]
    if not exists(file) then goto continue end
    if type(ret) == "string" then return ret end
    local str_ret = ret(file)
    if str_ret then return str_ret end
    ::continue::
  end
  return "Linux" -- Default to Linux
end

--- Gets the os name (in a file friendly manner)
--- Note this might have to do a lot of file operations. Cache it!
--- Translated from /etc/grub.d/30_os-prober
function M.get_os_name() ---@return string
  local name = M.get_full_os_name()
  return (name:lower():gsub("%W", "_")) -- replace non-alphanumeric characters with underscores
end
return M
