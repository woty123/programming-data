package com.dongnao.player;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.SurfaceView;

public class MainActivity extends AppCompatActivity {

    private SurfaceView mSurfaceView;
    private DNPlayer mDNPlayer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mDNPlayer = new DNPlayer();
        mSurfaceView = findViewById(R.id.surfaceView);
        findViewById(R.id.btnStart).setOnClickListener(v -> {
            prepare();
        });
    }

    private void prepare() {
        mDNPlayer.setSurfaceView(mSurfaceView);
        mDNPlayer.setDataSource("rtsp://211.139.194.251:554/live/2/13E6330A31193128/5iLd2iNl5nQ2s8r8.sdp");
        mDNPlayer.prepare();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mDNPlayer.destroy();
    }

}