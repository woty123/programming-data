# 自定义drawable

自定义 Drawable，相比 View 来说，Drawable 属于轻量级的、使用也很简单，如果多个 View 有一些相同绘制内容，可以考虑使用 Drawable 来实现重用。以后自定义实现一个效果的时候，可以改变 View first 的思想，尝试下 Drawable first。

下面提供两个自定义 drawable 的案例：

- CircleBackgroundDrawable

```java
public class CircleBackgroundDrawable extends Drawable {

    private Paint mPaint;

    public CircleBackgroundDrawable(int color) {
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(color);

    }

    @Override
    public void draw(Canvas canvas) {
        Rect bounds = getBounds();
        float centerX = bounds.exactCenterX();
        float centerY = bounds.exactCenterY();
        canvas.drawCircle(centerX, centerY, Math.min(centerX, centerY), mPaint);
    }

    @Override
    public void setAlpha(int alpha) {
        mPaint.setAlpha(alpha);
        invalidateSelf();
    }

    @Override
    public void setColorFilter(ColorFilter colorFilter) {
        mPaint.setColorFilter(colorFilter);
        invalidateSelf();
    }

    @Override
    public int getOpacity() {
        return paint.getAlpha() == 0 ? PixelFormat.TRANSPARENT : paint.getAlpha() == 0xff ? PixelFormat.OPAQUE : PixelFormat.TRANSLUCENT;
    }


    @Override
    public int getIntrinsicHeight() {
        return 100;
    }


    @Override
    public int getIntrinsicWidth() {
        return 100;
    }
}
```

- CircleDrawable

```java
public class CircleDrawable extends Drawable {

    private Bitmap mBitmap;
    private Paint mPaint;
    private RectF rectF;

    public CircleDrawable(Bitmap bitmap) {
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        BitmapShader bs = new BitmapShader(bitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP);
        mPaint.setShader(bs);
    }

    @Override
    public void setBounds(int left, int top, int right, int bottom) {
        super.setBounds(left, top, right, bottom);
        rectF = new RectF(left, top, right, bottom);
    }

    @Override
    public void draw(Canvas canvas) {
        canvas.drawRoundRect(rectF, 20,20,mPaint);
    }

    @Override
    public void setAlpha(int alpha) {
        mPaint.setAlpha(alpha);
        invalidateSelf();
    }

    @Override
    public void setColorFilter(ColorFilter colorFilter) {
        mPaint.setColorFilter(colorFilter);
        invalidateSelf();
    }

    @Override
    public int getOpacity() {
        return paint.getAlpha() == 0 ? PixelFormat.TRANSPARENT : paint.getAlpha() == 0xff ? PixelFormat.OPAQUE : PixelFormat.TRANSLUCENT;
    }

    @Override
    public int getIntrinsicWidth() {
        if (mBitmap != null) {
            return mBitmap.getWidth();
        }
        return super.getIntrinsicWidth();
    }

    @Override
    public int getIntrinsicHeight() {
        if (mBitmap != null) {
            return mBitmap.getHeight();
        }
        return super.getIntrinsicHeight();
    }
}
```

各个方法说明：

- `setColorFilter`：调用自己的 paint 设置后，调用 invalidateSelf 即可。
- `setAlpha`：用于设置透明度。
- `getOpacity` 获取一个值，用以表示该 Drawable 是否为透明的。
- `getIntrinsicHeight与getIntrinsicHeight`，默认的 drawable 并没有宽高都，这两个默认返回-1，如果要处理 view 的 wrap_content，需要返回一个有效值。
- `setBounds 与 getBounds`，getBounds 返回的是自身的区域大小，与 view 的大小有关
- `draw`：用于绘制自身
