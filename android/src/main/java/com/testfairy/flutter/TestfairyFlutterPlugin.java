package com.testfairy.flutter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;

import com.testfairy.FeedbackContent;
import com.testfairy.FeedbackOptions;
import com.testfairy.TestFairy;

import java.io.File;
import java.io.FileOutputStream;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;

/** TestfairyFlutterPlugin */
public class TestfairyFlutterPlugin implements MethodCallHandler {

	private class TestfairyFlutterException extends Exception {
		public TestfairyFlutterException(String msg) {
			super(msg);
		}
	}

	private static class FlutterViewMethodChannelPair {
		public WeakReference<FlutterView> flutterViewWeakReference;
		public WeakReference<MethodChannel> methodChannelWeakReference;

		public FlutterViewMethodChannelPair(FlutterView flutterView, MethodChannel methodChannel) {
			this.flutterViewWeakReference = new WeakReference<>(flutterView);
			this.methodChannelWeakReference = new WeakReference<>(methodChannel);
		}

		public boolean isValid() {
			return flutterViewWeakReference.get() != null && methodChannelWeakReference.get() != null;
		}
	}

	private WeakReference<Context> contextWeakReference = new WeakReference<>(null);
	private WeakReference<MethodChannel> methodChannelWeakReference = new WeakReference<>(null);
	private WeakReference<Activity> activityWeakReference = new WeakReference<>(null);
	private WeakReference<FlutterView> flutterViewWeakReference = new WeakReference<>(null);

	static private Map<WeakReference<Context>, FlutterViewMethodChannelPair> contextChannelMapping = new ConcurrentHashMap<>();

	static private FlutterViewMethodChannelPair getActiveFlutterViewMethodChannelPair() {
		List<Runnable> cleanUp = new ArrayList<>();
		FlutterViewMethodChannelPair result = null;

		for (final WeakReference<Context> c : contextChannelMapping.keySet()) {
			final FlutterViewMethodChannelPair flutterViewMethodChannelPair = contextChannelMapping.get(c);

			if (c.get() != null && flutterViewMethodChannelPair.isValid()) {
				if (c.get() == flutterViewMethodChannelPair.flutterViewWeakReference.get().getContext()) {
					result = flutterViewMethodChannelPair;
				}
			} else {
				cleanUp.add(new Runnable() {
					@Override
					public void run() {
						contextChannelMapping.remove(c);
					}
				});
			}
		}

		for (Runnable r : cleanUp) r.run();

		return result;
	}

	static private void takeScreenshot() {
		FlutterViewMethodChannelPair activeFlutterViewMethodChannelPair = getActiveFlutterViewMethodChannelPair();

		if (activeFlutterViewMethodChannelPair != null) {
			MethodChannel methodChannel = activeFlutterViewMethodChannelPair.methodChannelWeakReference.get();

			if (methodChannel != null) {
				methodChannel.invokeMethod("takeScreenshot", null, null);
			}
		}
	}

	/** Plugin registration. (Mandatory)*/
	public static void registerWith(Registrar registrar) {
		final MethodChannel channel = new MethodChannel(registrar.messenger(), "testfairy");
		final TestfairyFlutterPlugin testfairyFlutterPlugin = new TestfairyFlutterPlugin();

		testfairyFlutterPlugin.methodChannelWeakReference = new WeakReference<>(channel);
		testfairyFlutterPlugin.contextWeakReference = new WeakReference<>(registrar.context());
		testfairyFlutterPlugin.activityWeakReference = new WeakReference<>(registrar.activity());
		testfairyFlutterPlugin.flutterViewWeakReference = new WeakReference<>(registrar.view());

		channel.setMethodCallHandler(testfairyFlutterPlugin);

		contextChannelMapping.put(
				new WeakReference<Context>(registrar.activity()),
				new FlutterViewMethodChannelPair(registrar.view(), channel)
		);
	}

