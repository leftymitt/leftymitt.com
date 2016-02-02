---
title: us presidential election dynamics
layout: post
category: projects
repo: us-elections
author: leftymitt

added_date: "2016-02-01"
published_date: "2016-02-01"

banner: "united-states.svg"
tag: "an analysis of presidential elections in the united states at the state and national level, along with scripts for collecting and interpreting the data."

js: "
<script src='/assets/build/js/snap.svg.min.js'></script>

<script>
window.onload = function() {
	var s = Snap('#mysvg');
	Snap.load('/assets/build/img/united-states.svg', function (f) {
		var g = f.select('g');

		var paths = g.selectAll('path');
		paths.forEach( function(elem) {
			elem.mouseover( function() {
				this.attr({
					fill: '#46C6C6',
					cursor: 'pointer'
				});
			});
			elem.mouseout( function() {
				this.attr({
					fill: '#555'
				});
			});
			elem.click( function() {
				this.attr({
					fill: '#EE6E6E'
				});
				var allname = 'all_' + this.attr('title').toLowerCase().replace(' ', '_') + '.svg';
				var biname = 'bi_' + this.attr('title').toLowerCase().replace(' ', '_') + '.svg';
				document.getElementById('bi_state_plots').src = '/assets/build/img/us-elections/' + biname;
				document.getElementById('all_state_plots').src = '/assets/build/img/us-elections/' + allname;
			});
		});

		s.append(g);
	});
}
</script>
"
---

<hr>

<div class="uk-flex uk-flex-center">
	<ul class="uk-subnav uk-subnav-pill" 
		 data-uk-switcher="{connect:'#state_plots, #pop_v_electoral, #pop_elect', 
	                       animation:'fade'}">
		<li><a>Democrats/Republicans</a></li>
		<li><a>All Parties</a></li>
	</ul>
</div>

<hr>

United States elections have a peculiarity in that the popular vote is filtered through an electoral college system. 
In a direct democracy, each vote is counted towards the grand total, and in the end, the candidate with the majority or plurality of the votes wins the election. 
With the electoral college, though, votes are aggregated on the state level, and each state is allotted a set number of 'electors' in proportion with its population size. 
The winner of the popular vote in each state gets, in most cases, all of its electoral vote, meaning that all votes that went toward a losing candidate count for nothing. 
When all votes are tallied, the candidate with the most electoral votes wins the election.  

Naturally, such a system has potential to be undemocratic, but by and large, the winner of the popular vote has been the winner of the electoral vote. 

Potential for being undemocratic notwithstanding, the electoral college has another interesting characteristic - it magnifies tiny wobbles in the overall popular vote into huge electoral margins. 
Throughout US history, small deviations from 50% popular support for a party translate into large changes in electoral votes one from one election to the next. 
A party with 40-45 percent of the vote generally wins few electoral votes, whereas parties that win 55-60% typically win almost all of them.  


Compare the electoral vote percentage won by each party with its popular vote over time:  


<div class="uk-cover uk-text-center">
	<div id="pop_elect" class="uk-switcher">
		<img src="{{ site.images }}/{{ page.repo }}/bi_national.svg"
		     alt="national voting for democrats and republicans">
		<img src="{{ site.images }}/{{ page.repo }}/all_national.svg"
		     alt="national voting for all parties">
	</div>
</div>


<div class="uk-cover uk-text-center">
	<div id="pop_v_electoral" class="uk-switcher">
		<figure>
			<img src="{{ site.images }}/{{ page.repo }}/bi_popular_v_electoral_national.svg"
			     alt="national popular vs electoral vote for democrats/republicans.">
		</figure>
		<figure>
			<img src="{{ site.images }}/{{ page.repo }}/all_popular_v_electoral_national.svg"
			     alt="national popular vs electoral vote for all parties.">
		</figure>
	</div>
</div>

<hr>

Often, electoral college outcomes are not undemocratic. 
In fact, during the nation's entire history, there have only been three instances of candidates losing the popular vote but winning in the electoral college: George Bush (2000), Rutherford Hayes (1876), and Benjamin Harrison (1888). 

<div class="">
<img src="{{ site.images }}/{{ page.repo }}/bi_popular_v_electoral_national_diff.svg"
     alt="national popular vs electoral vote for democrats/republicans."
     class="uk-align-right uk-width-medium-2-3">
</div>

That, by no means, is a vindication of the system. 
There have been numerous 'close calls,' where a candidate barely won the popular vote but still secured a substantial electoral advantage. 
Had a few states gone the other way, another undemocratic result may have been realized. 

The plot on the right plots the difference in popular vote received for democrats and republicans against the electoral difference for every election since 1860. 
Undemocratic outcomes are represented in quadrants 2 and 4. 

Despite the potential for undemocratic outcomes, the system is not inherently undemocratic. 
This is easily demonstrated. 
Take a simple example. 
Assume that the popular vote is uniformly distributed throughout the country, meaning that sampling people from Porcupine, South Dakota will yield the same proportion of people supporting a candidate as another sample taken from San Jose, California. 
Also assume that people supporting a particular candidate are just as likely to show up to a polling station as someone supporting another. 

Voting, then, essentially becomes a random sampling of a population. 
Given a large sample size, something true for all states, the likelihood of sampling a less popular candidate more than a more popular one is extremely small. 
In such an election, the more popular candidate will win all of the electoral votes, even if they only win ~51 percent of the popular vote. 

Of course, that scenario does not exist in reality. 
The people in each state support different policies and candidates, who must run on platforms defined by national political parties. 
On top of that, the demography of each state is different, and each group votes at different rates. 
Each state has unique preferences and a unique electoral history. 

<br>

