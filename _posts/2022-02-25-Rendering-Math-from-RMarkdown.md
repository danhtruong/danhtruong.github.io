---
layout: single
toc: true
mathjax: true
title: Rendering Math from RMarkdown
tags: tutorials  R
---

In some of my posts, I have had trouble rendering math with MathJax. My
posts that include math equations were written in R markdown. Then I
used knitr to convert them into a markdown file before posting them to
my webpage. However, the math written using Latex ends up converted in a
way that is non-renderable.

My webpage and most others that have pages through GitHub are based on
[Jekyll](https://jekyllrb.com), which cannot parse the math even after
conversion. To handle this, I have come across a
[post](https://tinyheero.github.io/2015/12/06/rmd-to-jekyll-protect-eqn.html)
by Fong Chun Chan that gives some insight. Essentially, you need to
protect your latex equations with HTML tags in the R markdown file, so
that when you perform the conversion, they are kept intact. Afterwards,
you can remove the HTML tags and MathJax will interpret the equations
and render them correctly.

## MathJax

First, we need to add the MathJax script to your website. For Jekyll,
you add it to `_includes/head.html`. I use the [Minimal
Mistakes](https://mmistakes.github.io/minimal-mistakes/) theme so if you
have that, you can add it to `_layouts/single.html`.

``` js
<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
```

This enables the MathJax javascript library so it can parse the math
equations and render them on your website.

## Protecting display math equations

In R markdown, a typical display equation would be:

``` bash
$$ y = mx + b $$
```

*y* = *m**x* + *b*

As you can see, it does not render properly. It should like like the one
below:

$$ y = mx + b $$

To solve this, we can add HTML tags prior to the knitr conversion, where
knitr will not touch the equations, and then remove them later so that
MathJax can parse them. I found a
[script](https://gist.github.com/emanuelhuber/11835e6840868029d7c4721b7f7bf465)
that can do just that. It will look like this with tags prior to markdown conversion.

``` js
<pre>$$ y = mx + b $$</pre>
```

I have modified the script below. You can download it
[here](https://github.com/danhtruong/danhtruong.github.io/blob/master/assets/files/r2jekyll.R).

``` r
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
read_lines <- gsub("(\\${2}(.+?)\\${2})", "\\1<\\/pre>", read_lines)

writeLines(read_lines, tempfile)

rmarkdown::render(tempfile, output_format = "md_document"
    , output_file = mdtempfile)

read_lines <- readLines(mdtempfile)

# remove pre tags
sel <- grepl("", read_lines)
read_lines[sel] <- str_replace(read_lines[sel], '', '') %>%
  str_replace('</pre>', '') 

# remove multiple spaces from lists
sel <- grepl("[[:space:]]{2}\\${1}(.+?)\\${1}", read_lines)
read_lines[sel] <- gsub('\\s+', ' ', read_lines[sel])

# add correct path for files
read_lines <- gsub('files/', "{{ site.baseurl }}/files/" , read_lines) # this one is for me to add correct file path when you have output files, but you can change it to where your files are. 

writeLines(read_lines, mdfile)

# delete temp files
unlink(mdtempfile)
unlink(tempfile)
```

Place the script in the same folder as your R markdown file. Then run
the following:

``` bash
Rscript --vanilla r2jekyll.R your_RMarkdownFile.Rmd
```

Before running, if you generate output files or figures, make sure to
add the following to the top of your R markdown notebook.

## Enabling inline math equations

Now, for inline math equations. MathJax does not handle this unless you
properly
[configure](https://docs.mathjax.org/en/v2.7-latest/options/preprocessors/tex2jax.html)
it. So simply add this right before where you added the MathJax script.
For instance, see below:

``` js
<script>
MathJax = {
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']]
  }
};
</script>

<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
```

## Additional Resources

-   [R Markdown to Jekyll: “Protecting” Your Math Equations]([https://tinyheero.github.io/2015/12/06/rmd-to-jekyll-protect-eqn.html])
-   [MathJax](https://www.mathjax.org)
