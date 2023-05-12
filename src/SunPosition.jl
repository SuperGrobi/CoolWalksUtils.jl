is_daylight_saving(day::TimeType) = Date(year(day), 3, 26) < day < Date(year(day), 10, 29)

"""
Functions to calculate the sun position, adapted from
`Roberto Grena (2012), Five new algorithms for the computation of sun position
from 2010 to 2110, Solar Energy, 86(5):1323–1337, doi:10.1016/j.solener.2012.01.024.`

we use only algorithm 1 and omit the inputs of TT-UT, pressure and temperature, since we do not need the precision to launch satellites

# Notes on Arguments
- `longitude` has to be in radians, centered at Greenwitch, positive values going east, negative west.
- `latitude` has to be in radians from -π/2 to π/2, starting from south pole, going north

# Return
Array with 3 entries [x,y,z], representing vector pointing towards sun in local, cartesian coordinate system, centered at longitude, latitude
with x pointing east, y pointing north and z pointing up.

---

    sunposition(date::DateTime, longitude, latitude, timezone::Int=1, daylight_saving::Bool=is_daylight_saving(date))

# Notes on Arguments
- `date` is assumed to be in local time. 
- `timezone` and `daylight_saving` are used to convert to gmt. If the time is allready gmt, set `timezone=0` and `daylight_saving=false`

---

    sunposition(time, day::Int, month::Int, year::Int, longitude, latitude, timezone::Int=1, daylight_saving::Bool=true) 

# Notes on Arguments
- `time` is local time in hours. Convert minutes and seconds... to fractions of hours. (13:30 becomes 13.5) range from 0 to 24.
- `timezone` and `daylight_saving` are used to convert to gmt. If the time is allready gmt, set `timezone=0` and `daylight_saving=false`.
"""
function sunposition end

function sunposition(date::DateTime, longitude, latitude, timezone::Int=1, daylight_saving::Bool=is_daylight_saving(date))
    if !(-π / 2 <= latitude <= π / 2)
        throw(ArgumentError("latitude of $latitude not in range [-π/2, π/2]"))
    end
    u_date = date - Hour(timezone + daylight_saving)
    t_2060 = date_from_2060(u_date)
    return _sunposition(t_2060, longitude, latitude)
end

function sunposition(time, day::Int, month::Int, year::Int, longitude, latitude, timezone::Int=1, daylight_saving::Bool=true)
    if !(-π / 2 <= latitude <= π / 2)
        throw(ArgumentError("latitude of $latitude not in range [-π/2, π/2]"))
    end
    ut = time - (timezone + daylight_saving)
    t_2060 = date_from_2060(ut, day, month, year)
    return _sunposition(t_2060, longitude, latitude)
end

"""

    sunposition_deg(date::DateTime, longitude, latitude, args...)

same as `sunposition(date, ...)`, but takes the `longitude` and `latitude` in degrees.
"""
function sunposition_deg(date::DateTime, longitude, latitude, args...)
    if !(-90 <= latitude <= 90)
        throw(ArgumentError("latitude of $latitude not in range [-90, 90]"))
    end
    lon = deg2rad(longitude)
    lat = deg2rad(latitude)
    return sunposition(date, lon, lat, args...)
end



function _sunposition(t_2060, longitude, latitude)
    right_ascension, declination, hour_angle = algorithm_1(t_2060, longitude)
    elevation, azimuth = get_local_sun_pos(latitude, declination, hour_angle)
    # convert sun position from spherical coordinates to cartesian coordinates
    x = -sin(azimuth) * cos(elevation)
    y = -cos(azimuth) * cos(elevation)
    z = sin(elevation)
    return [x, y, z]
end

const dt2060 = DateTime(2060)

function date_from_2060(date::DateTime)
    t = (date - dt2060).value / 86400000.0
    return t
end

function date_from_2060(ut, day::Int, month::Int, year::Int)
    if month <= 2
        m̃ = month + 12
        ỹ = year - 1
    else
        m̃ = month
        ỹ = year
    end
    t = trunc(365.25 * (ỹ - 2000)) + trunc(30.6001 * (m̃ + 1)) - trunc(0.01ỹ) + day + ut / 24 - 21958
    # universal time
    return t
end

"""
    algorithm_1(t_2060, longitude)

algorithm 1 to calculate the sun position as described by
`Roberto Grena (2012), Five new algorithms for the computation of sun position
from 2010 to 2110, Solar Energy, 86(5):1323–1337, doi:10.1016/j.solener.2012.01.024.`
Simplified to not use TT-UT, pressure and temperature.
"""
function algorithm_1(t_2060, longitude)
    # assuming t = t_e for all our usecases
    ω_t = 0.017202786 * t_2060
    s1 = sin(ω_t)
    c1 = cos(ω_t)
    s2 = 2 * s1 * c1
    c2 = (c1 + s1) * (c1 - s1)

    right_ascension = -1.38880 + 1.72027920e-2 * t_2060 +
                      3.199e-2 * s1 - 2.65e-3 * c1 +
                      4.050e-2 * s2 + 1.525e-2 * c2
    right_ascension = mod(right_ascension, 2π)
    declination = 6.57e-3 + 7.347e-2 * s1 - 3.9919e-1 * c1 +
                  7.3e-4 * s2 - 6.60e-3 * c2
    hour_angle = 1.75283 + 6.3003881 * t_2060 + longitude - right_ascension
    hour_angle = mod(hour_angle + π, 2π) - π
    return right_ascension, declination, hour_angle
end

"""
    get_local_sun_pos(latitude, declination, hour_angle)

transform the location of the sun in the sky from global coordinates into spherical coordinates local to
latitude and longitude used to calculate the inputs.

# Returns
(elevation, azimuth)
The elevation is the heigth of the sun above the horizon, in radians.
The azimuth is the horizontal position of the sun in a polar coordinate system,
where azimuth=0 points to the south pole. negative angles point to the east, positive to the west.
again, in radians.
"""
function get_local_sun_pos(latitude, declination, hour_angle)
    sp = sin(latitude)
    cp = sqrt(1 - sp^2)
    sd = sin(declination)
    cd = sqrt(1 - sd^2)
    sH = sin(hour_angle)
    cH = cos(hour_angle)
    se0 = sp * sd + cp * cd * cH
    elevation = asin(se0) - 4.26e-5 * sqrt(1 - se0^2)
    azimuth = atan(sH, cH * sp - sd * cp / cd)
    return elevation, azimuth
end
