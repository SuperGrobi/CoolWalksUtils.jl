"""
Type holding all the data related to the center of a dataset like a street network, buildings, trees or their shadows.

- `name::String`: name of city/experiment
- `lon::Float64`: East-ward longitude of city in degrees
- `lat::Float64`: North-ward latitude of the city in degrees
- `tz::VariableTimeZone`: Time zone of the city (used to calculate sun direction at given local time)

This type is mostly inspired by the `AstroLib.Observatory` type, but we make it work with the `TimeZones` package.
Note the order of the `lon` and `lat` arguments which are renamed and switched compared to the `AstroLib` implementation.
"""
struct ShadowObservatory
    name::String
    lon::Float64
    lat::Float64
    tz::VariableTimeZone
end

"""

    local_sunpos(local_time::DateTime, obs::ShadowObservatory; cartesian::Bool=true)

Calculates the position of the sun in the sky at time `local_time`, at the location specified by `obs`.
Assumes `local_time` is given in the timezone of `obs.tz`.

Uses `AstroLib` for all the heavy lifting.

# Return
if `cartesian==true`:

Array with 3 entries [x,y,z], representing vector pointing towards sun in local, cartesian coordinate system, centered at `obs`
with x pointing east, y pointing north and z pointing up.

otherwise:

Array with 2 entries [altitude, azimuth] in degrees. `azimuth` measured east from north.
"""
function local_sunpos(local_time::DateTime, obs::ShadowObservatory; cartesian::Bool=true)
    utc_time = DateTime(ZonedDateTime(local_time, obs.tz), UTC)
    julian_time = jdcnv(utc_time)
    ra°, dec° = sunpos(julian_time)
    alt°, az° = eq2hor(ra°, dec°, julian_time, obs.lat, obs.lon)
    if !cartesian
        return [alt°, az°]
    else
        alt° = deg2rad(alt°)
        az° = deg2rad(az°)
        x = sin(az°) * cos(alt°)
        y = cos(az°) * cos(alt°)
        z = sin(alt°)
        return [x, y, z]
    end
end
