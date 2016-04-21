# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
	# ================================
  # Template Data
  # Variables that will be accessible via our templates

  templateData:

    # Site properties
    site:
      # The production url of our website
      url: "http://localhost:9778"

      # Here are some old site urls that you would like to redirect from
      ldUrls: []

      # The default title of our website
      title: "Blog DocPad"

      # The website description (for SEO)
      description: """
        Examples blog created using DocPad.
        """

      # The website keywords (for SEO) separated by commas
      keywords: """
        blog, docpad, bootstrap, jquery
        """

      # The website author's name
      author: "Jakub Gawlas"

      # The website author's email
      email: "jakub.gawlas.dev@gmail.com"

      # Styles
      styles: [
        "/vendor/twitter-bootstrap/css/bootstrap.min.css"
        "/styles/clean-blog.css"
      ]

      # Scripts
      scripts: [
        "//cdnjs.cloudflare.com/ajax/libs/jquery/1.10.2/jquery.min.js"
        "//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js"
        "/vendor/jquery/js/jquery.min.js"
        "/vendor/twitter-bootstrap/js/bootstrap.min.js"
        "/scripts/clean-blog.js"
      ]


    # -----------------------------
    # Helper Functions

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
    # if we have a document title, then we should use that and suffix the site's title onto it
        if @document.title
          "#{@document.title} | #{@site.title}"
    # if our document does not have it's own title, then we should just use the site's title
        else
          @site.title

    # Get the prepared site/document description
    getPreparedDescription: ->
    # if we have a document description, then we should use that, otherwise use the site's description
        @document.description or @site.description

    # Get the prepared site/document keywords
    getPreparedKeywords: ->
    # Merge the document keywords with the site keywords
        @site.keywords.concat(@document.keywords or []).join(', ')


    # =================================
    # Collections
    # These are special collections that our website makes available to us

  collections:
    # Documents from `pages` dir which have `pageOrder` meta attribute
    pages: (database) ->
      database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])
        .on "add", (model) ->
          model.setMetaDefaults({layout: "page"})

    # Documents from `posts` dir
    posts: (database) ->
      database.findAllLive({relativeOutDirPath: 'posts'}, [{date:-1}, {title: 1}])
        .on "add", (model) ->
          model.setMetaDefaults({layout: "post"})

    # Documents from `posts` dir which `date` older than a month ago
    # Tagged as `archived` and return
    archivedPosts: (database) ->
      todayDate = new Date(Date.now());
      monthAgoDate = todayDate.setMonth(todayDate.getMonth()-1)
      return database.findAllLive($and: {relativeOutDirPath: 'posts', date: $lt: monthAgoDate},[{date: -1}])
        .on "add", (model) ->
          model.setMetaDefaults({archived: true})


  # =================================
  # Plugins

  plugins:
    tags:
      injectDocumentHelper: (document) ->
        document.setMeta(layout: 'page')


    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki
  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

      # As we are now running in an event,
      # ensure we are using the latest copy of the docpad configuraiton
      # and fetch our urls from it
      latestConfig = docpad.getConfig()
      oldUrls = latestConfig.templateData.site.oldUrls or []
      newUrl = latestConfig.templateData.site.url

      # Redirect any requests accessing one of our sites oldUrls to the new site url
      server.use (req,res,next) ->
        if req.headers.host in oldUrls
          res.redirect(newUrl+req.url, 301)
        else
          next()

}

# Export the DocPad Configuration
module.exports = docpadConfig