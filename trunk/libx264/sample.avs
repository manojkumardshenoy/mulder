a = FFVideoSource("E:\Samples\Lossless\crew.704x576.avi").ChangeFPS(30.0)
b = FFVideoSource("E:\Samples\Lossless\soccer.704x576.avi")
return Dissolve(a,b,99)
