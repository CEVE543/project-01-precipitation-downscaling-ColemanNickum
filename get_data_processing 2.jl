using CDSAPI
using NCDatasets
using StatsBase: shuffle

# find the "root" directory of your project
HOMEDIR = abspath(dirname(@__FILE__))


function download_and_open_data(
  year::Int,
  filename::AbstractString,
  variable::AbstractString,
  resolution=1.0,
  bbox=[50, -130, 24, -65],
)
  # Download pressure level data
  download_pressure_level_data(
    year,
    joinpath(filename, "geopotential_500hPa_2020.nc"),
    "geopotential",
    500
  )

  # Download single level data
  download_single_level_data(
    year,
    joinpath(filename, "temperature_2020.nc"),
    "2m_temperature"
  )

  # Get all files in the data directory
  fnames = glob("*.nc", joinpath(filename))

  # Open and concatenate the files
  data_dict = open_mfdataset(fnames, variable_name)

  return data_dict
end

function glob(pattern::AbstractString, dir::AbstractString=".")
  # Convert the glob-like pattern to a regex pattern
  regex_pattern = replace(pattern, "*" => ".*")
  regex_pattern = Regex(regex_pattern)

  # List all files in the directory and filter by the regex pattern
  matching_files = filter(
    filename -> occursin(regex_pattern, filename), readdir(dir; join=true)
  )

  return matching_files
end

function run_demo()

  # The path to the raw data folder
  data_dir = joinpath(HOMEDIR, "data")

  years = 2019:2020 # example time range

  for year in years

    # Download and open all data for the year
    data_dict = download_and_open_data(year, joinpath(data_dir, "data_$year.nc"), "2m_temperature")

    display(data_dict)

  end

  return nothing
end

run_demo()