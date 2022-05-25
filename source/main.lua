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
end

local books = {}
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
				storyContent = storyValue.storyContent
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
				storyContent = storyValue.storyContent
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

-- 
function drawPage(storyContent, pageIndex) 
	-- break into individual lines here based on size or |n or whatever. Then we draw as lines below?
	-- print(playdate.graphics.getTextSize(storyContent))
	
	-- looks like each newline adds 20 to playdate.graphics.getTextSize(storyContent) 
	
	-- function like TurnStringIntoStrings
	-- Need to get just enough lines consisting of whole words to 
	-- left to right, append whole words into newLine until getText close enough to size
	-- unless \n then immedietely start newLine
	
	-- grab 12 lines using pageIndex
	
	local testText = "howdy partner, I love you howdy partner, I love you  howdy partner, I"
	print(testText)
	print(playdate.graphics.getTextSize(testText))
	
	
	playdate.graphics.drawTextInRect(storyContent, 0, 0, 400, 240, nil)
end

createBooks(stories)

-- chunk stories.storyContent into stories.storyLines
function chunkStoryContent(books) 
	for bookKey, bookValue in pairs(books) do
		local storyLines = {}
		-- we have a very long string called bookValue.storyContent with /n in it. 
		
	end
end


printTable(books)

local previousCursor = 1
local cursor = 2
local shelfView = true
local pageIndex = 0
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
		-- todo: get a page of text based on updown index
		drawPage(books[cursor].storyContent, pageIndex)
	end
end

function playdate.leftButtonDown()
	if cursor > 1 then
		previousCursor = cursor ; 
		cursor -= 1;
		playdate.graphics.setColor(playdate.graphics.kColorWhite) 
		gfx.fillRect(30, 20, 330 , 60)
	end
end
function playdate.rightButtonDown()	
	if cursor < #books then
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
end
