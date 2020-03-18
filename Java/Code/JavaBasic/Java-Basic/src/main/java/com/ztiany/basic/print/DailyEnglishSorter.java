package com.ztiany.basic.print;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;
import java.util.TreeMap;

/**
 * @author Ztiany
 * Email ztiany3@gmail.com
 * Date 2020/1/3 23:51
 */
public class DailyEnglishSorter {

    public static void main(String... args) throws IOException {
        File file = new File("files/DailyEnglishList");
        Map<Integer, String> map = new TreeMap<>();
        BufferedReader bufferedReader = new BufferedReader(new FileReader(file));
        String line = "";
        while ((line = bufferedReader.readLine()) != null) {
            addToMap(line, map);
        }
        bufferedReader.close();

        File fileOutput = new File("files/DailyEnglishListSorted");
        PrintWriter printWriter = new PrintWriter(new FileWriter(fileOutput));
        map.values().forEach(value -> printWriter.println("- " + value));
        printWriter.close();
    }

    private static void addToMap(String line, Map<Integer, String> map) {
        map.put(Integer.parseInt(line.split(" ")[2]), line);
    }

}
