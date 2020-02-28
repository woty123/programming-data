package me.ztiany.androidintegrateflutter

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity


class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    fun openFlutter(view: View) {
        FlutterActivity.withNewEngine()
            .initialRoute("page name")
            .build(this)
            .run { startActivity(this) }
    }

}
