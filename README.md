# csvsplit
A command line tool to split and partion arbitrary large CSV files.

It takes as input a arbitrary large csv file and a list of columns for partioning the data.
It creates then nested directories for all combination of the partioning columns and csv files containing subset of the data.

This format is well suited as input for Spark.

It streams the file for input and output, so works with arbitraty large files

It uses internaly the R package readr::read_csv_chunked function, which is very robust and fast.

I has as well a nice progess bar, good for larger files.

