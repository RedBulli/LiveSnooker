mocha.globals.importElement = (filepath, callback) ->
  link = document.createElement("link")
  link.rel = "import"
  link.href = filepath
  link.onload = -> callback()
  document.getElementsByTagName("head")[0].appendChild(link)
