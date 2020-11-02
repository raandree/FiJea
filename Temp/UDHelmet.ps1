New-UDCard -Content {
    New-UDHtml -Markup '<a class="twitter-timeline" href="https://twitter.com/adamdriscoll?ref_src=twsrc%5Etfw">Tweets by adamdriscoll</a>'
    New-UDHelmet -Content {
        New-UDHtmlTag -Tag 'script' -Attributes @{
            src = 'https://platform.twitter.com/widgets.js'
            async = "true"
        }
        New-UDHtmlTag -Tag 'title' -Content { "Hello" }
    }
}