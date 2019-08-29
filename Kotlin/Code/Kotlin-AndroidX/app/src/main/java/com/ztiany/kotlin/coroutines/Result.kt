package com.ztiany.kotlin.coroutines

/**the result for instead deferred.await */
data class Result<out T>(val success: T? = null, val error: Throwable? = null)