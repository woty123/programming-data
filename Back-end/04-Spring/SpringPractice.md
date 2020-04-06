# SpringPractise

1. 页面中推荐始终使用绝对路径，比如`"${pageContext.request.contextPath }/emp`，因为相对路径的结果不是唯一的，比如当一个页面是其他多个页面的转发目标时。
