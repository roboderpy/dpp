
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

TMySQL4: https://facepunch.com/showthread.php?t=1442438
mysqloo: https://facepunch.com/showthread.php?t=1515853
]]

file.CreateDir('dmysql3')

local DefaultOptions = {
	UseMySQL = false,
	Host = 'localhost',
	Database = 'test',
	User = 'user',
	Password = 'pass',
	Port = 3306,
}

local DefaultConfigString = util.TableToJSON(DefaultOptions, true)

if not file.Exists('dmysql3/default.txt', 'DATA') then
	file.Write('dmysql3/default.txt', DefaultConfigString)
end

DMySQL3 = DMySQL3 or {}

DMySQL3.LINKS = DMySQL3.LINKS or {}

DMySQL3.obj = DMySQL3.obj or {}
local obj = DMySQL3.obj
obj.__index = obj

function DMySQL3.WriteConfig(config, data)
	file.Write('dmysql3/' .. config .. '.txt', util.TableToJSON(data, true))
end

function DMySQL3.Connect(config)
	config = config or 'default'
	
	if DMySQL3.LINKS[config] then
		DMySQL3.LINKS[config]:Disconnect()
		DMySQL3.LINKS[config]:ReloadConfig()
		DMySQL3.LINKS[config]:Connect()
		return DMySQL3.LINKS[config]
	end
	
	local self = setmetatable({}, obj)
	self.config = config
	
	self:ReloadConfig()
	
	DMySQL3.LINKS[config] = self
	
	self:Connect()
	
	return self
end

local Prefix = '[DMySQL3] '
local PrefixColor = Color(0, 200, 0)
local TextColor = Color(200, 200, 200)

function DMySQL3.Message(...)
	MsgC(PrefixColor, Prefix, TextColor, ...)
	MsgC('\n')
end

obj.UseMySQL = false
obj.IsMySQL = false
obj.UseTMySQL4 = false
obj.Host = 'localhost'
obj.Database = 'test'
obj.User = 'user'
obj.Password = 'pass'
obj.Port = 3306

local tmsql, moo = file.Exists("bin/gmsv_tmysql4_*", "LUA"), file.Exists("bin/gmsv_mysqloo_*", "LUA")

