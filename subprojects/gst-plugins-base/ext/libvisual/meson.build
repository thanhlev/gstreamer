libvisual_sources = [
  'visual.c',
  'plugin.c',
]

libvisual_headers = [
  'visual.h',
]

doc_sources = []
foreach s: libvisual_sources + libvisual_headers
  doc_sources += meson.current_source_dir() / s
endforeach

plugin_sources += {
  'libvisual': pathsep.join(doc_sources)
}

libvisual_dep = dependency('libvisual-0.4', version : '>= 0.4.0',
                           required : get_option('libvisual'))
if libvisual_dep.found()
  core_conf.set_quoted('LIBVISUAL_PLUGINSBASEDIR',
    libvisual_dep.get_variable('pluginsbasedir'))

  # Ignore issues in libvisual header
  extra_args = cc.get_supported_arguments(['-Wno-old-style-definition'])

  gstlibvisual = library('gstlibvisual',
    libvisual_sources,
    c_args : gst_plugins_base_args + extra_args,
    include_directories: [configinc, libsinc],
    dependencies : [libvisual_dep, audio_dep, video_dep, pbutils_dep, gst_dep, gst_base_dep],
    install : true,
    install_dir : plugins_install_dir,
  )
  plugins += [gstlibvisual]
endif
