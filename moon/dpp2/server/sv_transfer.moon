
-- Copyright (C) 2015-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

DPP2.DoTransfer = (fents = {}, ply = NULL) ->
	ent\DPP2SetOwner(ply) for ent in *fents when ent\DPP2GetOwner() ~= ply
	DPP2.IN_TRANSFER = true

	if tab = undo.GetTable()
		for UniqueID, data in pairs(tab)
			toremove = {}

			for index, udata in pairs(data)
				if udata.Owner ~= ply
					removeAll = true
					everHit = false

					for ent in *udata.Entities
						hit = false

						for ent2 in *fents
							if ent == ent2
								hit = true
								everHit = true
								break

						if not hit
							removeAll = false
							break

					if everHit
						if removeAll
							if IsValid(ply)
								undo.Create(udata.Name or 'Prop')
								undo.AddEntity(ent) for ent in *udata.Entities when IsValid(ent)
								undo.AddFunction(func) for func in *udata.Functions
								undo.SetPlayer(ply)
								undo.Finish()

							table.insert(toremove, index)
						else
							toremove2 = {}

							for index2, ent in inpairs(udata.Entities)
								hit = false

								for ent2 in *fents
									if ent == ent2
										hit = true
										break

								table.insert(toremove2, index2) if not hit

							table.removeValues(udata.Entities, toremove2)

			table.sort(toremove)
			table.removeValues(data, toremove)

	DPP2.IN_TRANSFER = false

DPP2.cmd.transfer = (args = {}) =>
	return 'message.dpp2.concommand.generic.invalid_side' if not IsValid(@)
	str = table.concat(args, ' ')
	ply = DPP2.FindPlayerInCommand(str)
	return 'message.dpp2.concommand.generic.notarget' if not ply or ply == @
	return 'message.dpp2.concommand.generic.no_bots' if ply\IsBot()
	fents = @DPP2FindOwned()
	return 'message.dpp2.concommand.transfer.none' if #fents == 0
	DPP2.DoTransfer(fents, ply)
	DPP2.Notify(true, nil, 'message.dpp2.concommand.transfered', @, ply)

DPP2.cmd.transferent = (args = {}) =>
	return 'message.dpp2.concommand.generic.invalid_side' if not IsValid(@)
	sent = table.remove(args, 1)
	ent = Entity(tonumber(sent or -1) or -1)

	if not IsValid(ent)
		for ent2 in *@DPP2FindOwned()
			if tostring(ent2) == sent
				ent = ent2
				break

	return 'message.dpp2.concommand.transferent.notarget' if not IsValid(ent)
	return 'message.dpp2.concommand.transferent.not_owner' if ent\DPP2GetOwner() ~= @
	str = table.concat(args, ' ')
	ply = DPP2.FindPlayerInCommand(str)
	return 'message.dpp2.concommand.generic.notarget' if not ply or ply == @
	return 'message.dpp2.concommand.generic.no_bots' if ply\IsBot()
	DPP2.DoTransfer({ent}, ply)
	DPP2.Notify(@, nil, 'message.dpp2.concommand.transferent.success', ent, ply)
	-- admin log

DPP2.cmd.transfertoworld = (args = {}) =>
	return 'message.dpp2.concommand.generic.invalid_side' if not IsValid(@)
	fents = @DPP2FindOwned()
	return 'message.dpp2.concommand.transfer.none' if #fents == 0
	DPP2.DoTransfer(fents, NULL)
	-- admin log
	-- DPP2.Notify(true, nil, 'message.dpp2.concommand.transfertoworld', @, ply)

DPP2.cmd.transferfallback = (args = {}) =>
	return 'message.dpp2.concommand.generic.invalid_side' if not IsValid(@)
	str = table.concat(args, ' ')
	ply = DPP2.FindPlayerInCommand(str)
	return 'message.dpp2.concommand.generic.notarget' if not ply or ply == @
	return 'message.dpp2.concommand.generic.no_bots' if ply\IsBot()
	return 'message.dpp2.concommand.transfer.already_ply', ply if @GetNWEntity('dpp2_transfer_fallback', NULL) == ply
	@SetNWEntity('dpp2_transfer_fallback', ply)
	DPP2.Notify(@, nil, 'message.dpp2.concommand.transferfallback', ply)

DPP2.cmd.transferunfallback = (args = {}) =>
	return 'message.dpp2.concommand.generic.invalid_side' if not IsValid(@)
	return 'message.dpp2.concommand.transfer.none_ply' if not IsValid(@GetNWEntity('dpp2_transfer_fallback', NULL))
	@SetNWEntity('dpp2_transfer_fallback', NULL)
	DPP2.Notify(@, nil, 'message.dpp2.concommand.transferunfallback', ply)

PlayerDisconnected = =>
	if IsValid(@GetNWEntity('dpp2_transfer_fallback', NULL))
		fents = @DPP2FindOwned()
		if #fents ~= 0
			DPP2.DoTransfer(fents, @GetNWEntity('dpp2_transfer_fallback', NULL))
			DPP2.Notify(true, nil, 'message.dpp2.transfer.as_fallback', @Nick(), @SteamID(), #fents, @GetNWEntity('dpp2_transfer_fallback', NULL))

	for ply in *player.GetAll()
		if ply ~= @
			if @GetNWEntity('dpp2_transfer_fallback', NULL) == @
				DPP2.Notify(ply, nil, 'message.dpp2.transfer.no_more_fallback')

hook.Add 'PlayerDisconnected', 'DPP2.Fallback', PlayerDisconnected, -1
