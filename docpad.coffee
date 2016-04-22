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
      oldUrls: []

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

      # Header images dir path
      headerImagesDirPath: "/images/"

      # Styles
      styles: [
        "/vendor/twitter-bootstrap/css/bootstrap.min.css"
        "/styles/blog.css"
      ]

      # Scripts
      scripts: [
        "/vendor/jquery/js/jquery.min.js"
        "/vendor/twitter-bootstrap/js/bootstrap.min.js"
        "/vendor/jquery/js/jquery.bootstrap-autohidingnavbar.js"
        "/scripts/blog.js"
      ]


    # -----------------------------
    # Helper Functions

    # Get the prepared site/document title
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

    # Get path to the header image
    # Default return header-default.jpg
    getHeaderImagePath: (image) ->
      if !image
        image = "header-default.jpg"
      return "#{@site.headerImagesDirPath}#{image}"

    # Get all authors of posts
    # Return array of arrays, where [i][0]: author, [i][1]: number of posts
    getBloggers: (posts) ->
      sortedBloggers = getAuthorsWithNumberOfPosts(posts)
      return sortedBloggers

    # Get the blogger who posted the biggest amount of posts
    # Return {name: blogger name, numberPosts: number of posts}
    getMostActiveBlogger: (posts) ->
      sortedCounts = getAuthorsWithNumberOfPosts(posts)
      # FIX: Must return many blogger if they have the same number of posts
      return {name: sortedCounts[0][0], numberPosts: sortedCounts[0][1]};


  # =================================
  # Collections
  # These are special collections that our website makes available to us
  collections:
    # Documents from `pages` dir which have `pageOrder` meta attribute
    pages: (database) ->
      database.findAllLive({
        relativeOutDirPath: 'pages'
        pageOrder:
          $exists: true
      }, [pageOrder: 1, title: 1])
      .on "add", (model) ->
        model.setMetaDefaults({layout: "page"})

    # Documents from `posts` dir, newer than a month ago
    activePosts: (database) ->
      database.findAllLive({
        relativeOutDirPath: 'posts'
        date:
          $gt: getDateMonthAgo()
      }, [{date: -1}, {title: 1}])
      .on "add", (model) ->
        model.setMetaDefaults({layout: "post"})

    # Documents from `posts` dir which `date` older than a month ago
    # Tagged as `archived` and return
    archivedPosts: (database) ->
      return database.findAllLive({
        relativeOutDirPath: 'posts'
        date:
          $lt: getDateMonthAgo()
      }, [{date: -1}, {title: 1}])
      .on "add", (model) ->
        model.setMetaDefaults({layout: "post", archived: true})

  # =================================
  # Plugins
  plugins:
    tags:
      injectDocumentHelper: (document) ->
        # Set layout of documents for tags
        document.setMeta({layout: 'tag', headerImage: 'header-tag.jpg'})


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
      server.use (req, res, next) ->
        if req.headers.host in oldUrls
          res.redirect(newUrl + req.url, 301)
        else
          next()

}

# ===============================
# Helper methods for config

# Get date from the month ago
getDateMonthAgo = ->
  todayDate = new Date(Date.now());
  monthAgoDate = todayDate.setMonth(todayDate.getMonth() - 1)
  return monthAgoDate

# Get authors of posts collection with number of posts
# Sorted descending by number of posts
# Return array of arrays, where [i][0]: author, [i][1]: number of posts
getAuthorsWithNumberOfPosts = (posts) ->
  # Insert authors and number of posts to object where key: author, value: number of posts
  counts = {}
  posts.forEach((x) ->
    counts[x.author] = (counts[x.author] or 0) + 1
  )
  # Sort object descending by value
  sortedCounts = []
  for key, value of counts
    sortedCounts.push([key, value])
  # Sorting descending so compare by b[1]-a[1]
  sortedCounts.sort((a, b) -> b[1] - a[1])
  return sortedCounts

# Export the DocPad Configuration
module.exports = docpadConfig