function obj:Connect()
	if not self.UseMySQL then 
		DMySQL3.Message(self.config, ': Using SQLite')
		self.IsMySQL = false
		return
	end
	
	if not tmsql and not moo then
		DMySQL3.Message(self.config, ': No TMySQL4 module installed!\nGet latest at https://facepunch.com/showthread.php?t=1442438')
		DMySQL3.Message(self.config, ': Using SQLite')
		self.IsMySQL = false
		return
	end

	if tmsql then
		local hit = false
		
		xpcall(function()
			require("tmysql4")
			
			DMySQL3.Message(self.config, ': Trying to connect to ' .. self.Host .. ' using driver TMySQL4')
			
			local Link, Error = tmysql.initialize(self.Host, self.User, self.Password, self.Database, self.Port)
			
			if not Link then
				DMySQL3.Message(self.config, ': connection failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.\n' .. Error .. '')
				self.IsMySQL = false
			else
				DMySQL3.Message(self.config, ': Success')
				self.LINK = Link
				self.IsMySQL = true
				self.UseTMySQL4 = true
				hit = true
			end
		end, function(err)
			DMySQL3.Message(self.config, ': connection failed:\nCannot intialize a binary TMySQL4 module (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '')
			self.IsMySQL = false
		end)
		
		if hit then return end
	end
	
	if moo then
		DMySQL3.Message('DMySQL3 recommends to use TMySQL4!')
		
		xpcall(function()
			require("mysqloo")
			
			DMySQL3.Message(self.config, ': Trying to connect to ' .. self.Host .. ' using driver MySQLoo')
			local Link = mysqloo.connect(self.Host, self.User, self.Password, self.Database, self.Port)
			
			Link:connect()
			Link:wait()
			
			local Status = Link:status()
			
			if Status == mysqloo.DATABASE_CONNECTED then
				DMySQL3.Message(self.config, ': Success')
				self.IsMySQL = true
				self.LINK = Link
			else
				DMySQL3.Message(self.config, ': connection failed: \nInvalid username or password, wrong hostname or port, database does not exists, or given user can\'t access it.')
				DMySQL3.Message(Link:hostInfo())
			end
		end, function(err)
			DMySQL3.Message(self.config, ': connection failed:\nCannot intialize a binary MySQLoo module (internal error). Are you sure that your installed module for your OS? (linux/windows)\n' .. err .. '')
			self.IsMySQL = false
		end)
	end
end

function obj:Disconnect()
	DMySQL3.Message(self.config .. ': disconnected from database')
	if not self.IsMySQL then return end
	if self.UseTMySQL4 then
		self.LINK:Disconnect()
		return
	end
	
	--Put MySQLoo disconnect function here
end

function obj:ReloadConfig()
	local config = self.config
	
	if not file.Exists('dmysql3/' .. config .. '.txt', 'DATA') then
		file.Write('dmysql3/' .. config .. '.txt', DefaultConfigString)
		DMySQL3.Message('Creating default config for "' .. config .. '"')
	end
	
	local confStr = file.Read('dmysql3/' .. config .. '.txt', 'DATA')
	
	if not confStr or confStr == '' then
		confStr = DefaultConfigString
		DMySQL3.Message(config, ': ATTENTION: Config corrupted!')
	end
	
	local config = util.JSONToTable(confStr)
	
	if not config then
		config = table.Copy(DefaultOptions)
		DMySQL3.Message(config, ': ATTENTION: Config corrupted!')
	end
	
	if config.Host == 'localhost' and not system.IsWindows() then
		config.Host = '127.0.0.1'
		DMySQL3.Message(config, ':Warning: Forcing to use 127.0.0.1 instead of localhost. https://github.com/roboderpy/dpp/issues/6')
	end
	
	self.UseMySQL = config.UseMySQL
	self.Host = config.Host
	self.Database = config.Database
	self.User = config.User
	self.Password = config.Password
	self.Port = config.Port
end

local EMPTY = function() end

function obj:Query(str, success, failed)
	success = success or EMPTY
	failed = failed or EMPTY
	
	if not self.IsMySQL then
		local data = sql.Query(str)
		
		if data == false then
			xpcall(failed, debug.traceback, sql.LastError())
		else
			xpcall(success, debug.traceback, data or {})
		end
		
		return
	end
	
	if self.UseTMySQL4 then
		if not self.LINK then
			Connect()
		end
		
		if not self.LINK then
			DMySQL3.Message(self.config, ': Connection to database lost while executing query!')
			return
		end
		
		self.LINK:Query(str, function(data)
			local data = data[1]
			
			if not data.status then
				xpcall(failed, debug.traceback, data.error)
			else
				xpcall(success, debug.traceback, data.data or {})
			end
		end)
		
		return
	end
	
	local obj = self.LINK:query(str)
	
	function obj.onSuccess(q, data)
		xpcall(success, debug.traceback, data or {})
	end
	
	function obj.onError(q, err)
		if self.LINK:status() == mysqloo.DATABASE_NOT_CONNECTED then
			Connect()
			DMySQL3.Message(self.config, ': Connection to database lost while executing query!')
			return
		end
		
		xpcall(failed, debug.traceback, err)
	end
	
	obj:start()
end

obj.TRX = {}

function obj:Add(str, success, failed)
	success = success or EMPTY
	failed = failed or EMPTY
	
	table.insert(self.TRX, {str, success, failed})
end

function obj:Begin(nobegin)
	self.TRX = {}
	self.TRXNoCommit = nobegin
	
	if not nobegin then
		self:Add('BEGIN')
	end
end

function obj:Commit(finish)
	finish = finish or EMPTY
	
	if not self.TRXNoCommit then
		self:Add('COMMIT')
	end
	
	local TRX = self.TRX
	self.TRX = {}
	
	local current = 1
	local total = #TRX
	
	local success, err
	
	function success(data)
		xpcall(TRX[current][2], debug.traceback, data)
		current = current + 1
		if current >= total then xpcall(finish, debug.traceback) return end
		self:Query(TRX[current][1], success, err)
	end
	
	function err(data)
		xpcall(TRX[current][3], debug.traceback, data)
		current = current + 1
		if current >= total then xpcall(finish, debug.traceback) return end
		self:Query(TRX[current][1], success, err)
	end
	
	self:Query(TRX[current][1], success, err)
end

DMySQL3.Connect('default')