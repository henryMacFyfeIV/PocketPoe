import 'CoreLibs/object'
import 'CoreLibs/graphics'

playdate.display.setRefreshRate(20)
local gfx <const> = playdate.graphics

local books = {}

local filePlayer = playdate.sound.fileplayer.new("rain", 1000)

local filePlayerOn = false

local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()
local shelfDimensions = {
	x = 5,
	y = 195,
	w = 390,
	h = 30,
	lineWidth = 3
}

function createBooks(stories)
	for storyKey, storyValue in pairs(stories) do
		local newBook = {}
		local bookHeight = math.random(110, 135)
		local bookWidth = math.random(29, 35)

		if #books == 0 then
			newBook = {
				x = 25,
				y = 195 - bookHeight,
				w = bookWidth,
				h = bookHeight,
				lineWidth = 4,
				title = storyValue.fileHeader,
				storyChunk = storyValue.storyChunk,
				chunkLength = #storyValue.storyChunk,
				lineIndex = 1
			}
		else
			local lastBook = books[#books]
			newBook = {
				x = lastBook.x + lastBook.w,
				y = 195 - bookHeight,
				w = bookWidth,
				h = bookHeight,
				lineWidth = 4,
				title = storyValue.fileHeader,
				storyChunk = storyValue.storyChunk,
			        chunkLength = #storyValue.storyChunk,
				lineIndex = 1
			}
		end
		table.insert(books, newBook)
	end
end

-- draw books. A book must be flush with leftmost book or left shelf edge, and flush with shelf base
function drawBooks(shelfDimensions, stories)
	for bookKey, book in pairs(books) do
		gfx.drawRect(book.x, book.y, book.w, book.h, book.lineWidth)
	end
end

function drawPage(storyChunk, lineIndex)
	local renderedPage = ""
	local iterator = lineIndex
	local iteratorTerminator = lineIndex + 12
	while iterator < iteratorTerminator do
		nextLine = storyChunk[iterator] or ""
		renderedPage = renderedPage .. nextLine
		iterator = iterator + 1
	end
	gfx.drawTextInRect(renderedPage, 5, 5, 395, 235, nil)
end

-- 	create stories out of directory
local stories = {}
local storyFiles = playdate.file.listFiles("stories/")

for storyFileKey, storyFileValue in pairs(storyFiles) do
	local fileLocation = "stories/" .. storyFileValue
	local file = playdate.file.open(fileLocation, playdate.file.kFileRead)
	local fileHeader = file:readline()
	file:close()
	local file2 = playdate.file.open(fileLocation, playdate.file.kFileRead)
	local storyChunk = {}
	local line = " "
	while (line ~= nil) do
		line = file2:readline()
		if (line) then
			table.insert(storyChunk, line .. "\n")
		end 
	end
	table.insert(stories, { 
			storyChunk = storyChunk,
			fileHeader = fileHeader
		})
	file2:close()
end

createBooks(stories)

-- retriving book savestate, or creating an empty book state
local bookIndexes = playdate.datastore.read("bookIndexes")
if bookIndexes == nil then
	bookIndexes = {}
	for tkey, story in pairs(books) do
		bookIndexes[story.title] = story.lineIndex
	end
	playdate.datastore.write(bookIndexes, "bookIndexes")
end

local previousCursor = 1
local cursor = 2
local shelfView = true
function playdate.update()
	if shelfView then
		gfx.clear()

		-- color in selected book
		local book = books[cursor]
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(book.x + 2, book.y - .5, book.w - 2, book.h - 1)

		gfx.drawText(book.title, 50, 30)

		-- draw shelf
		gfx.drawRect(shelfDimensions.x, shelfDimensions.y, shelfDimensions.w, shelfDimensions.h, shelfDimensions.lineWidth)

		drawBooks(shelfDimensions, stories)

		-- uncolor in last selected book
		local lastBook = books[previousCursor]
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(lastBook.x + 2, lastBook.y - .5, lastBook.w - 2 , lastBook.h - 1)

	else -- draw book view
		gfx.clear()
		local crankPos = playdate.getCrankChange()

		if crankPos ~= 0.00 then
			if crankPos > 0 then
				if bookIndexes[books[cursor].title] < books[cursor].chunkLength - 1 then
					bookIndexes[books[cursor].title] += 1
				end
			end
			if crankPos < 0 then
				if not shelfView and bookIndexes[books[cursor].title] > 1 then
					bookIndexes[books[cursor].title] -= 1
				end
			end
		end
		
		drawPage(books[cursor].storyChunk, bookIndexes[books[cursor].title])
	end
end

-- buttons for page view
function playdate.downButtonDown()
	if not shelfView then
		if bookIndexes[books[cursor].title] < books[cursor].chunkLength - 1 then
			bookIndexes[books[cursor].title] += 1
		end
	end
end

function playdate.upButtonDown()
	if not shelfView and bookIndexes[books[cursor].title] > 1 then
		bookIndexes[books[cursor].title] -= 1
	end
end

-- buttons for shelf view
function playdate.leftButtonDown()
	if cursor > 1 and shelfView then
		previousCursor = cursor
		cursor -= 1
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(30, 20, 330 , 60)
	end
end

function playdate.rightButtonDown()
	if cursor < #books and shelfView then
		previousCursor = cursor ;
		cursor += 1;
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(30, 20, 330 , 60)
	end
end
function playdate.AButtonDown()
	shelfView = false
end

function playdate.BButtonDown()
	if shelfView then
		if filePlayerOn then
		    filePlayer:stop()
		else
		    filePlayer:play(50)
        end
        filePlayerOn = not filePlayerOn
	end
	shelfView = true
	playdate.datastore.write("bookIndexes", bookIndexes)
end

function playdate.gameWillTerminate()
	playdate.datastore.write("bookIndexes", bookIndexes)
end

-- can be used to add stories. just place them in storiesTxt as text files. 
-- the result of this, the formatted stories, can be found here ~/PlaydateSDK/Disk/Data/'Pocket Poe'.
function chunkStories()
	local rawFiles = playdate.file.listFiles("storiesTxt")
	for _, rawFileName in pairs(rawFiles) do
		local rawFile = playdate.file.open("storiesTxt/"..rawFileName)
		local rawStoryContent = rawFile:read(999999999999999)
		rawFile:close()
		local storyWords = {}
		-- finds carriage returns and complete words with punctuation
		for w in rawStoryContent:gmatch("%\n*%S+") do
			table.insert(storyWords, w)
		end

		local lineChunks = {}
		while #storyWords > 1 do
			local newLine = ""
			if storyWords[1] == "\n" then
				newLine = newLine .. storyWords[1]
				table.remove(storyWords, 1)
                break
			else 
				while (#storyWords > 1 and playdate.graphics.getTextSize(newLine .. storyWords[1]) < 389)  do
					newLine = newLine .. storyWords[1] .. " "
					table.remove(storyWords, 1)
				end
			end
			table.insert(lineChunks, newLine)
		end
		
		playdate.file.mkdir("./storiesFormatted/")
		local formattedFile = playdate.file.open("./storiesFormatted/"..rawFileName, playdate.file.kFileWrite)
		
		while #lineChunks > 0 do
			local formattedLine = table.remove(lineChunks, 1)
			formattedFile:write(formattedLine.."\n")
		end

		formattedFile:close()
	end

end

-- chunkStories()