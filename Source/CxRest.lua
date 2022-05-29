CxRequest = {
    method_string = "",
    path_string = "",
    params_string = "",
    header_string = "",
    body_string = "",
}

function CxRequest:addData(data)
    --
    -- This function add receive data to request and 
    -- parse this data to response fields in object 
    --
        
    -- If method is blank, then request is clear --
    -- and function must parse first line --
    if self.method_string == "" then
        
        -- Searching new line --
        local new_line = data:find("\r\n")

        if new_line == nil then
            return 
        end

        -- Parse start line --
        self:parseStartLine(data:sub(0, new_line - 1))

        -- Remove start line from request --
        data = data:sub(new_line + 2)
    end

    -- Adding data to header --
    self.header_string = self.header_string .. data
     
    -- If header is complete then add new values to body --
    local body = self.header_string:find("\r\n\r\n")

    if body ~= nil then
        self.body_string = self.body_string .. self.header_string:sub(body + 4)
        self.header_string = self.header_string:sub(0, body + 3)
    end
end

function CxRequest:headerParam(param_name)
    --
    -- This function return value of header param if
    -- it exist and nil if it not exist
    --

    -- Searching param --
    local param = self.header_string:find(param_name, 0, true)

    -- Param no exist --
    if param == nil then 
        return nil
    end

    -- Skipping ": " --
    param = param + param_name:len() + 2

    -- Searching end of param --
    local param_end = self.header_string:find("\r\n", param)

    if param_end == nil then
        return nil
    end

    -- Cutting values from header --
    return self.header_string:sub(param, param_end - 1)
end

function CxRequest:body()
    -- 
    -- This function return request body in plain/text
    -- form 
    --

    return self.body_string
end

function CxRequest:path()
    --
    -- This function return path of request
    --

    return self.path_string
end
    
function CxRequest:method()
    -- 
    -- This function return method of request
    --

    return self.method_string
end

function CxRequest:getParam(param_name)
    --
    -- This function return param send by GET method
    -- read from request URL
    --

    -- Complete param string --
    param_name = param_name .. "="
    
    -- Copy header and search param there --
    local params = self.params_string
    local param = params:find(param_name)

    -- Param not exist --
    if param == nil then 
        return nil
    end

    -- Cut all betwen param and param --
    params = params:sub(param + param_name:len()) .. ","

    -- Return all from start to "," --
    return params:sub(0, params:find(",") - 1)
end

function CxRequest:isComplete()
    -- 
    -- This function check if response is complete and can
    -- be move to service 
    --

    -- If header is not complete, then request is not complete --
    if self.header_string:find("\r\n\r\n") == nil then
        return false
    end

    -- If body is shorten than Content-Length --
    local content_length = self:headerParam("Content-Length")
    
    if 
        content_length ~= nil and
        tonumber(content_length) > self.body_string:len() 
    then
        return false
    end
    
    return true
end

function CxRequest:parseStartLine(line)
    --
    -- This function parse start line of header, with and save
    -- values from it to header object. This read path, method
    -- and params from them
    --

    -- Searching spaces betwen elements --    
    local first_space = line:find(" ")
    local second_space = line:find(" ", first_space + 1)

    -- Extracting items --
    self.method_string = line:sub(0, first_space - 1)
    self.path_string = line:sub(first_space + 1, second_space - 1)

    -- Searching params section in path --
    local params = self.path_string:find("?")

    -- If params section exist, extract it --
    if params ~= nil then
        self.params_string = self.path_string:sub(params + 1)
        self.path_string = self.path_string:sub(0, params - 1)
    end
end

function CxRequest:new()
    --
    -- This function return new instance of
    -- CxRequestHeader class, instance is blank
    --
        
    local new_object = {}

    setmetatable(new_object, self)
    self.__index = self
    
    return new_object
end


CxResponse = {
	status_code = "",
	header_params = {},
	body_string = "",
	
	STATUS = {
        CODE_200 = "200 OK",
        CODE_400 = "400 Bad Request",
        CODE_404 = "404 Not Found",
        CODE_500 = "500 Internal Server Error",
    },
}
	
function CxResponse:complete()
    --
    -- This function return response in string form to
    -- send by bufer
    --
    
    -- Adding length of response body --
    self:headerParam("Content-Length", self.body_string:len())
    
    -- Parsing and return --
    return
        self:createStartLine() ..
        self:createHeader() .. 
        self.body_string
end
	
function CxResponse:headerParam(param, value)
    --
    -- This function add param with value to
    -- header of response
    --
    
    if param == nil then
        return 
    end
    
    self.header_params[param] = value
end
		
function CxResponse:createStartLine()
    --
    -- This function return start line of response 
    -- in string form
    --
        
    return "HTTP/1.0 " .. self.status_code .. "\r\n"
end
	
