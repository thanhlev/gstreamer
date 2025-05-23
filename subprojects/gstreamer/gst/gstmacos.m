#include "gstmacos.h"
#include <Cocoa/Cocoa.h>

typedef struct _ThreadArgs ThreadArgs;

struct _ThreadArgs {
  void* main_func;
  int argc;
  char **argv;
  gpointer user_data;
  gboolean is_simple;
  GMutex nsapp_mutex;
  GCond nsapp_cond;
  gboolean nsapp_running;
};

@interface GstCocoaApplicationDelegate : NSObject <NSApplicationDelegate>
@property (assign) GMutex *nsapp_mutex;
@property (assign) GCond *nsapp_cond;
@property (assign) gboolean *nsapp_running;
@end

@implementation GstCocoaApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  g_mutex_lock (self.nsapp_mutex);
  *self.nsapp_running = TRUE;
  g_cond_signal (self.nsapp_cond);
  g_mutex_unlock (self.nsapp_mutex);
}

@end

int
gst_thread_func (ThreadArgs *args)
{
  /* Only proceed once NSApp is running, otherwise we could
   * attempt to call [NSApp: stop] before it's even started. */
  g_mutex_lock (&args->nsapp_mutex);
  while (!args->nsapp_running) {
    g_cond_wait (&args->nsapp_cond, &args->nsapp_mutex);
  }
  g_mutex_unlock (&args->nsapp_mutex);

  int ret;
  if (args->is_simple) {
    ret = ((GstMainFuncSimple) args->main_func) (args->user_data);
  } else {
    ret = ((GstMainFunc) args->main_func) (args->argc, args->argv, args->user_data);
  }

  /* Post a message so we'll break out of the message loop */
  NSEvent *event = [NSEvent otherEventWithType: NSEventTypeApplicationDefined
                       location: NSZeroPoint
                  modifierFlags: 0
                      timestamp: 0
                   windowNumber: 0
                        context: nil
                        subtype: NSEventSubtypeApplicationActivated
                          data1: 0
                          data2: 0];

  [NSApp stop:nil];
  [NSApp postEvent:event atStart:YES];

  return ret;
}

int
run_main_with_nsapp (ThreadArgs args)
{
  GThread *gst_thread;
  GstCocoaApplicationDelegate* delegate;
  int result;

  g_mutex_init (&args.nsapp_mutex);
  g_cond_init (&args.nsapp_cond);
  args.nsapp_running = FALSE;

  [NSApplication sharedApplication];
  delegate = [[GstCocoaApplicationDelegate alloc] init];
  delegate.nsapp_mutex = &args.nsapp_mutex;
  delegate.nsapp_cond = &args.nsapp_cond;
  delegate.nsapp_running = &args.nsapp_running;
  [NSApp setDelegate:delegate];

  /* This lets us show an icon in the dock and correctly focus opened windows */
  if ([NSApp activationPolicy] == NSApplicationActivationPolicyProhibited) {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
  }

  gst_thread = g_thread_new ("macos-gst-thread", (GThreadFunc) gst_thread_func, &args);
  [NSApp run];
  result = GPOINTER_TO_INT (g_thread_join (gst_thread));

  g_mutex_clear (&args.nsapp_mutex);
  g_cond_clear (&args.nsapp_cond);

  return result;
}

int gst_macos_main(GstMainFunc main_func, int argc, char **argv,
                   gpointer user_data) {
  ThreadArgs args;

  args.argc = argc;
  args.argv = argv;
  args.main_func = main_func;
  args.user_data = user_data;
  args.is_simple = FALSE;

  return run_main_with_nsapp(args);
}

int gst_macos_main_simple(GstMainFuncSimple main_func, gpointer user_data) {
  ThreadArgs args;

  args.argc = 0;
  args.argv = NULL;
  args.main_func = main_func;
  args.user_data = user_data;
  args.is_simple = TRUE;

  return run_main_with_nsapp (args);
}
