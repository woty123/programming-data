# GestureDetector

GestureDetector 用来检测手势，支持很多手势操作，使用很简单，代码如下：

```java
    mGestureDetector = new GestureDetector(getContext(), new GestureDetector.SimpleOnGestureListener() {
        ...
    });

    //如果需要拖动，设置此方法
    mGestureDetector.setIsLongpressEnabled(false);

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //事件交给mGestureDetector处理
        mGestureDetector.onTouchEvent(event);
        return super.onTouchEvent(event);
    }
```

通过SimpleOnGestureListener可以监听以下手势事件，这些手势说明如下：

|方法名 | 描述  |
| ------------ | ------------ |
| onDown  | 每次 ACTION_DOWN 事件出现的时候都会被调用，在这里返回 true 可以保证必然消费掉事件  |
| onShowPress  | 用户按下 100ms 不松⼿手后会被调用，⽤于标记「可以显示按下状态了」 |
| onSingleTapUp  | 用户单击时被调⽤(⻓按后松手不不会调用、双击的第二下时不会被调用) |
| onScroll  | 手指按下屏幕，并且拖动，由一个 ACTION_DOWN 和多个 ACTION_MOVE 触发，这是拖动行为  |
| onLongPress | 用户长按（一般是按下 500ms 不松⼿）后会被调用（在 GestureDetectorCompat）是 600ms |
| onFling |  手指按下屏幕，快速拖动屏幕后松开，有一个甩的动作，用于⽤户希望控件进行惯性滑动的场景 |
| onDoubleTap | 双击，由两个连续的单击事件组成，第二次触摸到屏幕时就会调用，⽽不是抬起时  |
| onSingleTopConfirmed  | 严格的单击行为，和 onSingleTapUp 的区别是，onSingleTopConfirmed 事件后面不可能在紧跟着一个单击行为，即这只是一个单击行为，不可能是双击行为中的一次单击，即不可能与 onDoubleTap 共存|
| onDoubleTapEvent | ⽤户双击第⼆次按下时、第⼆次按下后移动时、第二次按下后抬起时都会被调用，常⽤于「双击拖拽」的场景 |

详细的 GestureDetector 介绍可以参考 [Android 手势检测(GestureDetector)](https://github.com/GcsSloop/AndroidNote/blob/master/CustomView/Advance/%5B19%5Dgesture-detector.md)

## GestureDetectorCompat

GestureDetectorCompat 作为 GestureDetector 的兼容版本，支持更多的功能。
