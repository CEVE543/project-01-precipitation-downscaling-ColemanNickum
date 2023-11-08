using CDSAPI
using NCDatasets
using StatsBase: shuffle

# Find the "root" directory of your project
HOMEDIR = abspath(dirname(@__FILE__))

function download_2m_temperature_data(start_year, end_year, output_dir)
    for year in start_year:end_year
        filename = joinpath(output_dir, "2m_temperature_$year.nc")
        variable = "2m_temperature"
        download_single_level_data(year, filename, variable)
    end
end

function run_demo()
    # Define the years for which you want to download data
    start_year = 2006
    end_year = 2022

    # Define the output directory where the data will be saved
    output_dir = joinpath(HOMEDIR, "data", "raw")

    # Download 2m temperature data for the specified years
    download_2m_temperature_data(start_year, end_year, output_dir)
end

run_demo()
