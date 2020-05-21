package com.dongnao.player;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.SurfaceView;

import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;

public class MainActivity extends AppCompatActivity {

    private DNPlayer mDNPlayer;
    private SystemMediaSelector mSystemMediaSelector;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        SurfaceView surfaceView = findViewById(R.id.surfaceView);

        mDNPlayer = new DNPlayer();
        mDNPlayer.setSurfaceView(surfaceView);

        mSystemMediaSelector = new SystemMediaSelector(path -> mDNPlayer.setDataSource(path), this);
        findViewById(R.id.btnStart).setOnClickListener(v -> prepare());
        findViewById(R.id.btnSelectFile).setOnClickListener(v -> mSystemMediaSelector.takeFile());

        mDNPlayer.setOnPrepareListener(() -> AndroidSchedulers.mainThread().scheduleDirect(() -> {
            mDNPlayer.start();
        }));
    }

    private void prepare() {
        mDNPlayer.prepare();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mDNPlayer.destroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        mSystemMediaSelector.onActivityResult(requestCode, resultCode, data);
    }

}