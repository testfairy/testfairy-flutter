package com.testfairy.flutter;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.Nullable;

import com.testfairy.Consumer;
import com.testfairy.FeedbackContent;
import com.testfairy.FeedbackFormField;
import com.testfairy.FeedbackOptions;
import com.testfairy.FeedbackVerifier;
import com.testfairy.SelectFeedbackFormField;
import com.testfairy.StringFeedbackFormField;
import com.testfairy.TestFairy;
import com.testfairy.TextAreaFeedbackFormField;
import com.testfairy.UserInteractionKind;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * TestfairyFlutterPlugin
 */
public class TestfairyFlutterPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

	private static final long HIDDEN_RECT_RETRIEVAL_THROTTLE = 128;
	private static final String[] USER_INTERACTION_META_DATA_KEYS = new String[]{
			"accessibilityLabel", "accessibilityIdentifier", "accessibilityHint", "className", "scrollableParentAccessibilityIdentifier", "textInScrollableParent"
	};

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

	private static Map<WeakReference<Activity>, FlutterActivityMethodChannelPair> activityChannelMapping = new ConcurrentHashMap<>();
	private static long lastTimeHiddenRectsSent = 0;

	/**
	 * Plugin registration. (Mandatory)
	 */
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
							(String) args.get("errorMessage"),
							(String) args.get("requestHeaders"),
							(byte[]) args.get("requestBody"),
							(String) args.get("responseHeaders"),
							(byte[]) args.get("responseBody")
					);
					result.success(null);
					break;
				case "addUserInteraction":
					addUserInteraction((String) args.get("kind"), (String) args.get("label"), (Map) args.get("info"));
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
				case "installFeedbackHandler":
					installFeedbackHandler((String) call.arguments());
					result.success(null);
					break;
				case "installCrashHandler":
					installCrashHandler((String) call.arguments());
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
							(String) args.get("defaultText"),
							(String) args.get("browserUrl"),
							(boolean) args.get("emailFieldVisible"),
							(boolean) args.get("emailMandatory"),
							(boolean) args.get("takeScreenshotButtonVisible"),
							(boolean) args.get("recordVideoButtonVisible"),
							(List<Map>) args.get("feedbackFormFields"),
							(int) args.get("callId")
					);
					result.success(null);
					break;
				case "disableAutoUpdate":
					disableAutoUpdate();
					result.success(null);
					break;
				case "hideWidget":
					hideWidget();
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

	@SuppressLint("NewApi")
	private static void getHiddenRects(final Consumer<Rect[]> consumer) {
		final FlutterActivityMethodChannelPair activeFlutterActivityMethodChannelPair = getActiveFlutterViewMethodChannelPair();

//		Log.i("TestFairy", "Attempting to reach channel for getting hidden rects");

		final Result dartResponse = new Result() {
			@Override
			public void success(@Nullable Object result) {
				sendRects((List<Map>) result, consumer);
			}

			@Override
			public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
				TestFairy.logThrowable(errorMessage);
			}

			@Override
			public void notImplemented() {
				Log.e("TESTFAIRYSDK", "Invalid channel invoke getHiddenRects");
			}
		};

		if (activeFlutterActivityMethodChannelPair != null) {
			final MethodChannel methodChannel = activeFlutterActivityMethodChannelPair.methodChannelWeakReference.get();
			final Activity activity = activeFlutterActivityMethodChannelPair.flutterActivityWeakReference.get();

			final Runnable askDartForHiddenRects = new Runnable() {
				@Override
				public void run() {
					methodChannel.invokeMethod("getHiddenRects", null, dartResponse);
				}
			};

			if (methodChannel != null && activity != null) {
//				Log.i("TestFairy", "Getting hidden rects from Flutter");

				if (System.currentTimeMillis() - lastTimeHiddenRectsSent > HIDDEN_RECT_RETRIEVAL_THROTTLE) {
					new Handler(activity.getMainLooper()).post(askDartForHiddenRects);
				} else {
					new Handler(activity.getMainLooper()).postDelayed(askDartForHiddenRects, HIDDEN_RECT_RETRIEVAL_THROTTLE);
				}
			}
		}
	}

	@SuppressLint("NewApi")
	private static void sendRects(@Nullable List<Map> result, final Consumer<Rect[]> consumer) {
		try {
			List<Map> rectsList = result;

			final Rect[] rects = new Rect[rectsList.size()];

			int i = 0;
			for (Map rectMap : rectsList) {
				int left = ((Number) rectMap.get("left")).intValue();
				int top = ((Number) rectMap.get("top")).intValue();
				int right = ((Number) rectMap.get("right")).intValue();
				int bottom = ((Number) rectMap.get("bottom")).intValue();

				rects[i++] = new Rect(left, top, right, bottom);
			}

			consumer.accept(rects);
			lastTimeHiddenRectsSent = System.currentTimeMillis();
		} catch (Throwable t) {
			TestFairy.logThrowable(t);
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

	private boolean fakeHideViewCalledOnce = false;

	private void hideWidget() {
		if (fakeHideViewCalledOnce) {
			return;
		}

		fakeHideViewCalledOnce = true;
		withActivity(new ActivityConsumer<Void>() {
			@Override
			public Void consume(Activity activity) {
				View v = new View(activity);
				v.setId(-1);
				v.setVisibility(View.INVISIBLE);
				v.setClickable(false);

				ViewGroup decor = (ViewGroup) activity.getWindow().getDecorView();
				decor.addView(v, new ViewGroup.LayoutParams(1, 1));

				TestFairy.hideView(v);

				return null;
			}
		});
	}

	public void begin(final String appToken) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
					TestFairy.disableVideo();
				}

				TestFairy.begin(context, appToken);

				setExternalRectCapture();

				return null;
			}
		});

		// TODO : This is just a sample to test thread behavior, it shows how it successfully waits a result from the dart side
