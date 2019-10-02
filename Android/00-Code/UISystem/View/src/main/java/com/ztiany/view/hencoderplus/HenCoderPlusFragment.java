package com.ztiany.view.hencoderplus;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.ztiany.view.R;

/**
 * @author Ztiany
 * Email: ztiany3@gmail.com
 * Date : 2019-10-02 15:08
 */
public class HenCoderPlusFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.hencoderplus_fragment_camera, container, false);
    }

}
