Terser = require('terser')
formatError = (error) ->
    err = new Error("L#{error.line}:#{error.col} #{error.message}")
    err.name = ''
    err.stack = error.stack
    err

minifyOptions = (opts) ->
  opts = opts ? {}
  return {
    ecma: opts.ecma
    warnings: opts.warnings
    parse: opts.parse ? {
      bare_returns: false
      ecma: 8
      html5_comments: true
      shebang: true
    }
    compress: opts.compress ? {
      arrows: true
      arguments: false
      booleans: true
      collapse_vars: true
      comparisons: true
      computed_props: true
      conditionals: true
      dead_code: true
      defaults: true
      directives: true
      drop_console: false
      drop_debugger: true
      ecma: 5
      evaluate: true
      expression: false
      global_defs: {}
      hoist_funs: false
      hoist_props: true
      hoist_vars: false
      if_return: true
      inline: true
      join_vars: true
      keep_classnames: false
      keep_fargs: true
      keep_fnames: false
      keep_infinity: false
      loops: true
      module: false
      negate_iife: true
      passes: 1
      properties: true
      pure_funcs: null
      pure_getters: 'strict'
      reduce_funcs: true
      reduce_vars: true
      sequences: true
      side_effects: true
      switches: true
      toplevel: false
      top_retain: null
      typeofs: true
      unsafe: false
      unsafe_arrows: false
      unsafe_comps: false
      unsafe_Function: false
      unsafe_math: false
      unsafe_methods: false
      unsafe_proto: false
      unsafe_regexp: false
      unsafe_undefined: false
      unused: true
      warnings: false
    }
    mangle: opts.mangle ? true
    module: opts.module ? false
    output: opts.output ? { }
    sourceMap: opts.sourceMap ? false
    toplevel: opts.toplevel ? false
    nameCache: opts.nameCache ? null
    ie8: opts.ie8 ? false
    keep_fnames: opts.keep_fnames ? false
    safari10: opts.safari10 ? false
  }

TerserOptimizer = (config) ->
  @options = Object.assign {}, config.plugins.terser
  @options.sourceMaps = !!@options.sourceMaps
  @optimize = (file) =>
    data = file.data
    path = file.path
    try
      if @options.ignored?.test(path)
        result = {data, map:file.map?.toString()}
        return Promise.resolve(result)
    catch er
      return Promise.reject("error checking ignored files to minimize #{er}")
    if@options.sourceMaps?
      if file.map?
        @options.sourceMap =
          content: file.map.toJSON()
          url: "#{path}.map"
      else
        @options.sourceMap =
          filename: path
          url: "#{path}.map"
    try
      opts = minifyOptions(@options)
      optimized = Terser.minify(data, opts)
      if optimized.error?
        return Promise.reject(formatError(optimized.error))
      result =
        data: optimized.code
      if @options.sourceMaps?
        result.map = optimized.map
        result.data = result.data.replace(///\n//# sourceMappingURL =\S+$///, '')
      return Promise.resolve(result)
    catch er
      return Promise.reject(formatError(er))
  return
TerserOptimizer::brunchPlugin = true
TerserOptimizer::type = 'javascript'
module.exports = TerserOptimizer

