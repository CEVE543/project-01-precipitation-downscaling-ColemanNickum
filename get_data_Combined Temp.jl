using CDSAPI
using NCDatasets
using StatsBase: shuffle
using DataFrames

# Find the "root" directory of your project
HOMEDIR = abspath(dirname(@__FILE__))

function open_mfdataset(files::Vector{String}, variable_name::AbstractString)
    # Lists to store variable data, time data, and other coordinate data
    var_data_list = []
    time_data_list = []
    coords_data_dict = Dict()

    # Open the first file to get the coordinate names (excluding time and the main variable)
    ds = Dataset(files[1])
    dimnames = keys(ds.dim)
    coord_names = setdiff(collect(dimnames), [variable_name, "time"])
    close(ds)

    # Initialize lists for each coordinate in coords_data_dict
    for coord in coord_names
        coords_data_dict[coord] = []
    end

    # Open each file, extract data, and store in lists
    for file in files
        ds = Dataset(file)

        # Store variable and time data
        push!(var_data_list, ds[variable_name][:])
        push!(time_data_list, ds["time"][:])

        # Store other coordinate data
        for coord in coord_names
            push!(coords_data_dict[coord], ds[coord][:])
        end

        close(ds)
    end

    # Pair variable data with time data and sort by time
    sorted_pairs = sort(collect(zip(time_data_list, var_data_list)); by=x -> x[1])
    sorted_time_data = [pair[1] for pair in sorted_pairs]
    sorted_var_data = [pair[2] for pair in sorted_pairs]

    # Concatenate sorted data
    concatenated_data_dict = Dict(
        variable_name => vcat(sorted_var_data...), "time" => vcat(sorted_time_data...)
    )

    # Concatenate coordinate data and add to the dictionary
    for coord in coord_names
        concatenated_data_dict[coord] = vcat(coords_data_dict[coord]...)
    end

    return concatenated_data_dict
end


data_dict = open_mfdataset(["data/raw/2m_temperature_2000.nc", "data/raw/2m_temperature_2001.nc", "data/raw/2m_temperature_2002.nc"], "t2m")

fnames = shuffle(glob("2m_temperature", data_dir)) # shuffle -- should work even if out of order
t2m = open_mfdataset(fnames, "t2m") # we sort based on time, so we don't need to sort here