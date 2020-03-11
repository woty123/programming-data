/*Dart Basic Learning*/
void main(List<String> arguments) {
  print('Learning Dart');
  var num = 1 / 0;
  String s;
  Future.delayed(Duration(seconds: 1), () => print('num = ${num}'));
  try {
    print('num = ${s.substring(0)}');
  } on NoSuchMethodError catch (e) {
    print(e);
  }
}