//		AsyncTask.execute(new Runnable() {
//			@Override
//			public void run() {
//				List<Map<String, Integer>> result = invokeChannelForResult("getHiddenRects", null);
//				Log.d("DIEGO", "Result: " + result.toString());
//			}
//		});

		// TODO : This is just a sample to test UI thread behavior, it shows how it hands on synchronous calls
//		new Handler(Looper.getMainLooper()).post(new Runnable() {
//			@Override
//			public void run() {
//				List<Map<String, Integer>> result = invokeChannelForResult("getHiddenRects", null);
//				Log.d("DIEGO", "Result: " + result.toString());
//			}
//		});
	}

	private void beginWithOptions(final String appToken, final Map options) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
					TestFairy.disableVideo();
				}

				TestFairy.begin(context, appToken, options);

				setExternalRectCapture();

				return null;
			}
		});
	}

	private void installCrashHandler(final String appToken) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.installCrashHandler(context, appToken);

				return null;
			}
		});
	}

	private void installFeedbackHandler(final String appToken) {
		withContext(new ContextConsumer<Void>() {
			@Override
			public Void consume(Context context) {
				TestFairy.installFeedbackHandler(context, appToken);

				setExternalRectCapture();

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

	private void invokeChannel(final String methodName, final Object args, final Result callback) {
		final FlutterActivityMethodChannelPair activeFlutterViewMethodChannelPair = getActiveFlutterViewMethodChannelPair();

		if (activeFlutterViewMethodChannelPair != null) {
			new Handler(activeFlutterViewMethodChannelPair.flutterActivityWeakReference.get().getMainLooper()).post(
					new Runnable() {
						@Override
						public void run() {
							activeFlutterViewMethodChannelPair.methodChannelWeakReference.get().invokeMethod(methodName, args, callback);
						}
					}
			);
		}
	}

	private static class ValueHolder<T> {
		public volatile T value;

		public ValueHolder(T value) {
			this.value = value;
		}
	}

	private <T> T invokeChannelForResult(final String methodName, final Object args) {
		final ValueHolder<T> value = new ValueHolder<>(null);
		final FutureTask<T> completion = new FutureTask<>(new Callable<T>() {
			@Override
			public T call() throws Exception {
				return null;
			}
		});

		invokeChannel(methodName, args, new Result() {
			@Override
			public void success(@Nullable Object result) {
				value.value = (T) result;
				completion.run();
			}

			@Override
			public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
				Log.e("TESTFAIRYSDK", "Flutter call to " + methodName + "() raised an error " + errorCode + ": " + (errorMessage != null ? errorCode : "N/A"));
				completion.run();
			}

			@Override
			public void notImplemented() {
				completion.run();
			}
		});

		try {
			completion.get();
		} catch (Throwable e) {
			Log.w("TESTFAIRYSDK", "Flutter cannot communicate with the SDK synchronously", e);
		}

		return value.value;
	}

	private void invokeChannel(final String methodName, final Object args) {
		invokeChannel(methodName, args, new Result() {
			@Override
			public void success(@Nullable Object result) {
				// Ignore
			}

			@Override
			public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
				// Ignore
			}

			@Override
			public void notImplemented() {
				// Ignore
			}
		});
	}

	private void setFeedbackOptions(
			String defaultText,
			String browserUrl,
			boolean emailFieldVisible,
			boolean emailMandatory,
			boolean takeScreenshotButtonVisible,
			boolean recordVideoButtonVisible,
			List<Map> feedbackFormFields,
			final int callId
	) {
		FeedbackOptions.Builder builder = new FeedbackOptions.Builder();

		if (defaultText != null) builder.setDefaultText(defaultText);
		if (browserUrl != null) builder.setBrowserUrl(browserUrl);
		builder.setEmailFieldVisible(emailFieldVisible);
		builder.setEmailMandatory(emailMandatory);
		builder.setTakeScreenshotButtonVisible(takeScreenshotButtonVisible);
		builder.setRecordVideoButtonVisible(recordVideoButtonVisible);

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

						invokeChannel("callOnFeedbackSent", feedbackContentMap);
						return null;
					}
				});
			}

			@Override
			public void onFeedbackCancelled() {
				withMethodChannel(new MethodChannelConsumer<Void>() {
					@Override
					public Void consume(MethodChannel channel) {
						invokeChannel("callOnFeedbackCancelled", callId);
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

						invokeChannel("callOnFeedbackFailed", feedbackContentMap);
						return null;
					}
				});
			}
		});

		if (feedbackFormFields != null) {
			List<FeedbackFormField> fields = new LinkedList<>();

			for (Map f : feedbackFormFields) {
				if (f.containsKey("type")) {
					switch ((String) f.get("type")) {
						case "StringFeedbackFormField":
							fields.add(new StringFeedbackFormField(f.get("attribute").toString(), f.get("placeholder").toString(), f.get("defaultValue").toString()));
							break;
						case "TextAreaFeedbackFormField":
							fields.add(new TextAreaFeedbackFormField(f.get("attribute").toString(), f.get("placeholder").toString(), f.get("defaultValue").toString()));
							break;
						case "SelectFeedbackFormField":
							fields.add(new SelectFeedbackFormField(f.get("attribute").toString(), f.get("label").toString(), (Map<String, String>) f.get("values"), f.get("defaultValue").toString()));
							break;
						default:
							break;
					}
				}
			}

			builder.setFeedbackFormFields(fields);
		}

