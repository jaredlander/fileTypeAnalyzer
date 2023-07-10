context("Test plotAvgLinesPerFile function")

# Load the necessary packages
library(testthat)
library(vdiffr)
library(fileTypeAnalyzer)

# Setup: Create a temporary directory and some files
temp_dir <- tempfile()
dir.create(temp_dir)

# create text files with different number of lines
writeLines(rep("Line of text", 5), file.path(temp_dir, "file1.txt"))
writeLines(rep("Line of text", 10), file.path(temp_dir, "file2.txt"))
writeLines(rep("Line of text", 15), file.path(temp_dir, "file3.csv"))
writeLines(rep("Line of text", 20), file.path(temp_dir, "file4.R"))

# Register a teardown function to remove the temporary directory and files
teardown_env <- new.env(parent = emptyenv())
setup({
    assign("temp_dir", temp_dir, envir = teardown_env)
})
teardown({
    unlink(get("temp_dir", envir = teardown_env), recursive = TRUE)
})

# Test if function correctly produces a plot
test_that("plotAvgLinesPerFile correctly produces a plot", {
    # Assume we have a test directory "test_dir" with the files
    # "file1.txt" (10 lines), "file2.txt" (20 lines), "file3.csv" (15 lines)
    # and "file4.R" (25 lines)

    expect_silent(
        plotAvgLinesPerFile(temp_dir, fileTypes = c("txt", "csv", "R"), plotLibrary = "ggplot")
    )

    expect_silent(
        plotAvgLinesPerFile(temp_dir, fileTypes = c("txt", "csv", "R"), plotLibrary = "echarts4r")
    )

    expect_silent(
        plotAvgLinesPerFile(temp_dir, fileTypes = c("txt", "csv", "R"), plotLibrary = "base")
    )

    expect_silent(
        plotAvgLinesPerFile(temp_dir, fileTypes = c("txt", "csv", "R"), plotLibrary = "lattice")
    )
})


test_that("plotAvgLinesPerFile creates the correct plot", {
    # temp_dir <- tempdir()
    # # Create a data frame of average line counts by file type
    # avg_lines <- data.frame(
    #     File_Type = c("txt", "csv", "R"),
    #     Avg_Lines = c(10, 20, 30)
    # )

    # Test ggplot version
    plot <- plotAvgLinesPerFile(temp_dir, "ggplot")
    expect_doppelganger("Correct ggplot", plot)

    # Test base version
    plot <- plotAvgLinesPerFile(temp_dir, "base")
    expect_doppelganger("Correct base plot", plot)

    # Test lattice version
    plot <- plotAvgLinesPerFile(temp_dir, "lattice")
    expect_doppelganger("Correct lattice plot", plot)

    # Test echarts version
    plot <- plotAvgLinesPerFile(temp_dir, "echarts")
    expect_doppelganger("Correct echarts plot", plot)
})
