import 'CoreLibs/object'
import 'CoreLibs/graphics'

local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()
local shelfDimensions = {
	x = 5,
	y = 195,
	w = 390,
	h = 30,
	lineWidth = 3
}

local books = {}

-- 	create stories out of directory
local stories = {}
local storyFiles = playdate.file.listFiles("stories/")
for storyFileKey, storyFileValue in pairs(storyFiles) do
	local fileLocation = "stories/" .. storyFileValue
	local file = playdate.file.open(fileLocation, playdate.file.kFileRead)
	local fileHeader = file:readline()
	file:close()
	local file2 = playdate.file.open(fileLocation, playdate.file.kFileRead)
	local storyContent = file2:read(999999999999999)
	table.insert(stories, { 
			storyContent = storyContent,
			fileHeader = fileHeader 
		})
	file2:close()
end

function chunkStory(storyContent)
	local storyWords = {}
	-- finds carriage returns and complete words with punctuation
	for w in storyContent:gmatch("%\n*%S+") do
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
			while (#storyWords > 1 and playdate.graphics.getTextSize(newLine .. storyWords[1]) < 400)  do
				newLine = newLine .. storyWords[1] .. " "
				table.remove(storyWords, 1)
			end
		end
		table.insert(lineChunks, newLine)
	end
	return lineChunks
end

function createBooks(stories)
	for storyKey, storyValue in pairs(stories) do
		local newBook = {}
		local bookHeight = math.random(100, 130)
		local bookWidth = math.random(30, 50)

		if #books == 0 then
			newBook = {
				x = 5,
				y = 195 - bookHeight,
				w = bookWidth,
				h = bookHeight,
				lineWidth = 4,
				title = storyValue.fileHeader,
				storyContent = storyValue.storyContent,
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
				storyContent = storyValue.storyContent,
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
		renderedPage = renderedPage .. storyChunk[iterator]
		iterator = iterator + 1
	end
	playdate.graphics.drawTextInRect(renderedPage, 0, 0, 400, 240, nil)
end

-- chunk stories.storyContent into stories.storyLines
function chunkBooks(books)
	for bookKey, bookValue in pairs(books) do
		bookValue.storyChunk =  chunkStory(bookValue.storyContent)
	end
end

createBooks(stories)
chunkBooks(books)

local previousCursor = 1
local cursor = 2
local shelfView = true
local globalLineIndex = 1
function playdate.update()
	if shelfView then
		playdate.graphics.clear()

		-- color in selected book
		local book = books[cursor]
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		gfx.fillRect(book.x + 2, book.y - .5, book.w - 2, book.h - 1)

		local title = gfx.drawText(book.title, 50, 30)

		-- draw shelf
		gfx.drawRect(shelfDimensions.x, shelfDimensions.y, shelfDimensions.w, shelfDimensions.h, shelfDimensions.lineWidth)

		drawBooks(shelfDimensions, stories)

		-- uncolor in last selected book
		local lastBook = books[previousCursor]
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		gfx.fillRect(lastBook.x + 2, lastBook.y - .5, lastBook.w - 2 , lastBook.h - 1)

	else -- draw book view
		playdate.graphics.clear()
		drawPage(books[cursor].storyChunk, globalLineIndex)
	end
end

-- buttons for page view
function playdate.downButtonDown()
	if not shelfView then
		globalLineIndex += 1
	end
end

function playdate.upButtonDown()
	if not shelfView then
		globalLineIndex -= 1
	end
end

-- buttons for shelf view
function playdate.leftButtonDown()
	if cursor > 1 and shelfView then
		previousCursor = cursor ;
		cursor -= 1;
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		gfx.fillRect(30, 20, 330 , 60)
	end
end
function playdate.rightButtonDown()
	if cursor < #books and shelfView then
		previousCursor = cursor ;
		cursor += 1;
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		gfx.fillRect(30, 20, 330 , 60)
	end
end
function playdate.AButtonDown()
	shelfView = false
end

function playdate.BButtonDown()
	shelfView = true
	globalLineIndex = 1
end
