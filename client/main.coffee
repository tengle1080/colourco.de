Session.setDefault "colors", []
Session.setDefault "currentColor", {h: 0, s: 0.5, l: 0.5}
Session.setDefault "currentMenu", "menu-none"
Session.setDefault "schemeMode", "none"
Session.setDefault "editActive", true
Session.setDefault "displayColorType", "hex"
Session.setDefault "liftedColorIndex", null

Handlebars.registerHelper "foreach", (arr, options) ->
  return _.map arr, (item, index) ->
    item.$key   = index
    item.$index = index
    item.$first = index is 0
    item.$last  = index is arr.length-1
    return options.fn(item)
  .join('')
Template.menu["menu-class"] = (name) -> if Session.equals("currentMenu", name) then "active" else ""

Template.menu.rendered = () ->
  $(".menu [data-page]").click () ->
    $this = $ @
    pageIndex = $this.attr("data-page") * 1
    pageName = $this.attr("data-page-name")
    if pageIndex is 1
      Session.set "liftedColorIndex", null
      Session.set "schemeMode", pageName.replace("menu-","")
      if Session.equals "schemeMode", "none"
        Session.set "colors", []
        Session.set "editActive", true
      else
        Session.set "editActive", true
        Session.set "colors", [
          {h:  0, s: 0.5, l: 0.3}
          {h: .1, s: 0.5, l: 0.3}
          {h: .2, s: 0.5, l: 0.3}
          {h: .3, s: 0.5, l: 0.3}
          {h: .4, s: 0.5, l: 0.3}
        ]
        converter.scheme.generate Session.get("schemeMode")
    Session.set "currentMenu", pageName
    window.nextPage pageIndex
    return

Template.scheme.preserve [
  ".preview"
  ".details"
]

Template.scheme.colors = () -> Session.get "colors"
Template.scheme.currentColor = () -> Session.get "currentColor"
Template.scheme.editActive = () -> Session.get "editActive"
Template.scheme.isLifted = (index) -> Session.equals "liftedColorIndex", index
Template.scheme.isSchemeMode = () -> result = not Session.equals "schemeMode", "none"
Template.scheme.isCenter = (index) -> Math.floor(Session.get("colors").length / 2) is index
Template.scheme.bounds = () -> converter.bounds[Session.get "displayColorType"]
Template.scheme.factorizedColorValue = (hsl, key) ->
  type = Session.get("displayColorType")
  ~~(converter.convert("hsl", type, hsl)[key] * converter.bounds[type][key].f)
Template.scheme.displayColorType = (type) -> Session.get "displayColorType"
Template.scheme.getColor = (hsl, type) ->
  new Handlebars.SafeString converter.stringlify[type](converter.convert("hsl", type, hsl))
Template.scheme.getColorTag = (hsl, type) ->
  new Handlebars.SafeString converter.stringlify[type](converter.convert("hsl", type, hsl),"b")
Template.scheme.colorBack = (hsl) -> converter.stringlify.rgb(converter.convert("hsl", "rgb", hsl))
Template.scheme.markerLeft = (hsl) -> "#{hsl.h * 100}%"
Template.scheme.markerTop  = (hsl) -> "#{hsl.l * 100}%"
Template.scheme.colorFore = (hsl) -> converter.stringlify.fgc(converter.convert("hsl", "fgc", hsl))
Template.scheme.linkLess = (hsl) ->
  hex = converter.stringlify.hex(converter.convert("hsl", "hex", hsl)).substr(1)
  "http://api.colourco.de/export/less/%23#{hex}"
Template.scheme.linkImage = (hsl) ->
  hex = converter.stringlify.hex(converter.convert("hsl", "hex", hsl)).substr(1)
  "http://api.colourco.de/export/png/%23#{hex}"
Template.scheme.linkPerma = (hsl) ->
  hex = converter.stringlify.hex(converter.convert("hsl", "hex", hsl)).substr(1)
  "/none/%23#{hex}"
Template.scheme.editColor = (type, hsl) ->
  color = converter.convert "hsl", type, hsl
  inputs = ""
  cssClass = "edit-color"
  cssClass += " active" if Session.equals "displayColorType", type
  if type is "hex"
    value = converter.stringlify.hex(color).substr 1
    inputs += """
      <input
        type="text"
        data-type="#{type}"
        value="#{value}"
      />
    """
  else
    for key, bound of converter.bounds[type]
      value = ~~(color[key] * bound.f)
      inputs += """
        <input
          type="text"
          data-type="#{type}"
          data-key="#{key}"
          value="#{value}"
        />
      """
  new Handlebars.SafeString """
    <div class="#{cssClass}">
      <div class="hint--left" data-hint="click to choose '#{type}' as standard representation">
        <span data-type="#{type}">#{type}</span>
      </div>
      #{inputs}
    </div>
  """
