local pandocList = require 'pandoc.List'

Div = function (div)
  local options = div.attributes['data-latex']
  if options == nil then return nil end

  -- if the output format is not latex, the object is left unchanged
  if FORMAT ~= 'latex' and FORMAT ~= 'beamer' then
    div.attributes['data-latex'] = nil
    return div
  end

  local env = div.classes[1]
  -- if the div has no class, the object is left unchanged
  if not env then return nil end

  local returnedList

  -- build the returned list of blocks
  if env == 'column' then
    local beginEnv = pandocList:new{pandoc.RawBlock('tex', '\\begin' .. '{' .. 'minipage' .. '}' .. options)}
    local endEnv = pandocList:new{pandoc.RawBlock('tex', '\\end{' .. 'minipage' .. '}')}
    returnedList = beginEnv .. div.content .. endEnv

  elseif env == 'columns' then
    -- merge two consecutives RawBlocks (\end... and \begin...)
    -- to get rid of the extra blank line
    local blocks = div.content
    local rbtxt = ''

    for i = #blocks-1, 1, -1 do
      if i > 1 and blocks[i].tag == 'RawBlock' and blocks[i].text:match 'end'
      and blocks[i+1].tag == 'RawBlock' and blocks[i+1].text:match 'begin' then
        rbtxt = blocks[i].text .. blocks[i+1].text
        blocks:remove(i+1)
        blocks[i].text = rbtxt
      end
    end
    returnedList=blocks
  end
  return returnedList
end