<div class="uk-cover uk-text-center">
	<p class="uk-text-center">(click a state to view its electoral history)</p>

	<svg id="mysvg" width="100%" height="100%"  
		  viewBox="0 0 1035.2319 722.80334"></svg>

	<div id="state_plots" class="uk-switcher">
		<img id="bi_state_plots" 
	        src="{{ site.images }}/{{ page.repo }}/bi_alaska.svg"
		     alt="state voting history for republican and democratic parties.">
		<img id="all_state_plots" 
	        src="{{ site.images }}/{{ page.repo }}/all_alaska.svg"
		     alt="state voting history for all parties.">
	</div>
</div>

<hr> 

The two major political parties today, the Democrats and the Republicans, have both competed against each other since 1860, and for the most part, they have both dominated the popular vote. 
Exceptions in some elections in some states exist, but the overall pattern is clear. 

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_total_all_states.svg">
</div>

One interesting observation is that each of the downward blips in two-party popular totals rarely last for more than one election. 
These blips correspond to historically interesting events, such as: 

 * 1892 - James Weaver sweeps through the west in the Populist party. 
 * 1912 - Theodore Roosevelt runs as a Progressive party candidate. 
 * 1924 - Robert La Follette runs in the Progressive party. 
 * 1948 - Strom Thurmond represents the Dixiecrat party and winds states in the South. 
 * 1968 - George Wallace carries southern states with the American Independents. 
 * 1992 - Ross Perot challenges George Bush and Bill Clinton. 

In each of scenario, the loss of support for the two dominant parties corresponds to populist movements that ran on divergent platforms that often only had regional support. 

Essentially, the electoral college system presents an enormous hurdle to political groups without existing widespread national support and majorities in many regions. 
Polling at 20% everywhere translates to no electoral votes, incentivising voters to pick from established parties in hopes that their votes count toward a candidate with a chance of winning. 
This, coupled with the fact that the most successful third parties often champion inherently transient economic and social issues, such as currency policy during economic crises or segregation, leads to a stabilizing effect on the existing two party system. 

Still, both parties have dynamic voting histories in each state:  

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_all_states.svg">
</div>

<!--
<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_all_divisions.svg">
</div>
-->

For the most part, the country followed general trends for supporting one party or another. 
In other words, an increase in support for one party in one state correlated to an increase in another state. 
The notable exception is the South, which until 1940 voted overwhelmingly Democratic and was largely uncorrelated with other states. 
This observation is consistent with the idea that the electoral system magnifies small deviations from parity in the popular vote to large deviations in the electoral vote. 
Slight nation-wide increases in support for one party where opinion was closely split changed electoral losses to victories. 

Another exception is the pattern after 2000, where states increasingly diverge from each other, suggesting that states became more polarized politically or that no nationwide consensus of opinion existed to buoy one party in all states. 

Correlated nationally or not, voting patterns in each state is correlated with other states. It may be due to geographic proximity, demographic similarity, or pure statistical chance. 
The first reason for correlation can be easily seen by averaging states according to their [census region](https://en.wikipedia.org/wiki/List_of_regions_of_the_United_States#Census_Bureau-designated_regions_and_divisions). 

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_all_regions.svg">
</div>

As implied before, the South exhibits different voting patterns. 
It is perhaps notable that its unflagging support for the Democratic party in the pre-Civil Rights era is not reflected as unflagging support for Republicans today. 

A principal components analysis of states for every election yields further, non-initially biased information. 
Alaska, Hawaii, and Washington DC were excluded to increase the number of elections used in the analysis. 

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_pca_some_state.svg">
</div>


<img src="{{ site.images }}/{{ page.repo }}/bi_diff_pca_pc1_some_state.svg"
	  class="uk-align-right">

The first component (`var=0.615307`) is much more important than the second component (`var=0.0508273`), and segregates the South from the Northeast, with the West and Midwest states mixed in between.  

The loadings for PC1 favor elections away from 1960, which acts as an inflection point where political preferences for each state switch from one party to another. 
This is historically consistent with the evolution of the Republicans and Democrats during the Civil Rights Era. 
Dixiecrats in the south fell out of favor and joined the Republican Party, while liberal-minded people in left the Republicans and joined the Democratic party as it more actively pursued civil rights legislation.

Of course, history is replete with events that could retroactively be called turning points, and should an interesting feature have shown up on some other year, some event could likely be conjured up as an explanation. 

The second component, and presumably the others, has very little information. It does put states like Vermont and Mississippi close together, but given its low variance, interpreting it is not likely to be useful.  

Continuing with the census assumption of four distinct regions in the United States: a k-means clustering shows: 

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_pca_kmeans_some_state.svg">
</div>

Understandably, the four clusters do not fall precisely on the census regions, but they are close. 
The South is effectively partitioned in two. One South is characterized by states known to be the most reactionary that historically have broken from the two parties to support pro-segregationist candidates. 
The second south contains most remaining southern states, along with a few western states. 

The Northeastern states all fall into one cluster along with some midwestern and west coast states and those around Washington DC. The other cluster is nebulously defined but contains mostly midwestern and western states. 

Interestingly, the year with the second-highest loading, 1964, was Lyndon Johnson's overwhelming popular victory, where the only states where Republican Barry Goldwater won were Louisiana, Mississippi, Alabama, Georgia, and South Carolina, states that clustered into one group. 

Interpretations of these observation are purely speculative. 
The year with the highest loading, 1924, was Calvin Coolidge's easy victory, though it should be mentioned that Robert La Follette took much of the popular vote from the Democratic candidate.  


<!-- pca and k-means plots when alaska, dc, and hawaii are included. 

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_pca_state.svg">
</div>

<div class="uk-cover uk-text-center">
	<img src="{{ site.images }}/{{ page.repo }}/bi_diff_pca_kmeans_state.svg">
</div>

-->