Template.scheme.colorSlider = () ->
  type = Session.get "displayColorType"
  hsl = Session.get "currentColor"
  if not Template.scheme.isSchemeMode()
    hsl = Session.get("colors")[Session.get("liftedColorIndex")]

  color = converter.convert "hsl", type, hsl
  rows = ""
  for key, bound of converter.bounds[type]
    value = ~~(color[key] * bound.f)
    min = bound.min * bound.f
    max = bound.max * bound.f
    valueTag = ""
    valueTag = "value=\"#{value}\""
    gradientSteps = 10
    gradientRange = bound.max - bound.min
    gradientStep = gradientRange / gradientSteps
    gradientBody = ""
    for stepIndex in [0..gradientSteps]
      percentage = (100 / gradientSteps) * stepIndex
      gradientValue = bound.min + gradientStep * stepIndex
      gradientColor = jQuery.extend {}, color
      gradientColor[key] = gradientValue
      rgb = converter.stringlify.rgb(converter.convert type, "rgb", gradientColor)
      gradientBody += ", #{rgb} #{percentage.toFixed(2)}%"
    gradient = ""
    gradient += "background:-webkit-linear-gradient(left    #{gradientBody});"
    gradient += "background:   -moz-linear-gradient(left    #{gradientBody});"
    gradient += "background:    -ms-linear-gradient(left    #{gradientBody});"
    gradient += "background:     -o-linear-gradient(left    #{gradientBody});"
    gradient += "background:        linear-gradient(to right#{gradientBody});"
    console.log color
    console.log gradient
    rows += """
      <tr>
        <td>
          #{key}
        </td>
        <td style="#{gradient}">
          <input
            type="range"
            min="#{min}"
            max="#{max}"
            data-key="#{key}"
            step="any"
            #{valueTag} />
        </td>
        <td>
          #{value}
        </td>
      </tr>
    """
  new Handlebars.SafeString """
    <table>
      <colgroup>
        <col width="2em" />
        <col width="*" />
        <col width="4em" />
      </colgroup>
      <tbody>
        #{rows}
      </tbody>
    </table>
  """




