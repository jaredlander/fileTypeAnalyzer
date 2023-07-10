context("Test fileTypeCounts function")

# Load the necessary packages
library(testthat)
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

# Test if function correctly counts file types
test_that("fileTypeCounts correctly counts file types", {
    # Assume we have a test directory "test_dir" with the files
    # "file1.txt", "file2.txt", "file3.csv" and "file4.R"

    expect_equal(
        fileTypeCounts(temp_dir, fileTypes = c("txt", "csv", "R")),
        tibble::tibble(File_Type = c("txt", "R", "csv"),
                   Count = c(2, 1, 1))
    )
})
