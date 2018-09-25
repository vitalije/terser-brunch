Terser = require('terser')
formatError = (error) ->
    err = new Error("L#{error.line}:#{error.col} #{error.message}")
    err.name = ''
    err.stack = error.stack
    err

TerserOptimizer = (config) ->
  @options = Object.assign {}, config.plugins.terser
  @options.fromString = true
  @options.sourceMaps = !!config.sourceMaps
  @optimize = (file) =>
    data = file.data
    path = file.path
    try
      if @options.ignored?.test(path)
        result = {data, map:file.map?.toString()}
        return Promise.resolve(result)
    catch er
      return Promise.reject("error checking ignored files to minimize #{er}")
    if file.map?
      @options.inSourceMap = file.map.toJSON()
    @options.outSourceMap = if @options.sourceMaps? then "#{path}.map" else undefined
    try
      optimized = Terser.minify(data, @options)
      result =
        data: optimized.code
      if @options.sourceMaps?
        result.map = optimized.map
        result.data = result.data.replace(///\n//# sourceMappingURL =\S+$///, '')
      return Promise.resolve(result)
    catch er
      return Promise.reject(formatError(er))
TerserOptimizer::brunchPlugin = true
TerserOptimizer::type = 'javascript'
module.exports = TerserOptimizer