Template.scheme.events
  "mousemove .edit": (e) ->
    color = Session.get "currentColor"
    $swatch = $(e.srcElement or e.target)
    while not $swatch.hasClass "swatch"
      $swatch = $swatch.parent()
    offset = $swatch.offset()
    h = (e.pageX - offset.left) / ~~($swatch.width() * 0.99)
    l = (e.pageY - offset.top) / $swatch.height()
    hsl = {h: h, s: color.s, l: l}
    Session.set "currentColor", hsl
  "mousemove .edit-scheme": (e) ->
    color = Session.get "currentColor"
    $swatches = $(e.srcElement or e.target)
    while not $swatches.hasClass "swatches"
      $swatches = $swatches.parent()
    offset = $swatches.offset()
    h = (e.pageX - offset.left - $swatches.width() * 0.05) / ~~($swatches.width() * 0.9)
    l = (e.pageY - offset.top) / $swatches.height()
    hsl = {h: h, s: color.s, l: l}
    Session.set "currentColor", hsl
    converter.scheme.generate Session.get("schemeMode")
  "click .edit": (e) ->
    colors = Session.get "colors"
    colors.push Session.get "currentColor"
    Session.set "colors", colors
    Session.set "editActive", false
    Session.set "liftedColorIndex", null
  "click .edit-scheme": (e) ->
    Session.set "editActive", false
    Session.set "liftedColorIndex", null
  "click .icon-lock": (e) ->
    Session.set "editActive", true
    Session.set "liftedColorIndex", null
  "click .add": (e) ->
    Session.set "editActive", true
    Session.set "liftedColorIndex", null
  "click .add-scheme": (e) ->
    e.preventDefault()
    colors = Session.get "colors"
    colors.push Session.get "currentColor"
    Session.set "colors", colors
    Session.set "liftedColorIndex", null
    converter.scheme.generate Session.get("schemeMode")
    return false
  "click .remove-scheme": (e) ->
    e.preventDefault()
    colors = Session.get "colors"
    colors.pop()
    Session.set "colors", colors
    Session.set "liftedColorIndex", null
    converter.scheme.generate Session.get("schemeMode")
    return false
  "click .icon-trash": (e) ->
    $swatch = $(e.srcElement or e.target)
    while not $swatch.hasClass "swatch"
      $swatch = $swatch.parent()
    index = $swatch.attr "data-index"
    colors = Session.get "colors"
    colors.splice index, 1
    Session.set "editActive", true if colors.length is 0
    Session.set "colors", colors
    Session.set "liftedColorIndex", null
  "click .icon-left": (e) ->
    $swatch = $(e.srcElement or e.target)
    while not $swatch.hasClass "swatch"
      $swatch = $swatch.parent()
    index = $swatch.attr "data-index"
    colors = Session.get "colors"
    color = colors.splice index, 1
    colors.splice index - 1, 0, color[0]
    Session.set "colors", colors
    Session.set "liftedColorIndex", null
  "click .icon-right": (e) ->
    $swatch = $(e.srcElement or e.target)
    while not $swatch.hasClass "swatch"
      $swatch = $swatch.parent()
    index = $swatch.attr "data-index"
    colors = Session.get "colors"
    color = colors.splice index, 1
    colors.splice index + 1, 0, color[0]
    Session.set "colors", colors
    Session.set "liftedColorIndex", null
  "click .icon-up": (e) ->
    $swatch = $(e.srcElement or e.target)
    while not $swatch.hasClass "swatch"
      $swatch = $swatch.parent()
    index = $swatch.attr("data-index") * 1
    Session.set "liftedColorIndex", index
  "click .icon-down": (e) ->
    Session.set "liftedColorIndex", null
  "click span[data-type]": (e) ->
    $span = $(e.srcElement or e.target)
    Session.set "displayColorType", $span.attr("data-type")
  "change input[type=text][data-type]": (e) ->
    $input = $(e.srcElement or e.target)
    type = $input.attr "data-type"
    key = $input.attr "data-key"
    value = $input.val()
    srcColorHsl = Session.get "currentColor"
    if not Template.scheme.isSchemeMode()
      srcColorHsl = Session.get("colors")[Session.get("liftedColorIndex")]
    srcColor = converter.convert("hsl", type, srcColorHsl)
    if type is "hex"
      value = value.replace /^#+/g, ""
      bl = ~~(value.length / 3)
      srcColor.r = parseInt(new Array(4 - bl).join(value.substr(0 * bl, 1 * bl)), 16) / 255
      srcColor.g = parseInt(new Array(4 - bl).join(value.substr(1 * bl, 1 * bl)), 16) / 255
      srcColor.b = parseInt(new Array(4 - bl).join(value.substr(2 * bl, 1 * bl)), 16) / 255
    else
      value *= 1
      value /= converter.bounds[type][key].f
      srcColor[key] = value
    srcColorHsl = converter.convert(type, "hsl", srcColor)
    if Template.scheme.isSchemeMode()
      Session.set "currentColor", srcColorHsl
      converter.scheme.generate Session.get("schemeMode")
    else
      colors = Session.get "colors"
      colors[Session.get("liftedColorIndex")] = srcColorHsl
      Session.set "colors", colors
  "mouseup input[type=range]": (e) ->
    $range = $(e.srcElement or e.target)
    srcColorHsl = Session.get "currentColor"
    if not Template.scheme.isSchemeMode()
      srcColorHsl = Session.get("colors")[Session.get("liftedColorIndex")]
    type = Session.get("displayColorType")
    srcColor = converter.convert("hsl", type, srcColorHsl)
    key = $range.attr "data-key"
    value =
    srcColor[key] = ($range.val() * 1) / converter.bounds[type][key].f
    srcColorHsl = converter.convert(type, "hsl", srcColor)
    if Template.scheme.isSchemeMode()
      Session.set "currentColor", srcColorHsl
      converter.scheme.generate Session.get("schemeMode")
    else
      colors = Session.get "colors"
      colors[Session.get("liftedColorIndex")] = srcColorHsl
      Session.set "colors", colors

Template.menu.linkLess = () ->
  colorStr = "http://api.colourco.de/export/less/"
  for color, colorIndex in Session.get "colors"
    colorStr += "%2C" if colorIndex > 0
    colorStr += "%23"
    colorStr += converter.stringlify.hex(converter.convert("hsl", "hex", color)).substr(1)
  colorStr
Template.menu.linkImage = (hsl) ->
  colorStr = "http://api.colourco.de/export/png/"
  for color, colorIndex in Session.get "colors"
    colorStr += "%2C" if colorIndex > 0
    colorStr += "%23"
    colorStr += converter.stringlify.hex(converter.convert("hsl", "hex", color)).substr(1)
  colorStr
Template.menu.linkPerma = (hsl) ->
  colorStr = "/"
  if Session.equals "schemeMode", "none"
    colorStr += "none/"
    for color, colorIndex in Session.get "colors"
      colorStr += "%2C" if colorIndex > 0
      colorStr += "%23"
      colorStr += converter.stringlify.hex(converter.convert("hsl", "hex", color)).substr(1)
  else
    colorStr += "#{Session.get "schemeMode"}/#{Session.get("colors").length}/%23"
    colorStr += converter.stringlify.hex(converter.convert("hsl", "hex", Session.get "currentColor")).substr(1)
  colorStr