//		builder.setFeedbackFormFields()
//		builder.setFeedbackInterceptor()

		TestFairy.setFeedbackOptions(builder.build());
	}

	// TODO
	private void setFeedbackVerifier(final int callId) {
		TestFairy.setFeedbackVerifier(new FeedbackVerifier() {
			@Override
			public boolean verifyFeedback(FeedbackContent feedbackContent) {
				return false;
			}

			@Override
			public String getVerificationFailedMessage() {
				return null;
			}
		});
	}

	private void disableAutoUpdate() {
		TestFairy.disableAutoUpdate();
	}

	private void addUserInteraction(String kind, String label, final Map info) {
		Map<String, String> sanitizedInfo = new HashMap<>();

		if (info != null) {
			for (String key : USER_INTERACTION_META_DATA_KEYS) {
				if (info.containsKey(key) && info.get(key) != null) {
					sanitizedInfo.put(key, info.get(key).toString());
				}
			}
		}

		TestFairy.addUserInteraction(UserInteractionKind.valueOf(kind.replaceAll("UserInteractionKind.", "")), label, sanitizedInfo);
	}

	private void addNetworkEvent(
			String uri,
			String method,
			int code,
			long startTimeMillis,
			long endTimeMillis,
			long requestSize,
			long responseSize,
			String errorMessage,
			String requestHeaders,
			byte[] requestBody,
			String responseHeaders,
			byte[] responseBody
	) {
		try {
			if (requestHeaders == null && requestBody == null && responseHeaders == null && responseBody == null) {
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
			} else {
				TestFairy.addNetworkEvent(
						new URI(uri),
						method,
						code,
						startTimeMillis,
						endTimeMillis,
						requestSize,
						responseSize,
						errorMessage,
						requestHeaders,
						requestBody,
						responseHeaders,
						responseBody
				);
			}
		} catch (URISyntaxException ignore) {
		}
	}

	private static void sendScreenshot(byte[] pixels, int width, int height) {
		Bitmap bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		ByteBuffer buffer = ByteBuffer.wrap(pixels, 0, width * height * 4);
		buffer.rewind();
		bmp.copyPixelsFromBuffer(buffer);

//		saveImage(bmp, "tfss-" + System.currentTimeMillis());

//		Log.i("TestFairy", "Sending screenshot to SDK");

		TestFairy.addScreenshot(bmp);
	}

	private void setExternalRectCapture() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			try {
				Method setExternalRectCaptureMethod = getMethodWithName(TestFairy.class, "setExternalRectCapture");
				setExternalRectCaptureMethod.invoke(null, new Consumer<Consumer<Rect[]>>() {
					@Override
					public void accept(Consumer<Rect[]> consumer) {
						getHiddenRects(consumer);
					}
				});
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private static void saveImage(Bitmap finalBitmap, String image_name) {
		String root = Environment.getExternalStorageDirectory().toString();
		File myDir = new File(root);
		myDir.mkdirs();
		String fname = "Image-" + image_name + ".jpg";
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
