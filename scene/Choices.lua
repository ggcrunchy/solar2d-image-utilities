--- The samples scene.
--
-- Consult the wiki for more details.

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

-- Standard library imports --
local exit = os.exit

-- Modules --
local args = require("iterator_ops.args")
local button = require("corona_ui.widgets.button")
local file_utils = require("corona_utils.file")
local scenes = require("corona_utils.scenes")
local table_view_patterns = require("corona_ui.patterns.table_view")

-- Corona globals --
local display = display
local native = native
local system = system
local transition = transition

-- Corona modules --
local composer = require("composer")
local sqlite3 = require("sqlite3")

-- Is this running on the simulator? --
local OnSimulator = system.getInfo("environment") == "simulator"

-- Use graceful exit method on Android.
if system.getInfo("platformName") == "Android" then
	exit = native.requestExit
end

-- Title scene --
local Scene = composer.newScene()

--
local ReturnToChoices = scenes.Opener{ name = "scene.Choices" }

-- --
local Params = {
	boilerplate = function(view)
		button.Button_XY(view, 120, 75, 200, 50, ReturnToChoices, "Go Back")
	end
}

--
local function GoToScene (dir)
	return function()
		scenes.SetListenFunc(function(what)
			if what == "message:wants_to_go_back" then
				ReturnToChoices()
			end
		end)
		composer.gotoScene(dir .. ".core", { params = Params })
	end
end

--
function Scene:create ()
	local bh = 50

	for i, func, text in args.ArgsByN(2,
		GoToScene("colored_corners"), "Colored Corners",
		GoToScene("seams", "Seams"), "Seams",
		function()
			if not OnSimulator then
				exit()
			end
		end, "Exit"
	) do
		button.Button_XY(self.view, display.contentCenterX, display.contentCenterY + (i - 1) * (bh + 25), 400, bh, func, text)
	end
	-- ^^ TODO: Use layout...
end

Scene:addEventListener("create")

--
function Scene:show (event)
	if event.phase == "did" then
		scenes.SetListenFunc(nil)
	end
end

Scene:addEventListener("show")

return Scene