--- Principal warp build phase of the morphing demo.

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Modules --
local buttons = require("corona_ui.widgets.button")
local tabs_patterns = require("corona_ui.patterns.tabs")

-- Corona globals --
local display = display
local native = native

-- Corona modules --
local composer = require("composer")
local widget = require("widget")

--
local Scene = composer.newScene()

-- Cached dimensions --
local CW, CH = display.contentWidth, display.contentHeight

--
function Scene:show (event)
	if event.phase == "did" then
		local params = event.params

		-- Add a string describing the seam-generation method...
		local method_str = display.newText(self.view, "", 0, 0, native.systemFontBold, 20)

		method_str.anchorX, method_str.x = 1, CW - 20
		method_str.anchorY, method_str.y = 1, CH - 20

		-- ...and tabs used to select it.
		local tabs = tabs_patterns.TabBar(self.view, {
			{
				label = "Method 1", onPress = function()
					params.method, params.two_seams = "vertical", true
					method_str.text = "Top-to-bottom, then left-to-right seams"
				end
			},
			{
				label = "Method 2", onPress = function()
					params.method, params.two_seams = "horizontal", true
					method_str.text = "Left-to-right, then top-to-bottom seams"
				end
			},
			{
				label = "Method 3", onPress = function()
					params.method, params.two_seams = "vertical", false
					method_str.text = "Top-to-bottom seams, then horizontal bars"
				end
			},
			{
				label = "Method 4", onPress = function()
					params.method, params.two_seams = "horizontal", false
					method_str.text = "Left-to-right seams, then vertical bars"
				end
			}
		}, { top = CH - 105, left = CW - 370, width = 350 })

		tabs:setSelected(1, true)

		-- Provide some control over seam density.
		params.iw, params.ih = params.image:GetDims()


		-- Prepare a bitmap to store image energy (if not already created).
		--[[
		local image, values = params.bitmap or bitmap.Bitmap(self.view), {}

		image.x, image.y, image.isVisible = params.bitmap_x, params.bitmap_y, true

		image:Resize(params.iw, params.ih)]]

		-- Find some energy measure of the image and display it as gray levels, allowing the user
		-- to cancel while either is in progress. If both complete, proceed to the generation step.
		local funcs = params.funcs
		local cancel = buttons.Button_XY(self.view, params.ok_x, params.cancel_y, 100, 40, function()
			funcs.Cancel()
			composer.showOverlay("morphing.ChooseFile", { params = params })
		end, "Cancel")

		funcs.Action(function()
			funcs.SetStatus("Generating warp")

			--

			cancel.isVisible = false

		--	funcs.SetStatus("Press OK to carve seams")
			buttons.Button_XY(self.view, params.ok_x, params.ok_y, 100, 40, function()
			--	params.bitmap, params.energy, params.gray = image, values, energy.ToGray

			--	funcs.ShowOverlay("seams.GenSeams", params)
			end, "OK")
		end)()
	end
end

Scene:addEventListener("show")

return Scene