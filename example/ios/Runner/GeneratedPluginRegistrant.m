//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<audio_session/AudioSessionPlugin.h>)
#import <audio_session/AudioSessionPlugin.h>
#else
@import audio_session;
#endif

#if __has_include(<just_audio/JustAudioPlugin.h>)
#import <just_audio/JustAudioPlugin.h>
#else
@import just_audio;
#endif

#if __has_include(<pag/FlutterPagPlugin.h>)
#import <pag/FlutterPagPlugin.h>
#else
@import pag;
#endif

#if __has_include(<pag_flutter_audio/PagFlutterAudioPlugin.h>)
#import <pag_flutter_audio/PagFlutterAudioPlugin.h>
#else
@import pag_flutter_audio;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AudioSessionPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioSessionPlugin"]];
  [JustAudioPlugin registerWithRegistrar:[registry registrarForPlugin:@"JustAudioPlugin"]];
  [FlutterPagPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterPagPlugin"]];
  [PagFlutterAudioPlugin registerWithRegistrar:[registry registrarForPlugin:@"PagFlutterAudioPlugin"]];
}

@end
