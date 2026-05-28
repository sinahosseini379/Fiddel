#!/usr/bin/lua

local api = require "luci.fiddel.api"
local appname = api.appname
local fs = require "nixio.fs"
local sys = api.sys

local action = arg[1]
local node_id = arg[2]

if not action or not node_id then
	print("Usage: fiddel.lua update <node_id>")
	return
end

local uci = api.uci

if action == "update" then
	local url = uci:get(appname, node_id, "fiddel_url")
	if not url or url == "" then
		print("Error: No URL found for Fiddel node " .. node_id)
		return
	end

	local group_name = "Fiddel_" .. node_id
	
	-- Truncate old nodes
	sys.call(string.format("lua /usr/share/fiddel/subscribe.lua truncate '%s'", group_name))

	-- Fetch new nodes
	local tmp_file = "/tmp/fiddel_" .. node_id .. ".txt"
	local cmd = string.format("curl -s -L -o %s '%s'", tmp_file, url)
	sys.call(cmd)

	if fs.access(tmp_file) then
		-- Copy to /tmp/links.conf for subscribe.lua to read
		sys.call(string.format("cp %s /tmp/links.conf", tmp_file))
		-- Add nodes
		sys.call(string.format("lua /usr/share/fiddel/subscribe.lua add '%s'", group_name))
		fs.remove(tmp_file)
		fs.remove("/tmp/links.conf")
	else
		print("Error: Failed to fetch URL.")
		return
	end

	-- Now collect all the nodes added to this group
	local urltest_nodes = {}
	uci:load(appname)
	uci:foreach(appname, "nodes", function(s)
		if s.group == group_name then
			table.insert(urltest_nodes, s[".name"])
		end
	end)

	if #urltest_nodes > 0 then
		-- Update the Fiddel node to act as a urltest node for these fetched nodes
		uci:set(appname, node_id, "protocol", "_urltest")
		uci:set_list(appname, node_id, "urltest_node", urltest_nodes)
		uci:set(appname, node_id, "fiddel_last_update", os.date("%Y-%m-%d %H:%M:%S"))
		uci:commit(appname)
		print("Successfully updated Fiddel node with " .. #urltest_nodes .. " proxies.")
	else
		print("Error: No valid nodes parsed from the subscription.")
	end
end
