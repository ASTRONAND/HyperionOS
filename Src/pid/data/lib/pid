--:Minify:--

local pid = {}
pid.__index = pid

local function clamp(value, minimum, maximum)
    if minimum and value < minimum then
        return minimum
    end
    if maximum and value > maximum then
        return maximum
    end
    return value
end

local function assertNumber(value, name)
    if type(value) ~= "number" then
        error("pid: " .. name .. " must be a number")
    end
    return value
end

function pid.new(kp, ki, kd, options)
    assertNumber(kp, "kp")
    assertNumber(ki, "ki")
    assertNumber(kd, "kd")

    options = options or {}

    local controller = setmetatable({
        kp = kp,
        ki = ki,
        kd = kd,
        setpoint = options.setpoint or 0,
        outputMin = options.outputMin,
        outputMax = options.outputMax,
        integralMin = options.integralMin,
        integralMax = options.integralMax,
        lastError = 0,
        integral = 0,
        lastMeasurement = nil,
        lastOutput = 0,
        lastTime = nil,
    }, pid)

    return controller
end

function pid:reset()
    self.lastError = 0
    self.integral = 0
    self.lastMeasurement = nil
    self.lastOutput = 0
    self.lastTime = nil
end

function pid:setSetpoint(setpoint)
    assertNumber(setpoint, "setpoint")
    self.setpoint = setpoint
end

function pid:setCoefficients(kp, ki, kd)
    assertNumber(kp, "kp")
    assertNumber(ki, "ki")
    assertNumber(kd, "kd")
    self.kp = kp
    self.ki = ki
    self.kd = kd
end

function pid:setOutputLimits(minimum, maximum)
    if minimum ~= nil then assertNumber(minimum, "outputMin") end
    if maximum ~= nil then assertNumber(maximum, "outputMax") end
    if minimum and maximum and minimum > maximum then
        error("pid: outputMin must be <= outputMax")
    end
    self.outputMin = minimum
    self.outputMax = maximum
end

function pid:setIntegralLimits(minimum, maximum)
    if minimum ~= nil then assertNumber(minimum, "integralMin") end
    if maximum ~= nil then assertNumber(maximum, "integralMax") end
    if minimum and maximum and minimum > maximum then
        error("pid: integralMin must be <= integralMax")
    end
    self.integralMin = minimum
    self.integralMax = maximum
end

function pid:update(measurement, dt)
    assertNumber(measurement, "measurement")
    assertNumber(dt, "dt")
    if dt <= 0 then
        error("pid: dt must be greater than zero")
    end

    local errorValue = self.setpoint - measurement
    self.integral = clamp(self.integral + errorValue * dt, self.integralMin, self.integralMax)
    local derivative = 0
    if self.lastTime ~= nil then
        derivative = (errorValue - self.lastError) / dt
    end

    local output = self.kp * errorValue + self.ki * self.integral + self.kd * derivative
    output = clamp(output, self.outputMin, self.outputMax)

    self.lastError = errorValue
    self.lastMeasurement = measurement
    self.lastOutput = output
    self.lastTime = (self.lastTime or 0) + dt

    return output
end

function pid:compute(measurement, dt)
    return self:update(measurement, dt)
end

function pid:getState()
    return {
        setpoint = self.setpoint,
        kp = self.kp,
        ki = self.ki,
        kd = self.kd,
        integral = self.integral,
        lastError = self.lastError,
        lastOutput = self.lastOutput,
    }
end

function pid:resetIntegral()
    self.integral = 0
end

return pid