	@Override
	public void onMethodCall(MethodCall call, Result result) {
		try {
			Map args = null;
			if (call.arguments instanceof Map) {
				args = call.arguments();
			}

			switch (call.method) {
				case "sendScreenshot":
					sendScreenshot((byte[]) args.get("pixels"), (int) args.get("width"), (int) args.get("height"));
					result.success(null);
					break;
				case "begin":
					begin((String) call.arguments());
					result.success(null);
					break;
				case "beginWithOptions":
					beginWithOptions((String) args.get("appToken"), (Map) args.get("options"));
					result.success(null);
					break;
				case "setServerEndpoint":
					setServerEndpoint((String) call.arguments());
					result.success(null);
					break;
				case "getVersion":
					result.success(getVersion());
					break;
				case "sendUserFeedback":
					sendUserFeedback((String) call.arguments());
					result.success(null);
					break;
				case "addCheckpoint":
					addCheckpoint((String) call.arguments());
					result.success(null);
					break;
				case "addEvent":
					addEvent((String) call.arguments());
					result.success(null);
					break;
				case "setCorrelationId":
					setCorrelationId((String) call.arguments());
					result.success(null);
					break;
				case "identifyWithTraits":
					identifyWithTraits((String) args.get("id"), (Map) args.get("traits"));
					result.success(null);
					break;
				case "identify":
					identify((String) call.arguments());
					result.success(null);
					break;
				case "setUserId":
					setUserId((String) call.arguments());
					result.success(null);
					break;
				case "setAttribute":
					setAttribute((String) args.get("key"), (String) args.get("value"));
					result.success(null);
					break;
				case "getSessionUrl":
					result.success(getSessionUrl());
					break;
				case "showFeedbackForm":
					showFeedbackForm();
					result.success(null);
					break;
				case "stop":
					stop();
					result.success(null);
					break;
				case "resume":
					resume();
					result.success(null);
					break;
				case "pause":
					pause();
					result.success(null);
					break;
				case "log":
					log((String) call.arguments());
					result.success(null);
					break;
				case "setScreenName":
					setScreenName((String) call.arguments());
					result.success(null);
					break;
				case "didLastSessionCrash":
					result.success(didLastSessionCrash());
					break;
				case "enableCrashHandler":
					enableCrashHandler();
					result.success(null);
					break;
				case "disableCrashHandler":
					disableCrashHandler();
					result.success(null);
					break;
				case "enableMetric":
					enableMetric((String) call.arguments());
					result.success(null);
					break;
				case "disableMetric":
					disableMetric((String) call.arguments());
					result.success(null);
					break;
				case "enableVideo":
					enableVideo(
							(String) args.get("policy"),
							(String) args.get("quality"),
							(double) args.get("framesPerSecond")
					);
					result.success(null);
					break;
				case "disableVideo":
					disableVideo();
					result.success(null);
					break;
				case "enableFeedbackForm":
					enableFeedbackForm((String) call.arguments());
					result.success(null);
					break;
				case "disableFeedbackForm":
					disableFeedbackForm();
					result.success(null);
					break;
				case "setMaxSessionLength":
					setMaxSessionLength((double) call.arguments());
					result.success(null);
					break;
				case "bringFlutterToFront":
					bringFlutterToFront();
					result.success(null);
					break;
				case "logError":
					logError((String) call.arguments());
					result.success(null);
					break;
				case "setFeedbackOptions":
					setFeedbackOptions(
							(String) args.get("browserUrl"),
							(boolean) args.get("emailFieldVisible"),
							(boolean) args.get("emailMandatory"),
							(int) args.get("callId")
					);
					break;
				default:
					result.notImplemented();
					break;
			}
		} catch (Throwable e) {
			Log.e("TESTFAIRYSDK", "Invalid channel invoke", e);
			result.notImplemented();
		}
	}

	private interface ContextConsumer<T> {
		T consume(Context context);
	}
	private <T> T withContext(ContextConsumer<T> consumer) {
		if (contextWeakReference.get() != null) {
			return consumer.consume(contextWeakReference.get());
		}

		return null;
	}

	private interface MethodChannelConsumer<T> {
		T consume(MethodChannel channel);
	}
	private <T> T withMethodChannel(MethodChannelConsumer<T> consumer) {
		if (methodChannelWeakReference.get() != null) {
			return consumer.consume(methodChannelWeakReference.get());
		}

		return null;
	}

	private interface ActivityConsumer<T> {
		T consume(Activity activity);
	}
	private <T> T withActivity(ActivityConsumer<T> consumer) {
		if (activityWeakReference.get() != null) {
			return consumer.consume(activityWeakReference.get());
		}

		return null;
	}

	private interface FlutterViewConsumer<T> {
		T consume(FlutterView flutterView);
	}
	private <T> T withFlutterView(FlutterViewConsumer<T> consumer) {
		if (flutterViewWeakReference.get() != null) {
			return consumer.consume(flutterViewWeakReference.get());
		}

		return null;
	}

	// SDK mapping

	public void begin(final String appToken) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.begin(context, appToken);

