package retrofit

import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET


interface GitHub {
    @GET("/")
    fun contributorsAsync(): Deferred<Map<String, String>>
}

private val okHttpClient = OkHttpClient.Builder().build()

private val retrofit = Retrofit.Builder().apply {
    baseUrl("https://api.github.com")
    client(okHttpClient)
    addConverterFactory(GsonConverterFactory.create())
    addCallAdapterFactory(CoroutineCallAdapterFactory())
}.build()

private val githubApi = retrofit.create(GitHub::class.java)


fun main() {
    sample1()
}

private fun sample1() = runBlocking {

    println("Making GitHub API request")

    val result = githubApi.contributorsAsync()

    launch {
        try {
            val contributors = result.await()
            println("contributors = $contributors")
        } finally {
            okHttpClient.dispatcher().executorService().shutdown()
        }
    }

    println("end...")
    delay(100)
//    result.cancel()
}