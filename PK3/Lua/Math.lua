function maps.linearCycle(time, low, high, speed)
	local base = abs(time % speed - speed / 2) * 2 * FU / speed
	return low + FixedMul(base, high - low)
end

function maps.sinCycle(time, low, high, speed)
	local base = sin(time % speed * FU / speed * FU)
	return low + FixedMul(base + FU, (high - low) / 2)
end

function maps.linearFade(srcvalue, srclow, srchigh, dstlow, dsthigh)
	if srcvalue <= srclow then
		return dstlow
	elseif srcvalue >= srchigh then
		return dsthigh
	else
		local ratio = FixedDiv(srcvalue - srclow, srchigh - srclow)
		return dstlow + FixedMul(dsthigh - dstlow, ratio)
	end
end

function maps.sinFade(srcvalue, srclow, srchigh, dstlow, dsthigh)
	if srcvalue < dstlow then
		return srclow
	elseif srcvalue > dsthigh then
		return srchigh
	else
		local base = sin(ANGLE_270 + (srcvalue - dstlow) * FU / 2 / (dsthigh - dstlow) * FU)
		return srclow + FixedMul(base + FU, (srchigh - srclow) / 2)
	end
end
