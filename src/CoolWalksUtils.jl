module CoolWalksUtils

    using ArchGDAL

    """
    Reference which holds the WSG84 (EPSG4326) ArchGDAL Spatial Reference System
    with lon-lat order.
    """
    const OSM_ref = Ref{ArchGDAL.ISpatialRef}()

    function __init__()
        OSM_ref[] = ArchGDAL.importEPSG(4326; order=:trad)
        nothing
    end

    export OSM_ref

    
end