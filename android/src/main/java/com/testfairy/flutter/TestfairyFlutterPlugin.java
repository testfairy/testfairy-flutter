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
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TestfairyFlutterPlugin */
public class TestfairyFlutterPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

	private static class FlutterActivityMethodChannelPair {
		public WeakReference<Activity> flutterActivityWeakReference;
		public WeakReference<MethodChannel> methodChannelWeakReference;

		public FlutterActivityMethodChannelPair(Activity activity, MethodChannel methodChannel) {
			this.flutterActivityWeakReference = new WeakReference<>(activity);
			this.methodChannelWeakReference = new WeakReference<>(methodChannel);
		}

		public boolean isValid() {
			return flutterActivityWeakReference.get() != null && methodChannelWeakReference.get() != null;
		}
	}

	private WeakReference<Context> contextWeakReference = new WeakReference<>(null);
	private WeakReference<MethodChannel> methodChannelWeakReference = new WeakReference<>(null);
	private WeakReference<Activity> activityWeakReference = new WeakReference<>(null);

	static private Map<WeakReference<Activity>, FlutterActivityMethodChannelPair> activityChannelMapping = new ConcurrentHashMap<>();

	/** Plugin registration. (Mandatory)*/
	public static void registerWith(Registrar registrar) {
		final MethodChannel channel = new MethodChannel(registrar.messenger(), "testfairy");
		final TestfairyFlutterPlugin testfairyFlutterPlugin = new TestfairyFlutterPlugin();

		testfairyFlutterPlugin.methodChannelWeakReference = new WeakReference<>(channel);
		testfairyFlutterPlugin.contextWeakReference = new WeakReference<>(registrar.context());
		testfairyFlutterPlugin.activityWeakReference = new WeakReference<>(registrar.activity());

		channel.setMethodCallHandler(testfairyFlutterPlugin);

		activityChannelMapping.put(
				new WeakReference<>(registrar.activity()),
				new FlutterActivityMethodChannelPair(registrar.activity(), channel)
		);
	}

	@Override
	public void onAttachedToEngine(FlutterPluginBinding binding) {
		final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), "testfairy");

		this.methodChannelWeakReference = new WeakReference<>(channel);
		this.contextWeakReference = new WeakReference<>(binding.getApplicationContext());

		channel.setMethodCallHandler(this);
	}

	@Override
	public void onDetachedFromEngine(FlutterPluginBinding binding) {
	}

	@Override
	public void onAttachedToActivity(ActivityPluginBinding binding) {
		this.activityWeakReference = new WeakReference<>(binding.getActivity());

		activityChannelMapping.put(
				new WeakReference<>(binding.getActivity()),
				new FlutterActivityMethodChannelPair(binding.getActivity(), methodChannelWeakReference.get())
		);
	}

	@Override
	public void onDetachedFromActivityForConfigChanges() {
	}

	@Override
	public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
		this.activityWeakReference = new WeakReference<>(binding.getActivity());

		activityChannelMapping.put(
				new WeakReference<>(binding.getActivity()),
				new FlutterActivityMethodChannelPair(binding.getActivity(), methodChannelWeakReference.get())
		);
	}

	@Override
	public void onDetachedFromActivity() {
	}

	@Override
	public void onMethodCall(MethodCall call, Result result) {
		try {
			Map args = null;
			if (call.arguments instanceof Map) {
				args = call.arguments();
			}

			switch (call.method) {
				case "addNetworkEvent":
					addNetworkEvent(
							(String) args.get("uri"),
							(String) args.get("method"),
							(int) args.get("code"),
							((Number) args.get("startTimeMillis")).longValue(),
							((Number) args.get("endTimeMillis")).longValue(),
							((Number) args.get("requestSize")).longValue(),
							((Number) args.get("responseSize")).longValue(),
							(String) args.get("errorMessage")
					);
					result.success(null);
					break;
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
					result.success(null);
					break;
				case "disableAutoUpdate":
					disableAutoUpdate();
					result.success(null);
					break;
				default:
					result.notImplemented();
					break;
			}
		} catch (Throwable e) {
			Log.e("TESTFAIRYSDK", "Invalid channel invoke", e);

			StringWriter sw = new StringWriter();
			PrintWriter pw = new PrintWriter(sw);
			e.printStackTrace(pw);
			String stacktrace = sw.toString();

			result.error(
					"-1",
					e.getClass().getSimpleName() + ": " + e.getMessage() + "\n" + stacktrace,
					stacktrace
			);
		}
	}

	static private FlutterActivityMethodChannelPair getActiveFlutterViewMethodChannelPair() {
		List<Runnable> cleanUp = new ArrayList<>();
		FlutterActivityMethodChannelPair result = null;

		for (final WeakReference<Activity> a : activityChannelMapping.keySet()) {
			final FlutterActivityMethodChannelPair flutterActivityMethodChannelPair = activityChannelMapping.get(a);

			if (a.get() != null && flutterActivityMethodChannelPair.isValid()) {
				if (a.get() == flutterActivityMethodChannelPair.flutterActivityWeakReference.get()) {
					result = flutterActivityMethodChannelPair;
				}
			} else {
				cleanUp.add(new Runnable() {
					@Override
					public void run() {
						activityChannelMapping.remove(a);
					}
				});
			}
		}

		for (Runnable r : cleanUp) r.run();

		return result;
	}

	static private void takeScreenshot() {
		FlutterActivityMethodChannelPair activeFlutterViewMethodChannelPair = getActiveFlutterViewMethodChannelPair();

		if (activeFlutterViewMethodChannelPair != null) {
			MethodChannel methodChannel = activeFlutterViewMethodChannelPair.methodChannelWeakReference.get();

			if (methodChannel != null) {
				methodChannel.invokeMethod("takeScreenshot", null, null);
			}
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

	// SDK mapping

	public void begin(final String appToken) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.begin(context, appToken);

				setScreenshotProvider();

				return null;
			}
		});
	}

	private void beginWithOptions(final String appToken, final Map options) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.begin(context, appToken, options);

				setScreenshotProvider();

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
		TestFairy.logThrowable(error);
	}

	private void log(String msg) {
		TestFairy.log("Flutter", msg);
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
			public void onFeedbackFailed(final int feedbackNo, final FeedbackContent feedbackContent) {
				withMethodChannel(new MethodChannelConsumer<Void>() {
					@Override
					public Void consume(MethodChannel channel) {
						Map<String, Object> feedbackContentMap = new HashMap<>();

						feedbackContentMap.put("email", feedbackContent.getEmail());
						feedbackContentMap.put("text", feedbackContent.getText());
						feedbackContentMap.put("timestamp", (double) feedbackContent.getTimestamp());
						feedbackContentMap.put("feedbackNo", feedbackNo);
						feedbackContentMap.put("callId", callId);

						channel.invokeMethod("callOnFeedbackFailed", feedbackContentMap);
						return null;
					}
				});
			}
		});

		TestFairy.setFeedbackOptions(builder.build());
	}

	private void disableAutoUpdate() {
		TestFairy.disableAutoUpdate();
	}

	private void addNetworkEvent(
			String uri,
			String method,
			int code,
			long startTimeMillis,
			long endTimeMillis,
			long requestSize,
			long responseSize,
			String errorMessage
	) {
		try {
			TestFairy.addNetworkEvent(
				new URI(uri),
				method,
				code,
				startTimeMillis,
				endTimeMillis,
				requestSize,
				responseSize,
				errorMessage
			);
		} catch (URISyntaxException ignore) {
		}
	}

	static private void sendScreenshot(byte[] pixels, int width, int height) {
		Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		ByteBuffer buffer = ByteBuffer.wrap(pixels);
		bmp.copyPixelsFromBuffer(buffer);

//		saveImage(bmp, "tfss-" + System.currentTimeMillis());

		TestFairy.addScreenshot(bmp);
	}

	static private void setScreenshotProvider() {
		try {
			Method setScrenshotProvider = getMethodWithName(TestFairy.class, "setScreenshotProvider");
			setScrenshotProvider.invoke(null, new Runnable() {
				@Override
				public void run() {
					takeScreenshot();
				}
			});
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	}

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

	private static Method getMethodWithName(Class<?> klass, String method) {
		if (method == null || klass == null) return null;

		Method[] methods = klass.getDeclaredMethods();

		for (Method m : methods) {
			String mName = m.getName();
			if (mName.equals(method)) {
				m.setAccessible(true);
				return m;
			}
		}

		return null;
	}
}