function CxResponse:createHeader()
    -- 
    -- This function return header of response
    -- in string form
    --
        
    local header = ""
        
    for param, value in pairs(self.header_params) do
        header = header .. param .. ": " .. value .. "\r\n"	
    end
        
    return header .. "\r\n"
end
		
function CxResponse:status(status)
    --
    -- This function set up response status from code
    --
    
    self.status_code = status or self.STATUS.CODE_200
end
	
function CxResponse:addContent(new_content)
    --
    -- This function add new content to response body
    --
    
    self.body_string = self.body_string .. (new_content or "")
end
	
function CxResponse:body()
    --
    -- This function return response body
    --
    
    return self.body_string
end
	
function CxResponse:cleanBody()
    --
    -- This function clean response body or set
    -- content from param if exist
    --
    
    self.body_string = content or ""
end
	
function CxResponse:new()
    --
    -- This function return new instance of
    -- CxRequestHeader class, instance is blank
    --
    
    local new_object = {}

    setmetatable(new_object, self)
    self.__index = self

    return new_object
end

CxSendBufer = {
    data = "",
}

function CxSendBufer:empty()
    --
    -- Return bool CxSendBufer state, true if
    -- empty and false if not empty
    --

    if self.data == "" then
        return true
    end

    return false
end

function CxSendBufer:setup(data)
    --
    -- This function write new data to 
    -- bufer 
    --

    self.data = data
end

function CxSendBufer:getFrame()
    --
    -- This function gen frame from bufer and
    -- remove data from it
    --

    local frame = self.data:sub(0, 1400)
    self.data = self.data:sub(1401)

    return frame
end

function CxSendBufer:new()
    --
    -- This function return new instance of
    -- CxRequestHeader class, instance is blank
    --
    
    local new_object = {}

    setmetatable(new_object, self)
    self.__index = self

    return new_object
end


CxRest = {
    server = nil,
    send_bufer = {},
    receive_bufer = {},
    endpoints = {},
}

function CxRest:new()
 --
    -- This function return new instance of
    -- CxRequestHeader class, instance is blank
    --
    
    local new_object = {}

    setmetatable(new_object, self)
    self.__index = self

    return new_object
end

function CxRest:close()
    --
    -- This function stopper server if work
    --
    
    if self.server ~= nil then
        self.server:close()
    end
    
    self.server = nil
end

function CxRest:endpoint(method, path, action)
    --
    -- This function adding new endpoint to server
    -- if action is function or return action of
    -- latest set endpoint if action is nil
    --
    
    if action ~= nil then
        self.endpoints[method .. path] = action
    else
        return self.endpoints[method .. path]
    end
end

function CxRest:open(port)
    --
    -- This function open server to listen
    -- port given in param 
    --

    -- If server is open, first close it --
    if self.server ~= nil then
        self:close()
    end

    -- Create server to listen on port --
    self.server = net.createServer(net.TCP)
    self.server:listen(port, function (connection)
    
        connection:on("receive", function (socket, data)
            --
            -- This function is responsible for receiving 
            -- from user, write it to bufer. When it is
            -- complete, then running action of these 
            -- endpoint and set up response for sent 
            -- function. 
            --
            
            local peer = socket:getpeer()

            -- If client sent first frame, create bufer --
            if self.receive_bufer[peer] == nil then
                self.receive_bufer[peer] = CxRequest:new()
            end

            -- Add new data to bufer --
            self.receive_bufer[peer]:addData(data)

            -- If is not complete, return and wait for more data --
            if not self.receive_bufer[peer]:isComplete() then
                return 
            end

            -- Create response, and write default values --
            local response = CxResponse:new()

            response:status()
            response:headerParam("Server", "CxRest (Lua, ESP8266")
            response:cleanBody()

            -- Get endpoint action and if exist run it --
            local action = self:endpoint(self.receive_bufer[peer]:method(), self.receive_bufer[peer]:path())

            if action == nil then
                response:status(response.STATUS.CODE_404)
                response:addContent("That endpoint not exist!")
            else
                action(self.receive_bufer[peer], response)
            end

            -- Create send bufer --
            self.send_bufer[peer] = CxSendBufer:new()
            self.send_bufer[peer]:setup(response:complete())

            -- Remove garbage --
            self.receive_bufer[peer] = nil

            -- Send first frame --
            socket:send(self.send_bufer[peer]:getFrame())
        end)

        connection:on("sent", function (socket, data)
            --
            -- This function sending more data if it exist
            -- and close connection if data to send not exist
            --
            
            local peer = socket:getpeer()

            -- If bufer not exist return --
            if self.send_bufer[peer] == nil then
                return 
            end

            -- If bufer is empty close connection and remove garbage --
            if self.send_bufer[peer]:empty() then
                socket:close()
                self.send_bufer[peer] = nil
                
                return
            end

            -- Send next frame of data --
            socket:send(self.send_bufer[peer]:getFrame())
        end)
        
    end)
end
