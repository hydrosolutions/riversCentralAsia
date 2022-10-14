# Generate a small-size test nc file
# using cdo on a linux terminal (ubuntu)
# Get information about data stored in the nc file
# $ cdo sinfon <infile>.nc
# We cannot reduce the number of time steps in the infile because the function
# can only read files with one entire year of data. As all our input files are
# structured in that way, this is ok.
## NOT DONE ## Select the first 12 time steps from the infile and store them to
## outfile
## $ cdo -seltimestep,1/12 <infile>.nc <outfile>.nc
## END NOT DONE ##
# Get lat & lon of our test shapefile
# sf::st_read("tests/testthat/test_gen_HRU_Climate_CSV_RSMinerve_input_basin.shp",
#             quiet = TRUE) |>
#   sf::st_transform(crs = 4326) |>
#   sf::st_bbox()
# Crop nc file to box
# $ cdo -sellonlatbox,70.02,70.19,41.71,41.86 <infile>.nc <outfile>.nc
# This reduces the test file size from roughly 6 GB to roughly 800 KB.

test_that("gen HRU Climate CSV RSMinerve works as it should", {

  test_shp <- sf::st_read(
    "test_gen_HRU_Climate_CSV_RSMinerve_input_basin.shp",
    quiet = TRUE) |>
    dplyr::mutate(name = "test",
                  Z = 500)

  test_string <- gen_HRU_Climate_CSV_RSMinerve(
    climate_files =
      "test_gen_HRU_Climate_CSV_RSMinerve_input_file.nc",
    catchmentName = "test",
    temp_or_precip = "Temperature",
    elBands_shp = test_shp,
    startY = 1979,
    endY = 1979,
    obs_frequency = "day",
    climate_data_type = "hist_obs",
    crs_in_use = "+proj=longlat +datum=WGS84",
    output_file_dir=0,
    gcm_model=0,
    gcm_scenario=0,
    tz = "UTC")


  expect_equal(dim(test_string)[1], 373)
  expect_equal(dim(test_string)[2], 2)

  expect_equal(test_string$Station[9], "01.01.1979 00:00:00")
  expect_equal(test_string$Station[373], "31.12.1979 00:00:00")

  expect_equal(round(as.numeric(test_string$test[9]), digits = 4), -6.7011)
  expect_equal(round(as.numeric(test_string$test[373]), digits = 4), -11.8853)

})