				return null;
			}
		});
	}

	private void beginWithOptions(final String appToken, final Map options) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.begin(context, appToken, options);

				return null;
			}
		});
	}

	private void setServerEndpoint(final String endpoint) {
		TestFairy.setServerEndpoint(endpoint);
	}

	private String getVersion() {
		return TestFairy.getVersion();
	}

	private void sendUserFeedback(String feedback) {
		TestFairy.sendUserFeedback(feedback);
	}

	private void addCheckpoint(String cp) {
		TestFairy.addCheckpoint(cp);
	}

	private void addEvent(String e) {
		TestFairy.addEvent(e);
	}

	private void setCorrelationId(String id) {
		TestFairy.setCorrelationId(id);
	}

	private void identifyWithTraits(String id, Map traits) {
		TestFairy.identify(id, traits);
	}

	private void identify(String id) {
		TestFairy.identify(id);
	}

	private void setUserId(String id) {
		TestFairy.setUserId(id);
	}

	private boolean setAttribute(String key, String value) {
		return TestFairy.setAttribute(key, value);
	}

	private String getSessionUrl() {
		return TestFairy.getSessionUrl();
	}

	private void showFeedbackForm() {
		TestFairy.showFeedbackForm();
	}

	private void stop() {
		TestFairy.stop();
	}

	private void resume() {
		TestFairy.resume();
	}

	private void pause() {
		TestFairy.pause();
	}

	private void logError(String error) {
		TestFairy.logThrowable(new TestfairyFlutterException(error));
	}

	private void log(String msg) {
		TestFairy.log("TESTFAIRYSDK", msg);
	}

	private void setScreenName(String name) {
		TestFairy.setScreenName(name);
	}

	private boolean didLastSessionCrash() {
		return withContext(new ContextConsumer<Boolean>() {
			@Override
			public Boolean consume(Context context) {
				return TestFairy.didLastSessionCrash(context);
			}
		});
	}

	private void enableCrashHandler() {
		TestFairy.enableCrashHandler();
	}

	private void disableCrashHandler() {
		TestFairy.disableCrashHandler();
	}

	private void enableMetric(String metric) {
		TestFairy.enableMetric(metric);
	}

	private void disableMetric(String metric) {
		TestFairy.disableMetric(metric);
	}

	private void enableVideo(String policy, String quality, double framesPerSecond) {
		TestFairy.enableVideo(policy, quality, (float) framesPerSecond);
	}

	private void disableVideo() {
		TestFairy.disableVideo();
	}

	private void enableFeedbackForm(String method) {
		TestFairy.enableFeedbackForm(method);
	}

	private void disableFeedbackForm() {
		TestFairy.disableFeedbackForm();
	}

	private void setMaxSessionLength(double seconds) {
		TestFairy.setMaxSessionLength((float) seconds);
	}

	private void bringFlutterToFront() {
		withActivity(new ActivityConsumer<Void>() {
			@Override
			public Void consume(Activity activity) {
				Intent i = new Intent(activity, activity.getClass());
				i.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
				activity.startActivity(i);

				return null;
			}
		});
	}

	private void setFeedbackOptions(String browserUrl, boolean emailFieldVisible, boolean emailMandatory, final int callId) {
		FeedbackOptions.Builder builder = new FeedbackOptions.Builder();

		if (browserUrl != null) builder.setBrowserUrl(browserUrl);
		builder.setEmailFieldVisible(emailFieldVisible);
		builder.setEmailMandatory(emailMandatory);

		builder.setCallback(new FeedbackOptions.Callback() {
			@Override
			public void onFeedbackSent(final FeedbackContent feedbackContent) {
				withMethodChannel(new MethodChannelConsumer<Void>() {
					@Override
					public Void consume(MethodChannel channel) {
						Map<String, Object> feedbackContentMap = new HashMap<>();

						feedbackContentMap.put("email", feedbackContent.getEmail());
						feedbackContentMap.put("text", feedbackContent.getText());
						feedbackContentMap.put("timestamp", (double) feedbackContent.getTimestamp());
						feedbackContentMap.put("callId", callId);

						channel.invokeMethod("callOnFeedbackSent", feedbackContentMap);
						return null;
					}
				});
			}

			@Override
			public void onFeedbackCancelled() {
				withMethodChannel(new MethodChannelConsumer<Void>() {
					@Override
					public Void consume(MethodChannel channel) {
						channel.invokeMethod("callOnFeedbackCancelled", callId);
						return null;
					}
				});
			}

			@Override
			public void onFeedbackFailed(final int i, final FeedbackContent feedbackContent) {
				withMethodChannel(new MethodChannelConsumer<Void>() {
					@Override
					public Void consume(MethodChannel channel) {
						Map<String, Object> feedbackContentMap = new HashMap<>();

						feedbackContentMap.put("email", feedbackContent.getEmail());
						feedbackContentMap.put("text", feedbackContent.getText());
						feedbackContentMap.put("timestamp", (double) feedbackContent.getTimestamp());
						feedbackContentMap.put("i", i);
						feedbackContentMap.put("callId", callId);

						channel.invokeMethod("callOnFeedbackFailed", feedbackContentMap);
						return null;
					}
				});
			}
		});

		TestFairy.setFeedbackOptions(builder.build());
	}

	static private void sendScreenshot(byte[] pixels, int width, int height) {
		Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		ByteBuffer buffer = ByteBuffer.wrap(pixels);
		bmp.copyPixelsFromBuffer(buffer);

		// TODO : send to testfairy
		saveImage(bmp, "tfss-" + System.currentTimeMillis());
	}

//	private void addNetworkEvent(
//			URI uri,
//			String method,
//			int code,
//			long startTimeMillis,
//			long endTimeMillis,
//			long requestSize,
//			long responseSize,
//			String errorMessage
//	) {
//		// TODO
//	}

	private static void saveImage(Bitmap finalBitmap, String image_name) {
		String root = Environment.getExternalStorageDirectory().toString();
		File myDir = new File(root);
		myDir.mkdirs();
		String fname = "Image-" + image_name+ ".jpg";
		File file = new File(myDir, fname);
		if (file.exists()) file.delete();
		Log.i("TestFairy", "Saved image to " + root + "/" + fname);
		try {
			FileOutputStream out = new FileOutputStream(file);
			finalBitmap.compress(Bitmap.CompressFormat.JPEG, 90, out);
			out.flush();
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
