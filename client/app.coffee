Meteor.startup () ->
  settings =
    _colorMod: 96
    mode: 'code'
    scheme:
      mode: 'mono'
      colors: []
      edit: -1;
      locked: false
      contrast: 2.0
    code:
      colors: []
      edit: -1;
      locked: false

  d3.ihx = (hsl) -> #inverted hex
    rgb = new d3.rgb hsl
    mod = if Math.max(rgb.r, rgb.g, rgb.b) > 255 - settings._colorMod then -settings._colorMod else settings._colorMod
    @r = Math.min(255, Math.max(0, rgb.r + mod))
    @g = Math.min(255, Math.max(0, rgb.g + mod))
    @b = Math.min(255, Math.max(0, rgb.b + mod))
    @

  d3.hex = (hsl) ->
    strHex = hsl.toString()
    @r = strHex.substr(1,2)
    @g = strHex.substr(3,2)
    @b = strHex.substr(5,2)
    @

  downloadURL = (url) ->
    hiddenIFrameID = 'hiddenDownloader'
    iframe = document.getElementById(hiddenIFrameID)
    if (iframe is null)
      iframe = document.createElement('iframe')
      iframe.id = hiddenIFrameID
      iframe.style.display = 'none'
      document.body.appendChild(iframe)
    iframe.src = url
    return

  window.hslToIhxText = (hsl) -> "rgb(#{(new d3.ihx(hsl)).r}, #{(new d3.ihx(hsl)).g}, #{(new d3.ihx(hsl)).b})"
  window.hslToHexHtml = (hsl) -> "#<b>#{(new d3.hex(hsl)).r}</b><b>#{(new d3.hex(hsl)).g}</b><b>#{(new d3.hex(hsl)).b}</b>"
  window.hslToHexText = (hsl) -> "##{(new d3.hex(hsl)).r}#{(new d3.hex(hsl)).g}#{(new d3.hex(hsl)).b}"
  window.hslToHslHtml = (hsl) -> "hsl(<b>#{~~hsl.h}</b>, <b>#{(hsl.s * 100).toFixed(0)}</b>%, <b>#{(hsl.l * 100).toFixed(0)}</b>%)"
  window.hslToHslText = (hsl) -> "hsl(#{~~hsl.h}, #{(hsl.s * 100).toFixed(0)}%, #{(hsl.l * 100).toFixed(0)}%)"
  window.hslToHclHtml = (hsl) -> "hcl(<b>#{~~((new d3.hcl(hsl)).h + 360) % 360}</b>, <b>#{(new d3.hcl(hsl)).c.toFixed(0)}</b>%, <b>#{(new d3.hcl(hsl)).l.toFixed(0)}</b>%)"
  window.hslToHclText = (hsl) -> "hcl(#{~~((new d3.hcl(hsl)).h + 360) % 360}, #{(new d3.hcl(hsl)).c.toFixed(0)}%, #{(new d3.hcl(hsl)).l.toFixed(0)}%)"
  window.hslToRgbHtml = (hsl) -> "rgb(<b>#{(new d3.rgb(hsl)).r}</b>, <b>#{(new d3.rgb(hsl)).g}</b>, <b>#{(new d3.rgb(hsl)).b}</b>)"
  window.hslToRgbText = (hsl) -> "rgb(#{(new d3.rgb(hsl)).r}, #{(new d3.rgb(hsl)).g}, #{(new d3.rgb(hsl)).b})"
  window.hslToLabHtml = (hsl) -> "lab(<b>#{(new d3.lab(hsl)).l.toFixed(0)}</b>, <b>#{(new d3.lab(hsl)).a.toFixed(0)}</b>, <b>#{(new d3.lab(hsl)).b.toFixed(0)}</b>)"
  window.hslToLabText = (hsl) -> "lab(#{(new d3.lab(hsl)).l.toFixed(0)}, #{(new d3.lab(hsl)).a.toFixed(0)}, #{(new d3.lab(hsl)).b.toFixed(0)})"

  applySettings = (_settings) ->
    $.extend(settings, _settings)
    return

  draw = (index = settings[settings.mode].edit, mode = settings.mode) ->
    settings[mode].colors[index].h = Math.max(0, Math.min(360, settings[mode].colors[index].h))
    settings[mode].colors[index].s = Math.max(0, Math.min(1, settings[mode].colors[index].s))
    settings[mode].colors[index].l = Math.max(0, Math.min(1, settings[mode].colors[index].l))
    hsl = settings[mode].colors[index]
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .hex").html hslToHexHtml(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .rgb").html hslToRgbHtml(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .hsl").html hslToHslHtml(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .hcl").html hslToHclHtml(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .lab").html hslToLabHtml(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1})").css 'background-color', hslToHexText(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .info > span").css 'background-color', hslToHexText(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1})").css 'color', hslToIhxText(hsl)
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .save a").css 'color', hslToIhxText(hsl)
    strColor = ''
    if settings.mode is 'code'
      strColor = hslToHexText(hsl)
      colors = (hslToHexText color for color in settings[settings.mode].colors)
      colors.pop() if settings[settings.mode].locked is false
      if colors.length > 0
        $('footer .links .save').show()
        strColors = colors.join(',')
        $("footer .links .save.less").attr 'href', "http://api.colourco.de/export/less/#{encodeURIComponent(strColors)}"
        $("footer .links .save.image").attr 'href', "http://api.colourco.de/export/png/#{encodeURIComponent(strColors)}"
      else
        $('footer .links .save').hide()
    else
      colors = (hslToHexText color for color in settings[settings.mode].colors)
      strColor = colors.join(',')
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .save a:nth-child(2)").attr 'href', "http://api.colourco.de/export/less/#{encodeURIComponent(strColor)}"
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .save a:nth-child(3)").attr 'href', "http://api.colourco.de/export/png/#{encodeURIComponent(strColor)}"

    if settings[mode].colors.length > 5
      $("section.#{mode} > .colors > div").css("box-shadow","0 -1px 0 hsl(0, 0%, 60%) inset, 0 1px 0 hsl(0, 0%, 60%) inset")
    else
      $("section.#{mode} > .colors > div").css("box-shadow", "")
    if settings[mode].locked is false and index is settings[mode].edit
      colorClass = $('header .convert input[type=radio]:checked').val()
      $('header input[type=text]').val(window["hslTo#{colorClass}Text"](hsl))
      $("section.#{mode} .locked").removeClass('locked')
    else if settings[mode].locked is true
      $("section.#{mode} > .colors > .color").addClass('locked')
    return

  hoverColor = (e, mode = settings.mode) ->
    if settings[mode].locked is false
      maxX = $('.color').width() * 0.99
      maxY = $('.color').height() * 0.99
      x = e.pageX - 2 - settings[mode].edit * maxX
      y = e.pageY - $('header').height() - 2
      settings[mode].colors[settings[mode].edit] = new d3.hsl ~~(x / maxX * 360), settings[mode].colors[settings[mode].edit].s, ~~(y / maxY * 100) / 100
      draw()
    return

  setColorWidths = (offset = 0, mode = settings.mode) ->
    $("section.#{mode} > .colors > div").css 'width', (100 / (settings[mode].colors.length + offset)) + '%'
    $("section.#{mode} > .colors > div > div").css 'width', (100 / (settings[mode].colors.length + offset)) + '%'

  setColors = (mode = settings.mode) ->
    if mode is 'scheme'
      h = settings.scheme.colors[2].h
      s = settings.scheme.colors[2].s
      l = settings.scheme.colors[2].l
      switch settings.scheme.mode
        when 'mono'
          settings.scheme.colors[0] = new d3.hsl h,s * 0.8, l * (1 - 0.2 * settings.scheme.contrast)
          settings.scheme.colors[1] = new d3.hsl h,s * 0.9, l * (1 - 0.1 * settings.scheme.contrast)
          settings.scheme.colors[3] = new d3.hsl h,s * 1.1, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl h,s * 1.2, l * (1 + 0.2 * settings.scheme.contrast)
        when 'mono-d'
          settings.scheme.colors[0] = new d3.hsl h,0, l * (1 - 0.2 * settings.scheme.contrast)
          settings.scheme.colors[1] = new d3.hsl h,0, l * (1 - 0.1 * settings.scheme.contrast)
          settings.scheme.colors[3] = new d3.hsl h,s * 1.1, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl h,s * 1.2, l * (1 + 0.2 * settings.scheme.contrast)
        when 'mono-l'
          settings.scheme.colors[0] = new d3.hsl h,s * 0.8, l * (1 - 0.2 * settings.scheme.contrast)
          settings.scheme.colors[1] = new d3.hsl h,s * 0.9, l * (1 - 0.1 * settings.scheme.contrast)
          settings.scheme.colors[3] = new d3.hsl h,0, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl h,0, l * (1 + 0.2 * settings.scheme.contrast)
        when 'comp'
          settings.scheme.colors[0] = new d3.hsl (h + 180) % 360,s * 0.8, l * (1 - 0.1 * settings.scheme.contrast)
          settings.scheme.colors[1] = new d3.hsl (h + 180) % 360,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[3] = new d3.hsl h,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl h,s * 0.8, l * (1 - 0.1 * settings.scheme.contrast)
        when 'tri'
          settings.scheme.colors[0] = new d3.hsl (h + 160 - 10 * settings.scheme.contrast) % 360,s, l
          settings.scheme.colors[1] = new d3.hsl (h + 200 + 10 * settings.scheme.contrast) % 360,s, l
          settings.scheme.colors[3] = new d3.hsl h,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl h,s * 0.8, l * (1 - 0.1 * settings.scheme.contrast)
        when 'quad'
          settings.scheme.colors[0] = new d3.hsl (h + 180) % 360,s, l
          settings.scheme.colors[1] = new d3.hsl (h + 220 + 10 * settings.scheme.contrast) % 360,s, l
          settings.scheme.colors[3] = new d3.hsl h,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl (h + 40 + 10 * settings.scheme.contrast) % 360,s, l
        when 'ana'
          settings.scheme.colors[0] = new d3.hsl (h + 360 - 30 * settings.scheme.contrast) % 360, s, l * 1.1
          settings.scheme.colors[1] = new d3.hsl (h + 360 - 15 * settings.scheme.contrast) % 360, s, l
          settings.scheme.colors[3] = new d3.hsl (h + 15 * settings.scheme.contrast) % 360, s, l
          settings.scheme.colors[4] = new d3.hsl (h + 30 * settings.scheme.contrast) % 360, s, l * 1.1
        when 'ana-c'
          settings.scheme.colors[0] = new d3.hsl (h + 180) % 360,s * 0.8, l * (1 - 0.1 * settings.scheme.contrast)
          settings.scheme.colors[1] = new d3.hsl (h + 180) % 360,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[3] = new d3.hsl (h + 330) % 360,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
          settings.scheme.colors[4] = new d3.hsl (h + 30) % 360,s * 1.2, l * (1 + 0.1 * settings.scheme.contrast)
    for color, index in settings[mode].colors
      draw index, mode


  getColorIndex = (node, mode = settings.mode) ->
    $colors = $("section.#{mode} > .colors > div")
    for color, index in $colors
      return index if color is node
    -1

  removeColor = () ->
    $root = $(this).parent().parent().parent().parent()
    index = getColorIndex($root[0])
    if index >= 0
      $root.children().css 'opacity', '0'
      setColorWidths(-1)
      $root.css 'width', '0%'
      setTimeout(() ->
        settings[settings.mode].colors.splice(index,1)
        settings[settings.mode].edit-- if settings[settings.mode].edit > index
        if settings[settings.mode].colors.length > 5
          $("section.#{settings.mode} > .colors > div").css("box-shadow","0 -1px 0 hsl(0, 0%, 60%) inset, 0 1px 0 hsl(0, 0%, 60%) inset")
        else
          $("section.#{settings.mode} > .colors > div").css("box-shadow", "")
        $root.remove()
        return
      , 500)
    return

  swapColor = (node, count, mode = settings.mode) ->
    $root = $(node).parent().parent().parent().parent()
    index = getColorIndex($root[0])
    if index >= 0 and index + count >= 0 and index + count < settings[mode].colors.length
      tmp = settings[mode].colors[index]
      settings[mode].colors[index] = settings[mode].colors[index + count]
      settings[mode].colors[index + count] = tmp
      setColors()
    return

  wheelEvent = (e) ->
    mode = settings.mode
    if settings[mode].locked is false
      delta = if (e.wheelDelta || e.detail || e.originalEvent.wheelDelta || e.originalEvent.detail) > 0 then 1 else -1
      if mode is 'code'
        color = settings[mode].colors[settings[mode].edit]
        settings[mode].colors[settings[mode].edit] = new d3.hsl color.h, Math.max(0, Math.min(1, color.s + delta * .05)), color.l
        draw()
      else if mode is 'scheme'
        settings.scheme.contrast = Math.min(3, Math.max(1, settings.scheme.contrast + delta * 0.1))
        setColors()
    return

  $('body').bind "mousewheel", wheelEvent
  $('body').bind "DOMMouseScroll", wheelEvent

  $('header .convert input[type=radio]').change () ->
    colorClass = $('header .convert input[type=radio]:checked').val()
    $('header input[type=text]').val(window["hslTo#{colorClass}Text"](settings[settings.mode].colors[settings[settings.mode].edit]))
    return

  $('header .logo input[type=radio]').change () ->
    tmpMode = $('header .logo input[type=radio]:checked').val()
    if tmpMode isnt settings.mode
      $('body > div').removeClass(settings.mode)
      settings.mode = $('header .logo input[type=radio]:checked').val()
      $('body > div').addClass(settings.mode)
      if settings.mode is 'code'
        $('footer .links .save').show()
        $('header .mode input[type=radio]:checked').attr('checked', null)
      else if settings.mode is 'scheme'
        $('footer .links .save').hide()
        $("header .mode #scheme-#{settings.scheme.mode}").click()
      $('header .logo a.long').html "colour#{settings.mode}"
      $('section.hide').removeClass('hide')
      $('section.show').addClass('hide').removeClass('show')
      $("section.#{settings.mode}").addClass('show')
      $('section.firstrun').removeClass('firstrun')
    return

  $('header .mode input[type=radio]').change () ->
    settings.scheme.mode = $('header .mode input[type=radio]:checked').val()
    if $('header .logo input[type=radio]:checked').val() isnt 'scheme'
      $('header .logo #mode-scheme').click()
    setColors()
    return

  $('header input').keyup () ->
    if settings[settings.mode].edit >= 0 and settings[settings.mode].edit < settings[settings.mode].colors.length
      settings[settings.mode].colors[settings[settings.mode].edit] = new d3.hsl $(this).val()
      settings[settings.mode].locked = true
      if settings.mode is 'code'
        draw()
      else if settings.mode is 'scheme'
        setColors()
    return

  addColor = (e, mode = settings.mode) ->
    $("section.#{mode} > .colors > .color").removeClass('color').unbind()
    $("section.#{mode} > .colors > div:nth-child(#{settings[mode].edit + 1}) .ctl > b:nth-child(2)").click removeColor
    $("section.#{mode} > .colors > div:nth-child(#{settings[mode].edit + 1}) .ctl > b:nth-child(1)").click () ->
      swapColor this, -1
      return
    $("section.#{mode} > .colors > div:nth-child(#{settings[mode].edit + 1}) .ctl > b:nth-child(3)").click () ->
      swapColor this, 1
      return

    settings[mode].colors.push new d3.hsl(~~(Math.random() * 360), 0.5, if mode is 'code' then 0.8 else 0.5)
    settings[mode].edit = settings[mode].colors.length - 1
    $newColor = $ "<div class='color'>
        <div class='top'>
        </div>
        <div class='center'>
          <div class='info'>
            <span class='hex'/><br/>
            <span class='rgb'/><br/>
            <span class='hsl'/><br/>
            <span class='hcl'/><br/>
            <span class='lab'/><br/>
            <span class='ctl'><b>1</b><b>2</b><b>3</b></span>
            <b>a</b>
          </div>
        </div>
        <div class='bottom'>
          <span class='save'><a>y</a><a>z</a><a>A</a></span>
        </div>
      </div>"
    $("section.#{mode} > .colors").append $newColor
    setColorWidths(0, mode)
    $newColor.mousemove hoverColor
    $newColor.find(".save > a").click (args) ->
      downloadURL $(@).attr 'href'
      return false

    $newColor.find('.info > b').click (e) ->
      settings[mode].locked = false;
      draw()
      return false
    $newColor.find('.info > b').mouseenter () ->
      $(this).html 'b'
      return
    $newColor.find('.info > b').mouseleave () ->
      $(this).html 'a'
      return
    $newColor.click () ->
      addColor()
      return
    $newColor.bind 'contextmenu', () ->
      settings[mode].locked = not settings[mode].locked
      draw()
      return false
    settings[mode].locked = false
    draw(settings[mode].edit, mode)
    return

  showBack = (elemClass, mode = settings.mode) ->
    $('.flipper > .back').css 'visibility', 'visible'
    $('.flip-modal > div').hide()
    $(".flip-modal > .#{elemClass}.#{mode}, .flip-modal > .right").show()
    settings[mode].locked = true
    draw()
    $('.flipper').addClass('hover')
    return

  $('footer .legal').click () ->
    showBack 'legal'
    return

  $('footer .help').click () ->
    showBack 'help'
    return

  $('.flipper > .back button').click () ->
    $('.flipper').removeClass('hover')
    return

  $(window).keydown (e) ->
    if e.ctrlKey
      e.preventDefault() if (e.which >= 48 and e.which <= 57) or (e.which >= 37 and e.which <= 40)
      $('body > div').addClass('show-shortcuts') if e.which is 17
      $('body > div').addClass('shift') if e.which is 16
      switch e.which
        when 48 then $('label[for=mode-code]'    ).click() #0
        when 49 then $('label[for=scheme-mono]'  ).click() #1
        when 50 then $('label[for=scheme-mono-d]').click() #2
        when 51 then $('label[for=scheme-mono-l]').click() #3
        when 52 then $('label[for=scheme-ana]'   ).click() #4
        when 53 then $('label[for=scheme-comp]'  ).click() #5
        when 54 then $('label[for=scheme-ana-c]' ).click() #6
        when 55 then $('label[for=scheme-tri]'   ).click() #7
        when 56 then $('label[for=scheme-quad]'  ).click() #8
        when 37, 38, 39, 40
          if settings[settings.mode].edit >= 0 and settings[settings.mode].edit < settings[settings.mode].colors.length
            settings[settings.mode].locked = true
            switch e.which
              when 37 #<
                settings[settings.mode].colors[settings[settings.mode].edit].h = (settings[settings.mode].colors[settings[settings.mode].edit].h + 360 - 1) % 360
              when 39 #>
                settings[settings.mode].colors[settings[settings.mode].edit].h = (settings[settings.mode].colors[settings[settings.mode].edit].h + 360 + 1) % 360
              when 38, 40
                if e.shiftKey
                  if settings.mode is 'code'
                    if e.which is 38 #^
                      settings.code.colors[settings.code.edit].s += 0.01
                    else             #v
                      settings.code.colors[settings.code.edit].s -= 0.01
                  else
                    if e.which is 38 #^
                      settings.scheme.contrast = Math.min(3, Math.max(1, settings.scheme.contrast + 0.1))
                    else             #v
                      settings.scheme.contrast = Math.min(3, Math.max(1, settings.scheme.contrast - 0.1))
                else
                  if e.which is 38 #^
                    settings[settings.mode].colors[settings[settings.mode].edit].l += 0.01
                  else             #v
                    settings[settings.mode].colors[settings[settings.mode].edit].l -= 0.01
            setColors()
    return #false

  $(window).keyup (e) ->
    e.preventDefault()
    $('body > div').removeClass('show-shortcuts')
    $('body > div').removeClass('shift')
    return false

  init = () ->
    addColor()
    addColor(null, 'scheme')
    addColor(null, 'scheme')
    addColor(null, 'scheme')
    addColor(null, 'scheme')
    addColor(null, 'scheme')
    settings.scheme.edit = 2
    $('header .mode input[type=radio]:checked').attr('checked', null)
    $('header .logo input[type=radio]:checked').attr('checked', null)
    $('header .logo #mode-code').click()
    $('section.scheme .color').removeClass('color')
    $('section.scheme > .colors > div:nth-child(3)').addClass('color')
    $("section.scheme > .colors > div").unbind()
    setColors('scheme')
    $('section.scheme').click () ->
      settings.scheme.locked = true
      draw()
      return false
    $('section.scheme').mousemove (e) ->
      if settings.scheme.locked is false
        maxX = $('section.scheme').width() * 0.99
        maxY = $('section.scheme').height() * 0.99
        x = e.pageX
        y = e.pageY - $('header').height() - 2
        settings.scheme.colors[2] = new d3.hsl ~~(x / maxX * 360), 0.5, (~~(y / maxY * 100) / 100 + 0.15) * 0.7
        setColors()
      return

  init()