Meteor.startup () ->
  Meteor._reload.onMigrate () ->
    if confirm("The application has been updated!\nPress OK to restart the application.\n(The current status will maybe lost)")
      [true]
    else
      false
  path = window.location.pathname
  pathParts = path.split "/"
  if pathParts.length is 3 and pathParts[1] is "none"
    colorStrings = decodeURIComponent(pathParts[2]).split(",")
    colors = []
    for colorString, colorIndex in colorStrings
      if colorString.length is 7
        r = parseInt colorString.substr(1, 2), 16
        g = parseInt colorString.substr(3, 2), 16
        b = parseInt colorString.substr(5, 2), 16
        hsl = converter.convert "rgb", "hsl", {r: r / 255, g: g / 255, b: b / 255}
        colors.push hsl
        Session.set "currentColor", hsl
    if colors.length > 0
      Session.set "colors", colors
      Session.set "editActive", false
  if pathParts.length is 4
    colorString = decodeURIComponent(pathParts[3])
    if colorString.length is 7
      r = parseInt colorString.substr(1, 2), 16
      g = parseInt colorString.substr(3, 2), 16
      b = parseInt colorString.substr(5, 2), 16
      hsl = converter.convert "rgb", "hsl", {r: r / 255, g: g / 255, b: b / 255}
      Session.set "currentColor", hsl
    numColors = pathParts[2] * 1
    if numColors > 3 and numColors < 11
      colors = []
      for colorIndex in [1..numColors]
        colors.push {h: 0, s: 0, l: 0}
      Session.set "colors", colors
      Session.set "currentMenu", "menu-#{pathParts[1]}"
      Session.set "schemeMode", pathParts[1]
      Session.set "editActive", false
      converter.scheme.generate Session.get("schemeMode")

  $main = $ "#main"
  $pages = $main.children "div.page"
  isAnimating = false
  endCurrPage = false
  endNextPage = false
  animationEvents = 'animationend webkitAnimationEnd MSAnimationEnd oAnimationEnd'
  current = 0

  $pages.each () ->
    $page = $ @
    $page.data "originalClassList", $page.attr("class")

  $pages.eq(current).addClass("page-current")

  window.nextPage = (index) ->
    return false if isAnimating
    isAnimating = true;
    $currPage = $pages.eq current
    current = index

    $nextPage = $pages.eq(current)
    isAnimating = false if $nextPage.hasClass "page-current"
    return if $nextPage.hasClass "page-current"
    $nextPage.addClass("page-current")
    outClass = "page-rotateTopSideFirst"
    inClass = "page-moveFromTop page-delay200 page-ontop"

    $currPage.addClass(outClass).on animationEvents, () ->
      $currPage.off(animationEvents)
      endCurrPage = true
      onEndAnimation($currPage, $nextPage) if endNextPage

    $nextPage.addClass(inClass).on animationEvents, () ->
      $nextPage.off animationEvents
      endNextPage = true
      onEndAnimation($currPage, $nextPage) if endCurrPage

  wheelEvent = (e) ->
    delta = if (e.wheelDelta || e.detail || e.originalEvent.wheelDelta || e.originalEvent.detail) > 0 then 0.025 else -0.025
    hsl = Session.get "currentColor"
    hsl.s = Math.max(0, Math.min(1, hsl.s + delta))
    Session.set "currentColor", hsl if Session.equals "editActive", true
    converter.scheme.generate Session.get("schemeMode") unless Session.equals "schemeMode", "none"


  $("body").bind "mousewheel", wheelEvent
  $("body").bind "DOMMouseScroll", wheelEvent

  onEndAnimation = ($outpage, $inpage ) ->
    endCurrPage = false
    endNextPage = false
    resetPage $outpage, $inpage
    isAnimating = false

  resetPage = ($outpage, $inpage) ->
    $outpage.attr 'class', $outpage.data('originalClassList')
    $inpage.attr 'class', $inpage.data('originalClassList') + ' page-current'

  setTimeout () ->
    window.nextPage current + 1
  , 250

Template.analytics.rendered = ->
  if !window._gaq?
    window._gaq = []
    _gaq.push(['_setAccount', 'UA-29865051-1'])
    _gaq.push(['_setDomainName', 'colourco.de'])
    _gaq.push(['_trackPageview'])

    (->
      ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      gajs = '.google-analytics.com/ga.js'
      ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
      s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
    )()

