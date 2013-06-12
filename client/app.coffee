converter =
  bounds:
    rgb:
      r: {min: 0, max: 1}         # r ∊ [0, 1]    red
      g: {min: 0, max: 1}         # g ∊ [0, 1]    green
      b: {min: 0, max: 1}         # b ∊ [0, 1]    blue
    hsl:
      h: {min: 0, max: 1}         # h ∊ [0, 1[    hue
      s: {min: 0, max: 1}         # s ∊ [0, 1]    saturation
      l: {min: 0, max: 1}         # l ∊ [0, 1]    lightness
    hsv:
      h: {min: 0, max: 1}         # h ∊ [0, 1[    hue
      s: {min: 0, max: 1}         # s ∊ [0, 1]    saturation
      v: {min: 0, max: 1}         # v ∊ [0, 1]    value
    cmy:
      c: {min: 0, max: 1}         # c ∊ [0, 1[    cyan
      m: {min: 0, max: 1}         # m ∊ [0, 1]    magenta
      y: {min: 0, max: 1}         # y ∊ [0, 1]    yellow
    cmyk:
      c: {min: 0, max: 1}         # c ∊ [0, 1[    cyan
      m: {min: 0, max: 1}         # m ∊ [0, 1]    magenta
      y: {min: 0, max: 1}         # y ∊ [0, 1]    yellow
      k: {min: 0, max: 1}         # k ∊ [0, 1]    key
    XYZ:
      X: {min: 0, max: 0.95047}   # X ∊ [0, 0.95047]
      Y: {min: 0, max: 1.00000}   # Y ∊ [0, 1.00000]
      Z: {min: 0, max: 1.08883}   # Z ∊ [0, 1.08883]
    Yxy:
      Y: {min: 0, max: 1}         # Y ∊ [0, 1]
      x: {min: 0, max: 1}         # x ∊ [0, 1]
      y: {min: 0, max: 1}         # y ∊ [0, 1]
    lab:
      l: {min: -999, max: 999}    # l ∊ [?, ?]
      a: {min: -999, max: 999}    # a ∊ [?, ?]
      b: {min: -999, max: 999}    # b ∊ [?, ?]
    validate: (type, values) ->
      result = {}
      for key, bounds of converter.bounds[type]
        result[key] = Math.max(bounds.min, Math.min(bounds.max, values[key]))
      result

  # ----------------- #
  # -- rgb <-> rgb -- #
  # ----------------- #
  #rgb -> rgb
  "rgb-to-rgb": (values) -> converter.bounds.validate "rgb", values # validate

  # ----------------- #
  # -- hsl <-> rgb -- #
  # ----------------- #
  #hsl -> rgb
  "hsl-to-rgb": (values) -> # see: http://en.wikipedia.org/wiki/HSV_color_space
    # validate input
    values.h = values.h % 1
    hsl = converter.bounds.validate "hsl", values
    # logic
    H = hsl.h * 6.0                           # H ∊ [0, 6[    hue * 6
    C = (1 - Math.abs(2 * hsl.l - 1)) * hsl.s # C ∊ [0, 1]    chroma
    X = C * (1 - Math.abs(H % 2 - 1))         # X ∊ [0, 1]    intermediate
    r = g = b = 0
    r = C if (0 <= H < 1) or (5 <= H < 6)
    r = X if (1 <= H < 2) or (4 <= H < 5)
    g = C if (1 <= H < 3)
    g = X if (0 <= H < 1) or (3 <= H < 4)
    b = C if (3 <= H < 5)
    b = X if (2 <= H < 3) or (5 <= H < 6)
    m = hsl.l - 0.5 * C # match lightness
    # validate output
    converter.bounds.validate "rgb", {r: r + m, g: g + m, b: b + m}

  #rgb -> hsl
  "rgb-to-hsl": (values) -> # see: http://easyrgb.com/index.php?X=MATH&H=18#text18
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    a = Math.min(rgb.r, rgb.g, rgb.b) # a ∊ [0, 1]    min value
    z = Math.max(rgb.r, rgb.g, rgb.b) # z ∊ [0, 1]    max value
    d = (z - a)                       # d ∊ [0, 1]    delta value
    l = (z + a) / 2                   # l ∊ [0, 1]    lightness
    h = s = 0
    if d > 0 # color isn't gray
      s = d / if l < 0.5 then z + a else 2 - z - a # saturation
      d2 = d / 2 # delta half
      dr = (((z - rgb.r) / 6) + d2) / d # delta red
      dg = (((z - rgb.g) / 6) + d2) / d # delta green
      db = (((z - rgb.b) / 6) + d2) / d # delta blue
      if      rgb.r is z then h = (0 / 3) + db - dg
      else if rgb.g is z then h = (1 / 3) + dr - db
      else if rgb.b is z then h = (2 / 3) + dg - dr
      h += 1 if h < 0
      h -= 1 if h >= 1
    # validate output
    converter.bounds.validate "hsl", {h: h, s: s, l: l}

  # ----------------- #
  # -- hsv <-> rgb -- #
  # ----------------- #
  #hsv -> rgb
  "hsv-to-rgb": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=21#text21
    # validate input
    values.h = values.h % 1
    hsv = converter.bounds.validate "hsv", values
    # logic
    r = g = b = hsv.v
    if hsv.s > 0
      H = hsv.h * 6
      v1 = hsv.v * (1 - hsv.s)
      v2 = hsv.v * (1 - hsv.s * (H - vi))
      v3 = hsv.v * (1 - hsv.s * (1 - (H - vi)))

      r = hsv.v if (0 <= H < 1) or (5 <= H < 6)
      r = v1    if (2 <= H < 4)
      r = v2    if (1 <= H < 2)
      r = v3    if (4 <= H < 5)
      g = hsv.v if (1 <= H < 3)
      g = v1    if (4 <= H < 6)
      g = v2    if (3 <= H < 4)
      g = v3    if (0 <= H < 1)
      b = hsv.v if (3 <= H < 5)
      b = v1    if (0 <= H < 2)
      b = v2    if (5 <= H < 6)
      b = v3    if (2 <= H < 3)
    # validate output
    converter.bounds.validate "rgb", {r: r, g: g, b: b}

  #rgb -> hsv
  "rgb-to-hsv": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=20#text20
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    a = Math.min(rgb.r, rgb.g, rgb.b) # a ∊ [0, 1]    min value
    z = Math.max(rgb.r, rgb.g, rgb.b) # z ∊ [0, 1]    max value
    d = (z - a)                       # d ∊ [0, 1]    delta value

    v = z
    h = s = 0
    if d > 0 # color isn't gray
      s = d / z # saturation
      d2 = d / 2 # delta half
      dr = (((z - rgb.r) / 6) + d2) / d # delta red
      dg = (((z - rgb.g) / 6) + d2) / d # delta green
      db = (((z - rgb.b) / 6) + d2) / d # delta blue
      if      rgb.r is z then h = (0 / 3) + db - dg
      else if rgb.g is z then h = (1 / 3) + dr - db
      else if rgb.b is z then h = (2 / 3) + dg - dr
      h += 1 if h < 0
      h -= 1 if h >= 1
    # validate output
    converter.bounds.validate "hsv", {h: h, s: s, v: v}

  # ----------------- #
  # -- cmy <-> rgb -- #
  # ----------------- #
  #cmy -> rgb
  "cmy-to-rgb": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=12#text12
    # validate input
    cmy = converter.bounds.validate "cmy", values
    # logic
    r = 1 - cmy.c
    g = 1 - cmy.m
    b = 1 - cmy.y
    # validate output
    converter.bounds.validate "rgb", {r: r, g: g, b: b}

  #rgb -> cmy
  "rgb-to-cmy": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=11#text11
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    y = 1 - rgb.r
    m = 1 - rgb.g
    c = 1 - rgb.b
    # validate output
    converter.bounds.validate "cmy", {c: c, m: m, y: y}

  # ------------------ #
  # -- cmyk <-> rgb -- #
  # ------------------ #
  #cmyk -> rgb
  "cmyk-to-rgb": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=21#text21
    # validate input
    cmyk = converter.bounds.validate "cmyk", values
    # logic
    c = (cmyk.c * (1 - cmyk.k) + cmyk.k)
    m = (cmyk.m * (1 - cmyk.k) + cmyk.k)
    y = (cmyk.y * (1 - cmyk.k) + cmyk.k)
    # validate output
    converter["cmy-to-rgb"] {c: c, m: m, y: y}

  #rgb -> cmyk
  "rgb-to-cmyk": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=13#text13
    # validate input
    cmy = converter["rgb-to-cmy"] values
    # logic
    k = 1
    k = c if c < k
    k = m if m < k
    k = y if y < k

    c = 0 if k is 1 # black
    m = 0 if k is 1 # black
    y = 0 if k is 1 # black

    c = (c - k) / (1 - k) if k > 0
    m = (m - k) / (1 - k) if k > 0
    y = (y - k) / (1 - k) if k > 0
    # validate output
    converter.bounds.validate "cmyk", {c: c, m: m, y: y, k: k}

  # ----------------- #
  # -- XYZ <-> rgb -- #
  # ----------------- #
  #XYZ -> rgb
  "XYZ-to-rgb": (values) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=14#text14
    XYZ = converter.bounds.validate "XYZ", values
    # logic
    r = XYZ.X *  3.2406 + XYZ.Y * -1.5372 + XYZ.Z * -0.4986
    g = XYZ.X * -0.9689 + XYZ.Y *  1.8758 + XYZ.Z *  0.0415
    b = XYZ.X *  0.0557 + XYZ.Y * -0.2040 + XYZ.Z *  1.0570

    r = if r > 0.0031308 then 1.055 * ( r ^ ( 1 / 2.4 ) ) - 0.055 else 12.92 * r
    g = if g > 0.0031308 then 1.055 * ( g ^ ( 1 / 2.4 ) ) - 0.055 else 12.92 * g
    b = if b > 0.0031308 then 1.055 * ( b ^ ( 1 / 2.4 ) ) - 0.055 else 12.92 * b
    # validate output
    converter.bounds.validate "rgb", {r: r, g: g, b: b}

  #rgb -> XYZ
  "rgb-to-XYZ": (values) -> # see: http://easyrgb.com/index.php?X=MATH&H=02#text2
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    r = if rgb.r > 0.04045 then ((rgb.r + 0.055) / 1.055) ^ 2.4 else rgb.r / 12.92
    g = if rgb.g > 0.04045 then ((rgb.g + 0.055) / 1.055) ^ 2.4 else rgb.g / 12.92
    b = if rgb.b > 0.04045 then ((rgb.b + 0.055) / 1.055) ^ 2.4 else rgb.b / 12.92

    X = rgb.r * 0.4124 + rgb.g * 0.3576 + rgb.b * 0.1805
    Y = rgb.r * 0.2126 + rgb.g * 0.7152 + rgb.b * 0.0722
    Z = rgb.r * 0.0193 + rgb.g * 0.1192 + rgb.b * 0.9505
    # validate output
    converter.bounds.validate "XYZ", {X: X, Y: Y, Z: Z}

  # ----------------- #
  # -- Yxy <-> rgb -- #
  # ----------------- #
  #Yxy -> rgb
  "Yxy-to-rgb": (values) -> # see: http://easyrgb.com/index.php?X=MATH&H=04#text4
    # validate input
    Yxy = converter.bounds.validate "Yxy", values
    # logic
    X = Yxy.x * ( Yxy.Y / Yxy.y )
    Y = Yxy.Y
    Z = ( 1 - Yxy.x - Yxy.y ) * ( Yxy.Y / Yxy.y )
    # validate output
    converter["XYZ-to-rgb"] {X: X, Y: Y, Z: Z}

  #rgb -> Yxy
  "rgb-to-Yxy": (values) -> # see: http://easyrgb.com/index.php?X=MATH&H=03#text3
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    XYZ = converter["rgb-to-XYZ"] rgb
    x = y = 1
    if not (XYZ.X is XYZ.Y is XYZ.Z is 0)
      x = X / ( XYZ.X + XYZ.Y + XYZ.Z )
      y = Y / ( XYZ.X + XYZ.Y + XYZ.Z )
    # validate output
    converter.bounds.validate "Yxy", {Y: Y, x: x, y: y}

  # ----------------- #
  # -- lab <-> rgb -- #
  # ----------------- #
  #lab -> rgb
  "lab-to-rgb": (values) -> # see: http://easyrgb.com/index.php?X=MATH&H=08#text8
    # validate input
    lab = converter.bounds.validate "lab", values
    # logic
    Y = (lab.l + 16 ) / 116
    X = lab.a / 500 + Y
    Z = Y - lab.b / 200

    X = if X^3 > 0.008856 then X^3 else ( X - 16 / 116 ) / 7.787
    Z = if Z^3 > 0.008856 then Z^3 else ( Z - 16 / 116 ) / 7.787
    Y = if Y^3 > 0.008856 then Y^3 else ( Y - 16 / 116 ) / 7.787

    X *= converter.bounds.XYZ.X
    Y *= converter.bounds.XYZ.Y
    Z *= converter.bounds.XYZ.Z
    # validate output
    converter["XYZ-to-rgb"] {X: X, Y: Y, Z: Z}

  #rgb -> lab
  "rgb-to-lab": (r, g, b) -> # see: http://www.easyrgb.com/index.php?X=MATH&H=07#text7
    # validate input
    rgb = converter.bounds.validate "rgb", values
    # logic
    XYZ = converter["rgb-to-XYZ"] values
    X = XYZ.X / converter.bounds.XYZ.X
    Y = XYZ.Y / converter.bounds.XYZ.Y
    Z = XYZ.Z / converter.bounds.XYZ.Z

    X = if X > 0.008856 then X ^ ( 1 / 3 ) else ( 7.787 * X ) + ( 16 / 116 )
    Y = if Y > 0.008856 then Y ^ ( 1 / 3 ) else ( 7.787 * Y ) + ( 16 / 116 )
    Z = if Z > 0.008856 then Z ^ ( 1 / 3 ) else ( 7.787 * Z ) + ( 16 / 116 )

    l = ( 116 * Y ) - 16
    a = 500 * ( X - Y )
    b = 200 * ( Y - Z )
    # validate output
    converter.bounds.validate "lab", {l: l, a: a, b: b}

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
      activatedNew: true

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
    $(".front > .icon").css 'color', hslToIhxText(hsl) if index is 0
    strColor = ''
    if settings.mode is 'code'
      strColor = hslToHexText(hsl)
      colors = (hslToHexText color for color in settings[settings.mode].colors)
      colors.pop() if settings[settings.mode].locked is false
      if colors.length > 0
        $('.front > .icon.save').show()
        strColors = colors.join(',')
        $(".front > .icon.save.less").attr 'href', "http://api.colourco.de/export/less/#{encodeURIComponent(strColors)}"
        $(".front > .icon.save.image").attr 'href', "http://api.colourco.de/export/png/#{encodeURIComponent(strColors)}"
      else
        $('.front > .icon.save').hide()
    else
      colors = (hslToHexText color for color in settings[settings.mode].colors)
      strColor = colors.join(',')
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .save a:nth-child(2)").attr 'href', "http://api.colourco.de/export/less/#{encodeURIComponent(strColor)}"
    $("section.#{mode} > .colors > div:nth-child(#{index + 1}) .save a:nth-child(3)").attr 'href', "http://api.colourco.de/export/png/#{encodeURIComponent(strColor)}"
    if settings[mode].locked is false and index is settings[mode].edit
      colorClass = $('nav .convert input[type=radio]:checked').val()
      $('nav input[type=text]').val(window["hslTo#{colorClass}Text"](hsl))
      $("section.#{mode} .locked").removeClass('locked')
    else if settings[mode].locked is true
      $("section.#{mode} > .colors > .color").addClass('locked')
    return

  hoverColor = (e, mode = settings.mode) ->
    if settings[mode].locked is false
      maxX = $('.color').width() * 0.99
      maxY = $('.color').height() * 0.99
      x = e.pageX - 2 - settings[mode].edit * maxX
      y = e.pageY
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
        setColors()
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

  $('nav .convert input[type=radio]').change () ->
    colorClass = $('nav .convert input[type=radio]:checked').val()
    $(".flipper").removeClass("hex").removeClass("rgb").removeClass("hsl")
    $(".flipper").addClass(colorClass.toLowerCase())
    $('nav input[type=text]').val(window["hslTo#{colorClass}Text"](settings[settings.mode].colors[settings[settings.mode].edit]))
    return

  $('nav .logo input[type=radio]').change () ->
    tmpMode = $('nav .logo input[type=radio]:checked').val()
    if tmpMode isnt settings.mode
      $('body > div').removeClass(settings.mode)
      settings.mode = $('nav .logo input[type=radio]:checked').val()
      $('body > div').addClass(settings.mode)
      if settings.mode is 'code'
        $('.front > .icon.save').show()
        $('nav .mode input[type=radio]:checked').attr('checked', null)
      else if settings.mode is 'scheme'
        $('.front > .icon.save').hide()
        $("nav .mode #scheme-#{settings.scheme.mode}").click()
      $('nav .logo a.long').html "colour#{settings.mode}"
      $('section.hide').removeClass('hide')
      $('section.show').addClass('hide').removeClass('show')
      $("section.#{settings.mode}").addClass('show')
      $('section.firstrun').removeClass('firstrun')
    return

  $('nav .mode input[type=radio]').change () ->
    settings.scheme.mode = $('nav .mode input[type=radio]:checked').val()
    if $('nav .logo input[type=radio]:checked').val() isnt 'scheme'
      $('nav .logo #mode-scheme').click()
    setColors()
    return

  $('nav input').keyup () ->
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
    $newColor = $ """
      <div class="color">
        <div class="top">
        </div>
        <div class="center">
          <div class="info">
            <div class="colorcodes">
              <span class="hex"/><br/>
              <span class="rgb"/><br/>
              <span class="hsl"/><br/>
              <span class="hcl"/><br/>
              <span class="lab"/><br/>
            </div>
            <span class="ctl"><b>1</b><b>2</b><b>3</b></span>
            <b>a</b>
          </div>
        </div>
        <div class="bottom">
          <span class="save"><a>y</a><a>z</a><a>A</a></span>
        </div>
      </div>"
    """
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
    $(".flipper, nav + span.icon").removeClass("menu")
    return

  $('nav .legal').click () ->
    showBack 'legal'
    return

  $('nav .help').click () ->
    showBack 'help'
    return

  $('.flipper > .back button').click () ->
    $('.flipper').removeClass('hover')
    return

  $("nav + span.icon").click () ->
    $(".flipper, nav + span.icon").addClass("menu")

  $("nav").mouseleave () ->
    $(".flipper, nav + span.icon").removeClass("menu")

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
    $('nav .mode input[type=radio]:checked').attr('checked', null)
    $('nav .logo input[type=radio]:checked').attr('checked', null)
    $('nav .logo #mode-code').click()
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
        y = e.pageY
        settings.scheme.colors[2] = new d3.hsl ~~(x / maxX * 360), 0.5, (~~(y / maxY * 100) / 100 + 0.15) * 0.7
        setColors()
      return
    setColors()

  init()

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