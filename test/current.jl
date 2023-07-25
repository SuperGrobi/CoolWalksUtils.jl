using CoolWalksUtils

using TimeZones
using AstroLib
using Dates

@edit Observatory("denmark", 55, 12, 0, 1)
tz = tz"Europe/Berlin"
days = Date(2023, 1, 1):Day(1):Date(2023, 12, 30)

tzdays = ZonedDateTime.(days, tz)

obs = CoolWalksUtils.ShadowObservatory("denmark", 12, 55, tz"Europe/Berlin")
time = DateTime(2023, 8, 25, 13, 00)
CoolWalksUtils.local_sunpos(time, obs)

times = DateTime(2023, 7, 25, 5):Minute(1):DateTime(2023, 7, 25, 20)

base_pos = sunposition_deg.(times, 12, 55)

new_pos = CoolWalksUtils.local_sunpos.(times, Ref(obs))

plot(times, getindex.(base_pos, 2))
plot(times, getindex.(base_pos, 2) .- getindex.(new_pos, 2) .+ 180)
plot(times, getindex.(base_pos, 1) .- getindex.(new_pos, 1))

t1 = DateTime(2023, 7, 25, 8, 16)
t2 = DateTime(2023, 7, 25, 13, 18)
t3 = DateTime(2023, 7, 25, 18, 22)
CoolWalksUtils.local_sunpos(t3, obs; cartesian=true) * -1