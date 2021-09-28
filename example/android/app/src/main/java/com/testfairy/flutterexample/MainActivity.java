package com.testfairy.flutterexample;

import android.content.Context;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.SplashScreen;

public class MainActivity extends FlutterActivity {
	public static class MySplashScreen implements SplashScreen {
		@Nullable
		@Override
		public View createSplashView(Context context, @Nullable Bundle savedInstanceState) {
			final View v = new View(context);
			return v;
		}

		@Override
		public void transitionToFlutter(Runnable onTransitionComplete) {
			onTransitionComplete.run();
		}
	}

	@Nullable
	@Override
	public SplashScreen provideSplashScreen() {
		return new MySplashScreen();
	}
}
