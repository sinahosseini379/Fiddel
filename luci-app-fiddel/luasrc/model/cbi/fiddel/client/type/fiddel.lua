local m, s = ...

local type_name = "fiddel"

s.fields["type"]:value(type_name, "Fiddel")
if not s.fields["type"].default then
	s.fields["type"].default = type_name
end

if s.val["type"] ~= type_name then
	return
end

local option_prefix = "fiddel_"

local function _n(name)
	return option_prefix .. name
end

o = s:option(Value, _n("url"), translate("Subscription URL"), translate("Example: https://raw.githubusercontent.com/.../proxy_configs_tested.txt"))
o.datatype = "string"
o.rmempty = false

o = s:option(Value, _n("update_interval"), translate("Auto Update Interval (Hours)"))
o.datatype = "uinteger"
o.default = "24"
o.placeholder = "24"
o.rmempty = false

o = s:option(Flag, _n("auto_update"), translate("Enable Auto Update"))
o.default = "1"
o.rmempty = false

o = s:option(Button, "update_now", translate("Update Now"))
o.inputstyle = "apply"
o.write = function(self, section)
	luci.sys.call("lua /usr/share/fiddel/fiddel.lua update " .. section .. " >/dev/null 2>&1 &")
end

o = s:option(DummyValue, _n("last_update"), translate("Last Update Time"))
o.cfgvalue = function(self, section)
	return m.uci:get("fiddel", section, _n("last_update")) or translate("Never")
end
