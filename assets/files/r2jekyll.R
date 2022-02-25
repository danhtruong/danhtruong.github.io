#!/usr/bin/env Rscript

#-----------------------------------------------------------------------------
# How to run? 
# In terminal enter: Rscript --vanilla r2jekyll.R your_RMarkdownFile.Rmd

#-----------------------------------------------------------------------------
# Problem while rendering Rmarkdown files with latex equation into markdown file
# -> Rmarkdown try to convert the equation into markdown instead of leaving them
#    as latex equation. In consequences, the equations within the mardown file
#    are not correctly rendered in a website powered by jekyll and using
#    MathJax.js (a JavaScript display engine for mathematics)

#-----------------------------------------------------------------------------
# What does r2jekyll.R do?
# 1) it reads the Rmarkdown file
# 2) wrap the latex equation with the HTML tags <pre> and </pre> 
#    This "trick" to protect the latex equation from being knitted
#    into markdown
# 3) knit the Rmarkdown file into markdown
# 4) remove the <pre> and </pre> tags

#-----------------------------------------------------------------------------
# inspired by:
# - Nicole White
#    https://nicolewhite.github.io/2015/02/07/r-blogging-with-rmarkdown-knitr-jekyll.html
# - Fong Chun Chan
#    http://tinyheero.github.io/2015/12/06/rmd-to-jekyll-protect-eqn.html
# - Emanuel Huber
#    https://gist.github.com/emanuelhuber/11835e6840868029d7c4721b7f7bf465


library(rmarkdown)
library(dplyr)
library(stringr)

# Get the filename given as an argument in the shell.
args <- commandArgs(TRUE)
filename <- args[1]

# Check that it's a .Rmd file.
if(!grepl(".Rmd", filename)) {
  stop("You must specify a .Rmd file.")
}

tempfile <- sub('.Rmd', '_deleteme.Rmd', filename)
mdtempfile <- sub('.Rmd', '_deleteme.md', filename)
mdfile <- sub('.Rmd', '.md', filename)

read_lines <- readLines(filename)

# add pre tags around $...$
read_lines <- gsub("(\\${2}(.+?)\\${2})", "<pre>\\1<\\/pre>", read_lines)

writeLines(read_lines, tempfile)

rmarkdown::render(tempfile, output_format = "md_document"
	, output_file = mdtempfile)

read_lines <- readLines(mdtempfile)

# remove pre tags
sel <- grepl("<pre>", read_lines)
read_lines[sel] <- str_replace(read_lines[sel], '<pre>', '') %>%
  str_replace('</pre>', '') 

# remove multiple spaces from lists
sel <- grepl("[[:space:]]{2}\\${1}(.+?)\\${1}", read_lines)
read_lines[sel] <- gsub('\\s+', ' ', read_lines[sel])

# add correct path for figures
read_lines <- gsub('figures/', "{{ site.baseurl }}/figures/" , read_lines) # this one is for me to add correct file path when you have images, but you can change it to where your files are. 

writeLines(read_lines, mdfile)

# delete temp files
unlink(mdtempfile)
unlink(tempfile)
