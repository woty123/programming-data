package me.ztiany.asm.agent.visitor;

import org.objectweb.asm.ClassVisitor;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

import java.util.Arrays;

/**
 * 移除一个类的字段
 */
public class RemoveMethodAdapter extends ClassVisitor {

    private String mName;
    private String mDesc;

    RemoveMethodAdapter(ClassVisitor cv, String mName, String mDesc) {
        super(Opcodes.ASM5, cv);
        System.out.println("cv = [" + cv + "], mName = [" + mName + "], mDesc = [" + mDesc + "]");
        this.mName = mName;
        this.mDesc = mDesc;
    }

    @Override
    public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions) {
        System.out.println("access = [" + access + "], name = [" + name + "], desc = [" + desc + "], signature = [" + signature + "], exceptions = [" + Arrays.toString(exceptions) + "]");
        //不转发到下一个链，就是移除该方法。因为类的生成最终是由 ClassWriter 处理的，我们不把这个方法的信息传递给它，自然它就不会生成这个方法。
        if (name.equals(mName) && desc.equals(mDesc)) {
            // do not delegate to next visitor -> this removes the method
            return null;
        }
        return cv.visitMethod(access, name, desc, signature, exceptions);
    }

}