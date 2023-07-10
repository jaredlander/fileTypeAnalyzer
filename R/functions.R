#' Count File Types in Directory
#'
#' This function counts the number of each file type in a specified directory.
#' The file type is determined by the file extension. If specific file types are
#' provided, the function only counts files of those types.
#'
#' @param dirPath Character string specifying the path to the directory.
#' @param fileTypes Optional character vector specifying which file types to consider.
#'   If NULL (the default), all file types are considered.
#'
#' @return A tibble with one row for each file type and columns for the file type and count.
#'   The counts are sorted in descending order.
#'
#' @examples
#' \dontrun{
#' fileTypeCounts("/path/to/folder", c("txt", "csv"))
#' }
#'
#' @export
fileTypeCounts <- function(dirPath, fileTypes = NULL) {
    # Ensure the directory exists
    if(!fs::dir_exists(dirPath)) {
        stop("Directory not found")
    }

    # If specific file types are provided, modify the regex pattern accordingly
    if (!is.null(fileTypes)) {
        regex_pattern <- paste0(".*\\.(", paste(fileTypes, collapse = "|"), ")$")
    } else {
        regex_pattern <- ".*"  # Matches any file
    }

    # List files in the directory according to the regex pattern
    fileList <- fs::dir_ls(dirPath, regexp = regex_pattern)

    # Get file extensions
    fileExt <- purrr::map_chr(fileList, ~ fs::path_ext(.x))

    # Create a frequency count of file extensions
    fileTypeCounts <- fileExt %>%
        tibble::as_tibble() %>%
        dplyr::group_by(value) %>%
        dplyr::tally(sort = TRUE) %>%
        dplyr::rename(File_Type = value, Count = n)

    return(fileTypeCounts)
}

#' Average Lines Per File by File Type
#'
#' This function calculates the average number of lines for each file type in a specified directory.
#' The number of lines is only calculated for file types that are text-based (e.g., .txt, .csv, .R).
#' For binary file types, the number of lines cannot be computed and the function returns NA.
#'
#' @param dirPath Character string specifying the path to the directory.
#' @param fileTypes Optional character vector specifying which file types to consider.
#'   If NULL (the default), all file types are considered.
#'
#' @return A tibble with one row for each file type and columns for the file type and average number of lines.
#'   File types for which the number of lines cannot be computed have NA in the average number of lines column.
#' @importFrom magrittr `%>%`
#' @examples
#' \dontrun{
#' avgLinesPerFile("/path/to/folder", c("txt", "csv", "R"))
#' }
#'
#' @export
avgLinesPerFile <- function(dirPath, fileTypes = NULL) {
    # Ensure the directory exists
    if(!fs::dir_exists(dirPath)) {
        stop("Directory not found")
    }

    # If specific file types are provided, modify the regex pattern accordingly
    if (!is.null(fileTypes)) {
        regex_pattern <- paste0(".*\\.(", paste(fileTypes, collapse = "|"), ")$")
    } else {
        regex_pattern <- ".*"  # Matches any file
    }

    # List files in the directory according to the regex pattern
    fileList <- fs::dir_ls(dirPath, regexp = regex_pattern)

    # Get file extensions
    fileExt <- purrr::map_chr(fileList, ~ fs::path_ext(.x))

    # Calculate the number of lines for each file (returns NA for binary files)
    numLines <- purrr::map_dbl(fileList, ~ tryCatch(length(readLines(.x)), error = function(e) NA))

    # Combine file extensions and number of lines into a tibble
    fileData <- tibble::tibble(File_Type = fileExt, Num_Lines = numLines)

    # Calculate the average number of lines for each file type
    avgLines <- fileData %>%
        dplyr::group_by(File_Type) %>%
        dplyr::summarise(Avg_Lines = mean(Num_Lines, na.rm = TRUE), .groups = "drop")

    return(avgLines)
}

#' Generate Base R Bar Plot
#'
#' @param data Dataframe containing the average number of lines and file types.
#' @return NULL. The function outputs the plot directly.
genBaseRPlot <- function(data) {
    graphics::barplot(data$Avg_Lines, names.arg = data$File_Type,
            main = "Average Number of Lines per File by File Type",
            xlab = "File Type", ylab = "Average Number of Lines", col = "skyblue")
}

#' Generate Lattice Bar Plot
#'
#' @param data Dataframe containing the average number of lines and file types.
#' @return lattice plot object.
genLatticePlot <- function(data) {
    plot <- lattice::barchart(Avg_Lines ~ File_Type, data = data,
                              main = "Average Number of Lines per File by File Type",
                              xlab = "File Type", ylab = "Average Number of Lines",
                              col = "skyblue")
    return(plot)
}

#' Generate ggplot Bar Plot
#'
#' @param data Dataframe containing the average number of lines and file types.
#' @return ggplot object.
genGgplot <- function(data) {
    plot <- ggplot2::ggplot(data, ggplot2::aes(x = File_Type, y = Avg_Lines)) +
        ggplot2::geom_bar(stat = "identity", fill = "skyblue") +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(x = "File Type", y = "Average Number of Lines",
                      title = "Average Number of Lines per File by File Type")
    return(plot)
}

#' Generate echarts4r Bar Plot
#'
#' @param data Dataframe containing the average number of lines and file types.
#' @return echarts4r plot object.
genEcharts <- function(data) {
    plot <- data %>%
        echarts4r::e_charts(File_Type) %>%
        echarts4r::e_bar(Avg_Lines) %>%
        echarts4r::e_title("Average Number of Lines per File by File Type")
    return(plot)
}

#' Bar Plot of Average Lines Per File by File Type
#'
#' @param dirPath Character string specifying the path to the directory.
#' @param fileTypes Optional character vector specifying which file types to consider.
#'   If NULL (the default), all file types are considered.
#' @param plotLibrary Character string specifying which plotting library to use.
#'   Options are "ggplot", "echarts4r", "base", or "lattice". Default is c("ggplot", "echarts4r", "base", "lattice").
#' @return A plot object for ggplot, echarts4r, and lattice. Base R plots are output directly.
#'
#' @examples
#' \dontrun{
#' plotAvgLinesPerFile("/path/to/folder", c("txt", "csv", "R"), "lattice")
#' }
#'
#' @export
plotAvgLinesPerFile <- function(dirPath, fileTypes = NULL, plotLibrary = c("ggplot", "echarts4r", "base", "lattice")) {
    # Calculate average lines per file by file type
    avgLines <- avgLinesPerFile(dirPath, fileTypes)

    # Match the plot library argument and create a list of function calls
    plotFunc <- list(
        ggplot = genGgplot,
        echarts4r = genEcharts,
        base = genBaseRPlot,
        lattice = genLatticePlot
    )

    # Generate the bar plot with the specified library
    plot <- plotFunc[[match.arg(plotLibrary)]](avgLines)

    return(plot)
}

