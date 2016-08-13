---
title: "corruption perceptions index."
layout: post
category: blog
author: leftymitt
format: text
type: article
tags: 
 - data
 - corruption

added_date: "2016-02-27"
published_date: "2016-02-27"
img: "corruption-index/cpi_density_before_2012.svg"
repo: corruption-perceptions-index

css: "
<style>
img {
	margin-left:auto;
	margin-right:auto;
	display:block;
	max-width:100%;
	height:auto;
}
</style>
"
---

The Corruption Perceptions Index (CPI) is a rough metric for political and
corporate corruption created by Transparency International (TI), a German
anti-corruption NGO Each year, TI releases a score ranging from 0 to 100 for
each country.  Low scores correspond to high levels of corruption, and vice
versa.  Corruption is broadly defined as misuse of public power for private
gain. 

Scores are derived from between 3 to 11 external reports or surveys that
provide some measurement for corruption.  They are calculated as follows: 

> Each source is then standardised to be compatible with other available
> sources, for aggregation to the CPI scale. The standardisation converts all
> the data sources to a scale of 0-100 where a 0 = highest level of perceived
> corruption, and 100 = lowest level of perceived corruption. 
> 
> Any source that is scaled such that lower scores represent lower levels of
> corruption must first be reversed. This is done by multiplying every score in
> the data set by -1. 
> 
> Every score is then standardised (to a z score) by subtracting the mean of
> the data and dividing by the standard deviation. This results in a data set
> centred around 0 and with a standard deviation of 1. 
> 
> For these z scores to be comparable between data sets, we must define the
> mean and standard deviation parameters as global parameters. Therefore where
> a data set covers a limited range of countries, we impute scores for all
> those countries that are missing in the respective data set. We impute
> missing values for missing countries in each data set using the statistical
> software package STATA and, more specifically, the programme’s impute
> command. This command regresses each data set against the CPI data sources
> that are at least 50% complete to estimate values for each country that is
> missing data in each individual data set. This is with the exception of the
> Bertelsmann Foundation’s Transformation Index data, which is not used for the
> imputation of the Bertelsmann Foundation’s Sustainable Governance Indicators
> because there is no overlap in country coverage of these two data sources.
> The mean and standard deviation for the data set is calculated as an average
> of the complete data sets and is used as the parameter to standardise the raw
> data. Importantly, the complete data set with imputed values is used only to
> generate these parameters and the imputed values themselves are not used as
> source data for CPI country scores. 
> 
> Critically, the z scores are calculated using the mean and standard deviation
> parameters from the imputed 2012 scores. This is so that 2012 is effectively
> the baseline year for the data and the rescaled scores can be comparable year
> on year. When new sources enter the index, in order to appropriately reflect
> changes over time, the rescaling calculation will allow for these to be
> consistent with 2012 baseline parameters. This is done by first estimating if
> there has been a global change in the mean and standard deviation since 2012,
> and then using these new values, which may have deviated from 50 and 20 to
> rescale the new data set. 
> 
> The z scores are then rescaled to fit the CPI scale between 0-100. This uses
> a simple rescaling formula, which sets the mean value of the standardised
> dataset to approximately 45, and the standard deviation of approximately 20.
> Any score which exceeds the 0 to 100 boundaries will be capped.


Basically, all external scores are normalized to a mean of 0 and standard
deviation of 1, and then they are rescaled to a mean of 45 and standard
deviation of 20.  The normalized scores for each country are averaged, and the
result is the Corruption Perception Index.  Look at the figure below to
visualize this.  The mean of all countries' CPI for each year is ~45 and
standard deviation (the area colored above and below the line) is ~20.

![CPI density after 2012]({{ site.images
}}/corruption-index/cpi_stats_after_2012.svg)

This only applies to reports from 2012 and after.  Previous years (1995-2011)
used a different normalization scheme.  Data from the two groups are not
comparable.  See below for a time-series for the mean and standard deviation
for all countries each year.

![CPI density before 2012]({{ site.images
}}/corruption-index/cpi_stats_before_2012.svg)

By no means is the CPI a rigorous measurement.  Of course, any measure of
corruption is inherently not rigorous because corruption happens clandestinely.
Still, the fact that not every external measure covers all countries and that
each country gets different numbers of measurements from different sources
undoubtedly skews normalizations. 

Also, the normalization step renders changes in CPI scores for each country
over time somewhat meaningless.  For example, if Denmark maintains is lack of
corruption while many corrupt countries become less corrupt, Denmark's CPI will
decrease because the globally elevated corruption scores will reduce the
distance it is from the global mean.  Another scenario, that the corrupt
nations maintain their levels of corruption while Denmark becomes more corrupt,
fits the same data.  That is very problematic, and it can only be addressed by
going though the original raw scores from each source.

And, for the conspiratorially-minded, Transparency International is by no means
an organization exempt from [pressures from powerful
governments](https://en.wikipedia.org/wiki/Transparency_International#Refusal_to_support_Edward_Snowden). 



Still, it's worth noting some patterns in the data. 

![CPI density before 2012]({{ site.images
}}/corruption-index/cpi_density_before_2012.svg)

For the dataset from 1998-2011, plotted above, the distribution of CPI values
becomes more skewed over time toward the largest peak.  The smaller peak
corresponding to higher CPIs shrinks over time.  Questions of whether some
countries are overall becoming more or less corrupt cannot be answered by the
distribution, but it does establish that countries became more similarly
corrupt. 

![CPI density after 2012]({{ site.images
}}/corruption-index/cpi_density_after_2012.svg)

On inspection, changes in CPI distributions from 2012 to 2015 (plotted above)
are not apparent. 
