CxConfig = {
    --
    -- This class is responsible for loading and saving configuration to memory
    -- Writes to files, where then argument=value\n 
    --
}

function CxConfig.readConfig(filename)
    -- 
    -- This function will read into the table all parameters and their values
    -- ​​from the file with the name given in the parameter and then return
    -- the table. If file not exist or is empty, then return nil value
    --

    -- File open check --
    if not file.open(filename, "r") then
        return nil
    end

    -- Create table for config --
    local config = {}
    local line = ""

    -- Parse lineal --
    repeat
        line = file.readline() or ""
        
        local position = line:find("=")
        if position ~= nil then
            config[line:sub(0, position - 1)] = line:sub(position + 1, line:len() - 1)
        end
    until line == ""

    file.close()

    -- If config file is empty --
    if type(next(config)) == "nil" then
        return nil
    end

    return config
end

function CxConfig.writeConfig(filename, config)
    --
    -- This function saves the table to a file with the name given in the 
    -- parameter. If the table is empty then it will not create the file, 
    -- or it will delete the file if one already exists. If the table is 
    -- empty or there was an error opening the file, it returns nil, if the
    -- save was successful it returns true
    --

    -- File open check --
    if not file.open(filename, "w") then
        return nil
    end

    config = config or {}

    -- Check table is not empty
    if type(next(config)) == "nil" then
        file.close()
        file.remove(filename)
        
        return nil
    end

    -- Write all new values
    for property, value in pairs(config) do
        file.write(property .. "=" .. value .. "\n")
    end

    -- Close file --
    file.close()

    return true
end
