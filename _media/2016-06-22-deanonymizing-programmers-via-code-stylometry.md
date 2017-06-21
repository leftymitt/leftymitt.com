---
title: "deanonymizing programmers via code stylometry."
layout: post
category: media
author: Aylin Caliskan-Islam, Richard Harang, Andrew Liu, Arvind Narayanan, Clare Voss, Fabian Yamaguchi, and Rachel Greenstadt
format: text
type: science
tags: 
 - anonymity
 - programming

published_date: "2015-08-12"
icon: drexel.svg 
link: "https://sci-hub.ac/www.cs.drexel.edu/~ac993/papers/caliskan-islam_deanonymizing.pdf"
---

Source  code  authorship  attribution  is  a  significant  privacy threat to
anonymous code contributors.  However, it may also enable attribution of
successful attacks from code left behind on an infected system, or aid in
resolving copyright, copyleft, and plagiarism issues in the programming fields.
In this work, we investigate machine learning methods to de-anonymize source
code authors of C/C++ using coding style. Our Code Stylometry Feature Set is a
novel representation of coding style found in source code that reflects coding
style from properties derived from abstract syntax trees.

Our random forest and abstract syntax tree-based approach attributes more
authors (1,600 and 250) with significantly  higher  accuracy  (94%  and  98%)
on  a  larger data  set  (Google  Code  Jam)  than  has  been  previously
achieved.  Furthermore, these novel features are robust, difficult to
obfuscate, and can be used in other programming languages, such as Python. We
also find that (i) the code resulting from difficult programming tasks is
easier to attribute than easier tasks and (ii) skilled programmers (who can
complete the more difficult tasks) are easier to attribute than less skilled
programmers.
