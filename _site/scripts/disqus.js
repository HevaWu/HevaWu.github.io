window.onload = function () {
    var page = document.activeElement("page");
    var site = document.activeElement("site");

    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
    var disqus_shortname = 'he_wu'; // required: replace example with your forum shortname
    var disqus_identifier = "{{ page.id }}";
    var disqus_url = "{{site.url}}{{page.url}}";

    /* * * DON'T EDIT BELOW THIS LINE * * */
    (function () {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
}