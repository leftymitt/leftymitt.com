---
title: "about this site."
layout: post
category: blog
author: leftymitt

added_date: "2015-11-24"
published_date: "2015-11-25"
---

This site functions mostly as an information aggregator, compiling noteworthy reports, publications, articles, projects, guides, anime, etc. with some original content. To find you here, out of all the other places on the internet, is quite a surprise. Welcome.  

For those concerned about the information you divulge by visiting this site, the entire website is open source, hosted on GitHub at [leftymitt.github.io](https://github.com/leftymitt/leftymitt.github.io). The site uses the [Uikit](getuikit.com) framework for Javascript and CSS.  

That notwithstanding, there are some potential areas of concern for the preternaturally paranoid:  

1. All dependencies used for building the site are handled by npm and bower, neither of which sign their packages. (npm checks shasums, though.) See the discussions on [bower](https://github.com/bower/bower/issues/1775) and [npm](https://github.com/npm/npm/pull/4016). Potentially, a malicious third party can intercept dependencies when downloaded and then inject some Javascript.  

2. Your connection to this site isn't truly encrypted. HTTPS is provided by [CloudFlare's Flexible SSL](https://www.cloudflare.com/ssl/), mainly because GitHub, this site's hosting service, [does not support SSL with custom domain names](https://github.com/isaacs/github/issues/156). This page is encrypted from CloudFlare's servers to your browser, but the connection between CloudFlare and GitHub is fair game for any malicious third party. Still, that particular avenue on ingress isn't at all easy to exploit.  

3. The site makes heavy use of SVGs to avoid compression artifacts from bitmap-style image formats (PNG, JPG, etc.). All SVGs used on the site are included with `<img>` tags, and most browsers will not run any code embedded in them as long as they are used. See [this talk](https://www.hackinparis.com/slides/hip2k11/09-TheForbiddenImage.pdf) for an explanation of what SVGs are and how they can be used as an attack vector.  

4. At the bottom of most pages are links for sharing via various social media. The icons are purely CSS and built with FontAwesome. The links do not inherently enable social media sites to track you. Just watch out for your browser. By default, it may be configured to prefetch links on whatever page you're on to make loading new pages seem faster. 

5. You can send bitcoin tips to this [bitcoin address](bitcoin:{{ site.bitcoin.address }}?amount=.025). The site doesn't generate new addresses for each transaction; it only uses a single one. This means that the wallet associated with this site and the fact you sent bitcoin to it will be documented on the blockchain. 
