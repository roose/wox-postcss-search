import os, strutils, httpclient, json, browsers
import wox

proc query(wp: Wox, params: varargs[string]) =
  let
    query = params[0].strip
    name = "plugins"
    ico = "Images\\postcss.png"
    url = "https://raw.githubusercontent.com/himynameisdave/postcss-plugins/master/plugins.json"

  if isCacheOld("plugins",7*24*60*60):
  # is cache old - download plugins list
    let
      content = getContent(url)
      data = parseJson(content)
    wp.saveCache(name, data)
    # save plugins list to cache file

  let plugins = wp.loadCache(name)
  # load plugins list from cache file
  for plugin in plugins:
    let
      title = plugin["name"].getStr
      desc = plugin["description"].getStr
      url = plugin["url"].getStr
    wp.add(title, desc, ico, "openUrl", url, false)
    # add plugin to results
  wp.sort(query, minScore = 10.0, sortBy = byTitleSub)

  if wp.data.result.len == 0:
    wp.add("No Results", "", ico, "", "", true)

  echo wp.results()

proc openUrl(wp: Wox, params: varargs[string]) =
  let url = params[0].strip
  openDefaultBrowser(url)

when isMainModule:
  var wp = newWox()
  # register `query` and `openUrl` for call from Wox
  wp.register("query", query)
  wp.register("openUrl", openUrl)
  # run called proc
  wp.run()