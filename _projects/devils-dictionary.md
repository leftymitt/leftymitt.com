---
title: "the devil's dictionary."
layout: post
category: projects
author: Ambrose Bierce
format: text
type: article
tags: 

added_date: "2016-05-06"
published_date: 
banner: ambrose-bierce.jpg 
repo: devils-dictionary

tag: MAN, n. An animal so lost in rapturous contemplation of what he thinks he is as to overlook what he indubitably ought to be. His chief occupation is extermination of other animals and his own species, which, however, multiplies with such insistent rapidity as to infest the whole habitable earth and Canada. 
---

The Devil's Dictionary was begun in a weekly paper in 1881, and was continued in a desultory way at long intervals until 1906. 
In that year a large part of it was published in covers with the title *The Cynic's Word Book*, a name which the author had not the power to reject or happiness to approve. 
To quote the publishers of the present work:

>This more reverent title had previously been forced upon him by the religious scruples of the last newspaper in which a part of the work had appeared, with the natural consequence that when it came out in covers the country already had been flooded by its imitators with a score of 'cynic' books -- The Cynic's This, The Cynic's That, and The Cynic's Other. Most of these books were merely stupid, though some of them added the distinction of silliness. Among them, they brought the word 'cynic' into disfavor so deep that any book bearing it was discredited in advance of publication.

Meantime, too, some of the enterprising humorists of the country had helped themselves to such parts of the work as served their needs, and many of its definitions, anecdotes, phrases and so forth, had become more or less current in popular speech. 
This explanation is made, not with any pride of priority in trifles, but in simple denial of possible charges of plagiarism, which is no trifle. 
In merely resuming his own the author hopes to be held guiltless by those to whom the work is addressed -- enlightened souls who prefer dry wines to sweet, sense to sentiment, wit to humor and clean English to slang.

A conspicuous, and it is hoped not unpleasant, feature of the book is its abundant illustrative quotations from eminent poets, chief of whom is that learned and ingenius cleric, Father Gassalasca Jape, S.J., whose lines bear his initials. 
To Father Jape's kindly encouragement and assistance the author of the prose text is greatly indebted.

A.B.

<hr>

<ul id="letter-filter" class="uk-subnav uk-subnav-pill uk-align-center uk-flex uk-flex-center">
{% for letter in site.data.devils-dictionary.dictionary %}
<li><a href="#section-{{ letter.letter }}">{{ letter.letter }}</a></li>
{% endfor %}
</ul>

{% for letter in site.data.devils-dictionary.dictionary %}
<hr>
<div class="uk-h2 uk-text-center" id="section-{{ letter.letter}}">{{ letter.letter }}</div>
<br>
<div class="uk-grid" data-uk-grid="{gutter:15, controls:'#letter-filter', animation:false}">
{% for term in letter.terms %}
<div data-uk-filter="{{ letter.letter }}" class="uk-width-1-1 uk-width-medium-1-1 uk-width-xlarge-1-2">
<div class="uk-panel uk-panel-box">
	<div class="uk-panel-title uk-panel-header">
	{{ term.word }} <span class="uk-float-right">{{ term.type }}</span>
	</div>

	<p>{{ term.def }}</p> 
	{% if term.poem  %} 
	<blockquote> 
	<p>{{ term.poem | strip | newline_to_br }}</p>
	<small> {{ term.author }}</small>
	</blockquote> 
	{% endif %}
</div>
</div>
{% endfor %}
</div>
{% endfor %}
