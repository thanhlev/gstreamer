gstopencv_sources = [
  'gstcvdilate.cpp',
  'gstcvdilateerode.cpp',
  'gstcvequalizehist.cpp',
  'gstcverode.cpp',
  'gstcvlaplace.cpp',
  'gstcvsmooth.cpp',
  'gstcvsobel.cpp',
  'gstdisparity.cpp',
  'gstedgedetect.cpp',
  'gstfaceblur.cpp',
  'gstfacedetect.cpp',
  'gstgrabcut.cpp',
  'gsthanddetect.cpp',
  'gstmotioncells.cpp',
  'gstopencv.cpp',
  'gstretinex.cpp',
  'gstsegmentation.cpp',
  'gstskindetect.cpp',
  'gsttemplatematch.cpp',
  'gsttextoverlay.cpp',
  'MotionCells.cpp',
  'motioncells_wrapper.cpp',
  'gstdewarp.cpp',
  'camerautils.cpp',
  'cameraevent.cpp',
  'gstcameracalibrate.cpp',
  'gstcameraundistort.cpp',
  'gstcvtracker.cpp'
]

gstopencv_headers = [
  'gstcvlaplace.h',
  'gstcameracalibrate.h',
  'gstcverode.h',
  'gstsegmentation.h',
  'gsttextoverlay.h',
  'gstcvequalizehist.h',
  'gstdisparity.h',
  'gstgrabcut.h',
  'gstedgedetect.h',
  'gstskindetect.h',
  'gsttemplatematch.h',
  'gstfacedetect.h',
  'gstretinex.h',
  'MotionCells.h',
  'gstcvdilateerode.h',
  'gstdewarp.h',
  'motioncells_wrapper.h',
  'gstcvdilate.h',
  'gstcvsobel.h',
  'gstfaceblur.h',
  'gstmotioncells.h',
  'gstcvsmooth.h',
  'gsthanddetect.h',
  'gstcameraundistort.h',
  'gstcvtracker.h',
]

doc_sources = []
foreach s: gstopencv_sources + gstopencv_headers
  doc_sources += meson.current_source_dir() / s
endforeach

plugin_sources += {
  'opencv': pathsep.join(doc_sources)
}

if get_option('opencv').disabled() or not opencv_dep.found() or not gstopencv_dep.found()
  subdir_done()
endif

gstopencv = library('gstopencv',
  gstopencv_sources,
  cpp_args : gst_plugins_bad_args + gstopencv_cargs + [ '-DGST_USE_UNSTABLE_API' ],
  link_args : noseh_link_args,
  include_directories : [configinc, libsinc],
  dependencies : [gstbase_dep, gstvideo_dep, opencv_dep, gstopencv_dep],
  install : true,
  install_dir : plugins_install_dir,
)
plugins += [gstopencv]
