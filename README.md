# MJKTask
1.实现NSOperationQueue大部分功能，也增加一些NSOperationQueue没有的功能如下
  1).任务可以在主线程中执行
  2).只要是TaskQueue中触发的Task，即使业务方已经在自己开了线程不方便不改造，Task的完成也会等业务方完成之后才会置为完成
  
2.可以建构有向无顺图
3.可以用来处理冷启动
4.主线程空闲时可以处理低优先级的任务
