#!/usr/bin/ruby

module AutoSetUtility
    def string_endswith(str, suffix)
        if str == nil or suffix == nil or str.length < suffix.length
            return false
        end
        foundIndex = str.rindex(suffix, str.length - suffix.length)
        return foundIndex != nil
    end
end