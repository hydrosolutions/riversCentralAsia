test_that("Block is parsed correclty", {
  filepath <- normalizePath(file.path("Tutorial01-results.dst"))
  conn <- base::file(filepath, open = "r")
  test_chunk <- base::readLines(conn, n = 170)
  base::close.connection(conn)

  output <- NULL
  output <- base::rbind(output, parse_block(test_chunk))

  expect_equal("GSM:Qtot", output$Variable[1])
  expect_equal(0.1, output$Value[1])
})
