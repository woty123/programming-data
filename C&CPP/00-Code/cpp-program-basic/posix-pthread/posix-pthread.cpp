/*
 ============================================================================
 
 Author      : Ztiany
 Description : posix pthread

 ============================================================================
 */

#include <cstdlib>
#include <pthread.h>
#include <mutex>
#include <iostream>
#include "posix-pthread.h"

using namespace std;

void *createThread_task(void *args) {
    cout << "createThread_task self = " << pthread_self() << " running" << endl;
    return 0;
}

/*
默认为非分离线程
    非分离线程：可以被其他线程操作。
    分离线程：不能被其他线程操作。

线程的调度策略与优先级
 */

//示例1：创建线程
void createThreadSample() {//出参，获取线程id
    pthread_t pid;
    //入参，线程的属性，可以传 null
    pthread_attr_t pthreadAttr;
    pthread_attr_init(&pthreadAttr);
    pthread_attr_setdetachstate(&pthreadAttr, PTHREAD_CREATE_DETACHED);//设置为分离线程，此时 join 无效。
    pthread_attr_setschedpolicy(&pthreadAttr, SCHED_FIFO);//设置调度策略
    struct sched_param schedParam{};
    schedParam.sched_priority = sched_get_priority_max(SCHED_FIFO);//设置优先级
    cout << "max priority = " << schedParam.sched_priority << endl;
    pthread_attr_setschedparam(&pthreadAttr, &schedParam);

    //创建线程
    pthread_create(&pid, &pthreadAttr, createThread_task, 0);
    pthread_attr_destroy(&pthreadAttr);
    //启动线程
    pthread_join(pid, 0);

    cout << "createThreadSample end self = " << pthread_self() << endl;
}


void *threadSafeTask(void *args) {
    auto *params = static_cast<ThreadMutexParams *>(args);

    pthread_mutex_lock(params->mutex_);

    if (!params->queue_->empty()) {
        cout << "threadSafeTask " << " getElement " << params->queue_->front() << endl;
        params->queue_->pop();
    } else {
        cout << "threadSafeTask  " << " getElement " << "nothing" << endl;
    }

    pthread_mutex_unlock(params->mutex_);

    return 0;
}

void threadSafeSample() {
    queue<int> queue;
    for (int i = 0; i < 5; ++i) {
        queue.push(i);
    }
    pthread_mutex_t pthreadMutex;
    pthread_mutex_init(&pthreadMutex, 0);

    ThreadMutexParams threadMutexParams(&queue, &pthreadMutex);

    for (int i = 0; i < 5; ++i) {
        pthread_t pid;
        pthread_create(&pid, 0, threadSafeTask, &threadMutexParams);
    }

    pthread_mutex_destroy(&pthreadMutex);
    system("pause");
}

int main() {
    //createThreadSample();
    threadSafeSample();
    return EXIT_SUCCESS;
}

